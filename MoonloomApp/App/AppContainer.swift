import Foundation
import SwiftData

/// Lightweight dependency-injection container and lifecycle coordinator.
///
/// Owns the single `GameState` the UI observes plus all services (persistence,
/// production engine, offline calculator, prestige, haptics, audio, analytics).
/// Views receive `GameState` as an `@EnvironmentObject` and reach the container
/// for actions (buy, prestige, reset). `@MainActor` so all UI-facing state is
/// main-thread isolated.
@MainActor
final class AppContainer: ObservableObject {

    // Configuration & services
    let config: EconomyConfig
    let timeProvider: TimeProvider
    let repository: GameStateRepository
    let haptics: HapticsService
    let audio: AudioService
    let analytics: AnalyticsService
    let offlineCalculator: OfflineEarningsCalculator
    let prestigeCalculator: PrestigeCalculator

    // Observable state
    @Published private(set) var gameState: GameState
    /// Set when there are offline earnings to present in the "Welcome back" modal.
    @Published var pendingOfflineEarnings: OfflineEarningsCalculator.Result?
    @Published private(set) var isBootstrapped = false
    /// Transient banner text for a tier unlock or milestone (cleared by the UI).
    @Published var celebrationMessage: String?

    private var engine: ProductionEngine?

    // Progression-event tracking (for unlock/milestone celebrations).
    private var knownUnlockedTierIDs: Set<String> = []
    private var knownMilestoneIDs: Set<String> = []
    // Accumulator for the gentle ~1Hz "production pulse" feedback.
    private var pulseAccumulator: TimeInterval = 0

    init(
        modelContainer: ModelContainer,
        config: EconomyConfig = EconomyConfig(),
        timeProvider: TimeProvider = SystemTimeProvider()
    ) {
        self.config = config
        self.timeProvider = timeProvider
        self.repository = SwiftDataGameStateRepository(modelContainer: modelContainer)
        self.haptics = HapticsService()
        self.audio = AudioService()
        self.analytics = AnalyticsService()
        self.offlineCalculator = OfflineEarningsCalculator(config: config)
        self.prestigeCalculator = PrestigeCalculator(config: config)
        self.gameState = GameState(
            config: config,
            snapshot: .newGame(config: config, now: timeProvider.now())
        )
    }

    /// Load persisted state, credit offline earnings, and start the engine.
    /// Idempotent: safe to call once from the app's `.task`.
    func bootstrap() async {
        guard !isBootstrapped else { return }
        isBootstrapped = true

        let now = timeProvider.now()
        let loaded = await repository.load()

        if let loaded {
            gameState.restore(from: loaded)
            creditOfflineEarnings(since: loaded.lastActiveTimestamp, now: now)
        }
        gameState.updateLastActive(now)

        // Seed known unlocks/milestones so existing progress doesn't re-fire
        // celebrations on launch.
        knownUnlockedTierIDs = Set(gameState.unlockedTiers.map(\.id))
        knownMilestoneIDs = Set(gameState.achievedMilestones.map(\.id))

        applySettingsToServices()
        analytics.log(.appLaunched)
        if gameState.isMusicEnabled { audio.startAmbientMusic() }

        await startEngine()
        await save()
    }

    // MARK: - Player actions

    /// Buy one building of a tier. Returns whether the purchase succeeded.
    @discardableResult
    func purchase(_ tier: ProductionTier) -> Bool {
        let success = gameState.purchaseBuilding(tier)
        if success {
            haptics.impact(.light)
            audio.playSFX("building_tap")
            analytics.log(.buildingPurchased(tierID: tier.id, count: gameState.count(of: tier.id)))
            checkProgressEvents()
            Task { await save() }
        } else {
            haptics.warning()
        }
        return success
    }

    /// Buy a building upgrade. Returns whether the purchase succeeded.
    @discardableResult
    func purchaseUpgrade(_ upgrade: Upgrade) -> Bool {
        let success = gameState.purchaseUpgrade(upgrade)
        if success {
            haptics.impact(.medium)
            audio.playSFX("upgrade")
            analytics.log(.upgradePurchased(upgradeID: upgrade.id))
            checkProgressEvents()
            Task { await save() }
        } else {
            haptics.warning()
        }
        return success
    }

    /// Fulfil the given Dream Order. Returns whether it succeeded.
    @discardableResult
    func fulfillOrder(_ order: DreamOrder) -> Bool {
        let success = gameState.fulfillOrder(order)
        if success {
            haptics.success()
            audio.playSFX("order_complete")
            analytics.log(.orderFulfilled(index: order.index, rewardAmount: order.rewardAmount))
            Task { await save() }
        } else {
            haptics.warning()
        }
        return success
    }

    /// Restore a moon biome by spending Moonlight. Returns whether it succeeded.
    @discardableResult
    func restoreNode(_ node: RestorationNode) -> Bool {
        let success = gameState.restoreNode(node)
        if success {
            haptics.success()
            audio.playSFX("moon_restore")
            checkProgressEvents()
            Task { await save() }
        } else {
            haptics.warning()
        }
        return success
    }

    /// Whether a New Moon Reset is currently available.
    var canPrestige: Bool {
        prestigeCalculator.canPrestige(
            moonRestoration: gameState.moonRestoration,
            resetCount: gameState.resetCount
        )
    }

    /// Lucid Shards that the player would earn by prestiging right now.
    var projectedShards: Double {
        prestigeCalculator.lucidShardsEarned(
            moonRestoration: gameState.moonRestoration,
            resetCount: gameState.resetCount
        )
    }

    /// Perform a New Moon Reset if eligible. Stops the engine first to avoid a
    /// reset/tick race (RISK-008). Returns whether the reset happened.
    @discardableResult
    func performPrestige() async -> Bool {
        guard canPrestige else {
            haptics.warning()
            return false
        }
        let shards = projectedShards
        await engine?.stop()
        gameState.applyPrestige(shardsEarned: shards)
        analytics.log(.prestigePerformed(resetCount: gameState.resetCount, shardsEarned: shards))
        haptics.success()
        gameState.updateLastActive(timeProvider.now())
        await startEngine()
        await save()
        return true
    }

    /// Erase all progress and start a fresh save (Settings → reset).
    func resetProgress() async {
        await engine?.stop()
        await repository.deleteAll()
        gameState.restore(from: .newGame(config: config, now: timeProvider.now()))
        applySettingsToServices()
        await startEngine()
        await save()
    }

    /// Persist current settings toggles (called when a toggle changes).
    func persistSettings() async {
        applySettingsToServices()
        await save()
    }

    // MARK: - Scene lifecycle

    /// Call when the app moves to the background: stop ticking, stamp the
    /// last-active time, and persist so offline earnings can be computed later.
    func handleBackground() async {
        await engine?.stop()
        gameState.updateLastActive(timeProvider.now())
        audio.stopAmbientMusic()
        await save()
    }

    /// Call when the app returns to the foreground: credit time spent away,
    /// then resume ticking.
    func handleForeground() async {
        guard isBootstrapped else { return }
        let now = timeProvider.now()
        creditOfflineEarnings(since: gameState.lastActiveTimestamp, now: now)
        gameState.updateLastActive(now)
        if gameState.isMusicEnabled { audio.startAmbientMusic() }
        await startEngine()
        await save()
    }

    // MARK: - Internals

    private func creditOfflineEarnings(since lastActive: Date, now: Date) {
        let result = offlineCalculator.calculate(
            perSecond: gameState.outputPerSecondByResource(),
            capHours: gameState.offlineEarningCapHours,
            lastActive: lastActive,
            now: now
        )
        guard result.hasEarnings else { return }
        gameState.applyOfflineEarnings(result.earnings)
        pendingOfflineEarnings = result
        analytics.log(.offlineEarningsCollected(seconds: result.creditedSeconds))
    }

    private func applySettingsToServices() {
        haptics.isEnabled = gameState.isSFXEnabled
        audio.isMusicEnabled = gameState.isMusicEnabled
        audio.isSFXEnabled = gameState.isSFXEnabled
    }

    private func startEngine() async {
        if engine == nil {
            engine = ProductionEngine(
                tickInterval: config.tickInterval,
                timeProvider: timeProvider,
                apply: { [weak self] delta in
                    self?.onTick(delta: delta)
                }
            )
        }
        await engine?.resetBaseline()
        await engine?.start()
    }

    /// Per-tick hook: advance production, emit the gentle production pulse, and
    /// detect newly unlocked tiers/milestones for celebration.
    private func onTick(delta: TimeInterval) {
        gameState.applyProduction(delta: delta)
        emitProductionPulse(delta: delta)
        checkProgressEvents()
    }

    /// A subtle ~1Hz "heartbeat" sound hook while the factory is producing, so
    /// the screen feels alive without firing on every 0.1s tick. Deliberately a
    /// *sound* pulse only — a continuous 1Hz haptic would drain battery and
    /// annoy, so haptics are reserved for discrete events (purchase, upgrade,
    /// order, unlock, milestone, restore).
    private func emitProductionPulse(delta: TimeInterval) {
        guard gameState.totalBuildingCount > 0 else {
            pulseAccumulator = 0
            return
        }
        pulseAccumulator += delta
        guard pulseAccumulator >= config.productionPulseInterval else { return }
        pulseAccumulator = 0
        audio.playSFX("production_tick")
    }

    /// Fire one-shot celebrations when a new tier unlocks or a milestone is met.
    private func checkProgressEvents() {
        let unlocked = Set(gameState.unlockedTiers.map(\.id))
        let newTiers = unlocked.subtracting(knownUnlockedTierIDs)
        knownUnlockedTierIDs = unlocked
        if let tier = gameState.config.tiers
            .filter({ newTiers.contains($0.id) })
            .max(by: { $0.tier < $1.tier }) {
            celebrationMessage = "New building unlocked: \(tier.name)!"
            haptics.impact(.heavy)
            audio.playSFX("tier_unlock")
        }

        let achieved = Set(gameState.achievedMilestones.map(\.id))
        let newMilestones = achieved.subtracting(knownMilestoneIDs)
        knownMilestoneIDs = achieved
        if let milestone = gameState.config.milestones.first(where: { newMilestones.contains($0.id) }) {
            celebrationMessage = "Milestone reached: \(milestone.name)!"
            haptics.success()
            audio.playSFX("milestone")
        }
    }

    private func save() async {
        await repository.save(gameState.snapshot(now: timeProvider.now()))
    }
}
