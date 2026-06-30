import Foundation
import Combine

/// Central, observable game state holding all currencies, building counts,
/// upgrade flags, moon-restoration progress, prestige data, and settings.
///
/// This is the single source of truth the SwiftUI layer observes. It is
/// `@MainActor`-isolated so all mutations happen on the main thread (and is
/// therefore implicitly `Sendable`). Simulation math lives in the engine /
/// use cases and is applied here through small, intention-revealing methods —
/// views never mutate raw fields directly.
@MainActor
final class GameState: ObservableObject {

    let config: EconomyConfig

    /// Deterministic generator for the Dream Order chain.
    private let orderGenerator: OrderGenerator

    // MARK: - Currencies
    @Published private(set) var currencyAmounts: [ResourceType: Double]
    @Published private(set) var currencyLifetimeEarned: [ResourceType: Double]

    // MARK: - Buildings & upgrades
    @Published private(set) var buildingCounts: [String: Int]
    /// Per-building upgrade level (0...`config.maxUpgradeLevel`), keyed by tier id.
    @Published private(set) var upgradeLevels: [String: Int]
    /// Tiers the player has unlocked (paid the Moonlight unlock cost for).
    @Published private(set) var unlockedTierIDs: Set<String>
    /// Cached global production multiplier from milestones, updated by the app
    /// from `MilestoneService` (read synchronously in the hot tick path).
    @Published private(set) var globalMultiplier: Double = 1.0

    // MARK: - Orders
    /// Number of Dream Orders fulfilled (drives the sequential order board).
    @Published private(set) var ordersFulfilled: Int

    // MARK: - Moon restoration & prestige
    /// Identifiers of restored biome nodes. Overall restoration is the fraction
    /// of `config.restorationNodes` restored.
    @Published private(set) var restoredNodeIDs: Set<String>
    @Published private(set) var resetCount: Int
    @Published private(set) var totalLucidShardsEarned: Double
    @Published private(set) var bestRunMoonlightRestored: Double
    @Published private(set) var permanentUpgradeIDs: Set<String>
    /// Lunar Codex permanent-upgrade levels (upgrade id → level). Survives resets.
    @Published private(set) var lunarCodexLevels: [String: Int]
    /// Cached aggregate Lunar Codex effects (recomputed on change; read hot path).
    private(set) var lunarCodexEffects: LunarCodexEffects = LunarCodexEffects()

    // MARK: - Meta progression
    /// Achievement identifiers the player has unlocked.
    @Published private(set) var unlockedAchievementIDs: Set<String>
    /// Most recent daily-reward claim.
    @Published private(set) var lastDailyClaim: Date?
    /// Current consecutive-day login streak.
    @Published private(set) var dailyStreak: Int
    /// Active StoreKit entitlement product ids (cosmetics, expansion, Pass).
    @Published private(set) var entitlementProductIDs: Set<String>
    /// Whether first-launch onboarding has been completed.
    @Published private(set) var hasCompletedOnboarding: Bool

    // MARK: - Settings
    @Published var isMusicEnabled: Bool
    @Published var isSFXEnabled: Bool
    @Published var isNotificationsEnabled: Bool
    @Published private(set) var offlineEarningCapHours: Int
    @Published var theme: String

    // MARK: - Timing
    @Published private(set) var lastActiveTimestamp: Date

    // MARK: - Init

    init(config: EconomyConfig = EconomyConfig(), snapshot: GameSnapshot) {
        self.config = config
        self.orderGenerator = OrderGenerator(config: config)
        self.currencyAmounts = Self.decodeCurrencies(snapshot.currencyAmounts)
        self.currencyLifetimeEarned = Self.decodeCurrencies(snapshot.currencyLifetimeEarned)
        self.buildingCounts = snapshot.buildingCounts
        self.upgradeLevels = snapshot.upgradeLevels
        self.unlockedTierIDs = Set(snapshot.unlockedTierIDs)
        self.ordersFulfilled = snapshot.ordersFulfilled
        self.restoredNodeIDs = Set(snapshot.restoredNodeIDs)
        self.resetCount = snapshot.resetCount
        self.totalLucidShardsEarned = snapshot.totalLucidShardsEarned
        self.bestRunMoonlightRestored = snapshot.bestRunMoonlightRestored
        self.permanentUpgradeIDs = Set(snapshot.permanentUpgradeIDs)
        self.lunarCodexLevels = snapshot.lunarCodexLevels
        self.unlockedAchievementIDs = Set(snapshot.unlockedAchievementIDs)
        self.lastDailyClaim = snapshot.lastDailyClaim
        self.dailyStreak = snapshot.dailyStreak
        self.entitlementProductIDs = Set(snapshot.entitlementProductIDs)
        self.hasCompletedOnboarding = snapshot.hasCompletedOnboarding
        self.isMusicEnabled = snapshot.isMusicEnabled
        self.isSFXEnabled = snapshot.isSFXEnabled
        self.isNotificationsEnabled = snapshot.isNotificationsEnabled
        self.offlineEarningCapHours = snapshot.offlineEarningCapHours
        self.theme = snapshot.theme
        self.lastActiveTimestamp = snapshot.lastActiveTimestamp
        recomputeCodexEffects()
    }

    /// Overwrite all state from a snapshot in place (used after the async load
    /// at launch, so the observed `GameState` instance stays stable and the view
    /// tree is not torn down).
    func restore(from snapshot: GameSnapshot) {
        currencyAmounts = Self.decodeCurrencies(snapshot.currencyAmounts)
        currencyLifetimeEarned = Self.decodeCurrencies(snapshot.currencyLifetimeEarned)
        buildingCounts = snapshot.buildingCounts
        upgradeLevels = snapshot.upgradeLevels
        unlockedTierIDs = Set(snapshot.unlockedTierIDs)
        ordersFulfilled = snapshot.ordersFulfilled
        restoredNodeIDs = Set(snapshot.restoredNodeIDs)
        resetCount = snapshot.resetCount
        totalLucidShardsEarned = snapshot.totalLucidShardsEarned
        bestRunMoonlightRestored = snapshot.bestRunMoonlightRestored
        permanentUpgradeIDs = Set(snapshot.permanentUpgradeIDs)
        lunarCodexLevels = snapshot.lunarCodexLevels
        unlockedAchievementIDs = Set(snapshot.unlockedAchievementIDs)
        lastDailyClaim = snapshot.lastDailyClaim
        dailyStreak = snapshot.dailyStreak
        entitlementProductIDs = Set(snapshot.entitlementProductIDs)
        hasCompletedOnboarding = snapshot.hasCompletedOnboarding
        isMusicEnabled = snapshot.isMusicEnabled
        isSFXEnabled = snapshot.isSFXEnabled
        isNotificationsEnabled = snapshot.isNotificationsEnabled
        offlineEarningCapHours = snapshot.offlineEarningCapHours
        theme = snapshot.theme
        lastActiveTimestamp = snapshot.lastActiveTimestamp
        recomputeCodexEffects()
    }

    private static func decodeCurrencies(_ raw: [String: Double]) -> [ResourceType: Double] {
        var result: [ResourceType: Double] = [:]
        for (key, value) in raw {
            if let type = ResourceType(rawValue: key) {
                result[type] = value
            }
        }
        return result
    }

    // MARK: - Read helpers

    /// Current spendable amount of a currency.
    func amount(of type: ResourceType) -> Double {
        currencyAmounts[type] ?? 0
    }

    /// Number of buildings owned for a tier.
    func count(of tierID: String) -> Int {
        buildingCounts[tierID] ?? 0
    }

    /// Tiers that are currently unlocked (the player paid their unlock cost).
    var unlockedTiers: [ProductionTier] {
        config.tiers.filter { isUnlocked($0) }
    }

    /// Whether a tier has been unlocked. Tier 1 is always unlocked.
    func isUnlocked(_ tier: ProductionTier) -> Bool {
        tier.tier <= 1 || unlockedTierIDs.contains(tier.id)
    }

    /// Whether the tier *before* this one is unlocked (so this one is reachable).
    func isPreviousTierUnlocked(_ tier: ProductionTier) -> Bool {
        guard let previous = config.previousTier(of: tier) else { return true }
        return isUnlocked(previous)
    }

    /// Whether the player can unlock this tier now: it's locked, the previous
    /// tier is unlocked (sequential, no skipping), and they can afford the cost.
    func canUnlockTier(_ tier: ProductionTier) -> Bool {
        !isUnlocked(tier)
            && isPreviousTierUnlocked(tier)
            && amount(of: tier.costCurrency) >= tier.unlockCost
    }

    /// Pay a tier's one-time unlock cost. Returns whether it succeeded.
    @discardableResult
    func unlockTier(_ tier: ProductionTier) -> Bool {
        guard canUnlockTier(tier) else { return false }
        guard spend(tier.costCurrency, tier.unlockCost) else { return false }
        unlockedTierIDs.insert(tier.id)
        return true
    }

    /// Cost to buy one more of the given tier.
    func nextCost(for tier: ProductionTier) -> Double {
        tier.cost(forOwnedCount: count(of: tier.id))
    }

    /// Whether the player can afford one more of the given tier right now (and
    /// the tier is unlocked).
    func canAfford(_ tier: ProductionTier) -> Bool {
        isUnlocked(tier) && amount(of: tier.costCurrency) >= nextCost(for: tier)
    }

    /// Output-per-second for a single tier, applying the full multiplier stack
    /// (`MOONLOOM-PROMPT-004`):
    /// `count × baseRate × upgradeMultiplier × globalMultiplier × prestigeMultiplier`.
    func outputPerSecond(forTier tier: ProductionTier) -> Double {
        Double(count(of: tier.id))
            * tier.baseOutputPerSecond
            * buildingMultiplier(for: tier.id)
            * lunarCodexEffects.productionMultiplier(forTierNumber: tier.tier)
            * globalMultiplier
            * prestigeMultiplier
    }

    /// Per-tier output-per-second for every owned, producing tier (used for the
    /// offline per-building breakdown).
    func perTierOutputPerSecond() -> [(tier: ProductionTier, perSecond: Double)] {
        config.tiers.compactMap { tier in
            let rate = outputPerSecond(forTier: tier)
            return rate > 0 ? (tier, rate) : nil
        }
    }

    /// Aggregate output-per-second for a currency across all owned buildings,
    /// before offline penalties.
    func outputPerSecond(of resource: ResourceType) -> Double {
        config.tiers.reduce(0) { partial, tier in
            tier.produces == resource ? partial + outputPerSecond(forTier: tier) : partial
        }
    }

    /// Output-per-second for every resource, keyed by type. Used by the engine
    /// and the offline calculator. Computes the shared global/prestige
    /// multipliers once for efficiency (the hot tick path).
    func outputPerSecondByResource() -> [ResourceType: Double] {
        let global = globalMultiplier
        let prestige = prestigeMultiplier
        let codex = lunarCodexEffects
        var result: [ResourceType: Double] = [:]
        for tier in config.tiers {
            let count = self.count(of: tier.id)
            guard count > 0 else { continue }
            let rate = Double(count)
                * tier.baseOutputPerSecond
                * buildingMultiplier(for: tier.id)
                * codex.productionMultiplier(forTierNumber: tier.tier)
                * global
                * prestige
            result[tier.produces, default: 0] += rate
        }
        return result
    }

    /// Snapshot of current production rates per resource, for UI display.
    /// (`calculateProductionRates()` in the engine API.)
    func calculateProductionRates() -> [ResourceType: Double] {
        outputPerSecondByResource()
    }

    // MARK: - Multipliers

    /// Permanent production multiplier granted by prestige progress. Each Lucid
    /// Shard adds a small permanent boost, plus any Lunar Codex prestige bonus
    /// (Lucid Resonance scales with reset count).
    var prestigeMultiplier: Double {
        1.0 + (totalLucidShardsEarned * 0.02) + lunarCodexEffects.prestigeBonus
    }

    /// Output multiplier for a building from its upgrade level (`1.5^level`).
    func buildingMultiplier(for buildingID: String) -> Double {
        config.upgradeMultiplier(forLevel: upgradeLevel(of: buildingID))
    }

    /// Apply a freshly-evaluated global multiplier from `MilestoneService`.
    func setGlobalMultiplier(_ value: Double) {
        guard value.isFinite, value > 0 else { return }
        globalMultiplier = value
    }

    /// Total number of buildings owned across all tiers.
    var totalBuildingCount: Int {
        buildingCounts.values.reduce(0, +)
    }

    /// Lifetime Moonlight earned (drives milestones).
    var lifetimeMoonlight: Double {
        currencyLifetimeEarned[.moonlight] ?? 0
    }

    /// Lifetime Stardust earned (drives Stardust achievements).
    var lifetimeStardust: Double {
        currencyLifetimeEarned[.stardust] ?? 0
    }

    // MARK: - Lunar Codex (permanent prestige upgrades)

    /// Recompute the cached aggregate Lunar Codex effects. Call after any change
    /// to `lunarCodexLevels` or `resetCount`.
    func recomputeCodexEffects() {
        lunarCodexEffects = LunarCodex.effects(levels: lunarCodexLevels, resetCount: resetCount)
    }

    func codexLevel(of id: String) -> Int { lunarCodexLevels[id] ?? 0 }

    func isCodexMaxed(_ upgrade: LunarCodexUpgrade) -> Bool {
        codexLevel(of: upgrade.id) >= upgrade.maxLevel
    }

    func codexCost(for upgrade: LunarCodexUpgrade) -> Double {
        upgrade.cost(forLevel: codexLevel(of: upgrade.id))
    }

    func canPurchaseCodex(_ upgrade: LunarCodexUpgrade) -> Bool {
        !isCodexMaxed(upgrade) && amount(of: .lucidShards) >= codexCost(for: upgrade)
    }

    /// Buy one level of a Lunar Codex upgrade with Lucid Shards. Returns success.
    @discardableResult
    func purchaseCodexUpgrade(_ upgrade: LunarCodexUpgrade) -> Bool {
        guard canPurchaseCodex(upgrade) else { return false }
        guard spend(.lucidShards, codexCost(for: upgrade)) else { return false }
        lunarCodexLevels[upgrade.id, default: 0] += 1
        recomputeCodexEffects()
        return true
    }

    // MARK: - Achievements

    /// Number of cumulative-Moonlight milestones reached so far.
    var milestonesReached: Int {
        MilestoneCalculator(config: config).reachedCount(lifetimeMoonlight: lifetimeMoonlight)
    }

    func isAchievementUnlocked(_ id: String) -> Bool { unlockedAchievementIDs.contains(id) }

    /// Build the metrics snapshot achievements are evaluated against.
    func achievementContext() -> AchievementContext {
        var perTier: [Int: Int] = [:]
        for tier in config.tiers {
            let owned = count(of: tier.id)
            if owned > 0 { perTier[tier.tier] = owned }
        }
        return AchievementContext(
            lifetimeMoonlight: lifetimeMoonlight,
            moonlightPerSecond: outputPerSecond(of: .moonlight),
            totalBuildings: totalBuildingCount,
            perTierCount: perTier,
            tiersUnlocked: unlockedTiers.count,
            totalUpgradeLevels: upgradeLevels.values.reduce(0, +),
            ordersFulfilled: ordersFulfilled,
            biomesRestored: restoredNodeIDs.count,
            resetCount: resetCount,
            milestonesReached: milestonesReached,
            lifetimeStardust: lifetimeStardust
        )
    }

    /// Unlock any newly-satisfied achievements, granting their Stardust once.
    /// Returns the newly-unlocked achievements for celebration.
    @discardableResult
    func evaluateAchievements() -> [Achievement] {
        let context = achievementContext()
        let newly = AchievementCatalog.newlyUnlocked(context: context, alreadyUnlocked: unlockedAchievementIDs)
        for achievement in newly {
            unlockedAchievementIDs.insert(achievement.id)
            if achievement.stardustReward > 0 {
                credit(.stardust, achievement.stardustReward)
            }
        }
        return newly
    }

    // MARK: - Daily reward

    /// The claim available right now, if any.
    func availableDailyClaim(now: Date, calculator: DailyRewardCalculator) -> DailyRewardCalculator.Claim? {
        calculator.claim(lastClaim: lastDailyClaim, currentStreak: dailyStreak, now: now)
    }

    /// Apply a daily claim: grant Stardust, advance the streak, stamp the date.
    func applyDailyClaim(_ claim: DailyRewardCalculator.Claim, now: Date) {
        credit(.stardust, claim.reward)
        dailyStreak = claim.newStreak
        lastDailyClaim = now
    }

    // MARK: - Entitlements & cosmetics

    /// Credit premium Stardust (e.g. from a consumable IAP).
    func creditStardust(_ amount: Double) {
        credit(.stardust, amount)
    }

    /// Replace the set of active entitlements (from StoreKit reconciliation).
    func setEntitlements(_ productIDs: Set<String>) {
        entitlementProductIDs = productIDs
        applyEntitlementSideEffects()
    }

    /// Add a single entitlement after a purchase completes.
    func grantEntitlement(_ productID: String) {
        entitlementProductIDs.insert(productID)
        applyEntitlementSideEffects()
    }

    func ownsEntitlement(_ productID: String) -> Bool { entitlementProductIDs.contains(productID) }

    /// Theme palette ids the player owns ("default" is always owned).
    var ownedThemeIDs: Set<String> {
        var ids: Set<String> = ["default"]
        for productID in entitlementProductIDs {
            if let theme = ProductCatalog.themeID(for: productID) { ids.insert(theme) }
        }
        return ids
    }

    var ownedMothSkinIDs: Set<String> {
        Set(entitlementProductIDs.compactMap { ProductCatalog.mothSkinID(for: $0) })
    }

    var hasMoonloomPass: Bool { entitlementProductIDs.contains(ProductCatalog.passProductID) }

    /// Offline-earnings multiplier from entitlements (Moonloom Pass → 2×).
    var offlineEntitlementMultiplier: Double {
        entitlementProductIDs.reduce(1.0) { max($0, ProductCatalog.offlineMultiplier(for: $1)) }
    }

    /// Base offline cap from owned convenience products.
    private var entitlementOfflineCapHours: Int {
        entitlementProductIDs.compactMap { ProductCatalog.offlineCapHours(for: $0) }.max()
            ?? config.defaultOfflineCapHours
    }

    /// Effective offline cap: best of (settings cap, entitlement cap) + codex bonus.
    var effectiveOfflineCapHours: Int {
        let base = max(offlineEarningCapHours, entitlementOfflineCapHours)
        return min(base + lunarCodexEffects.offlineCapBonusHours, config.hardOfflineCapHours)
    }

    /// Effective offline efficiency: base + Lunar Codex bonus (clamped below 1).
    var effectiveOfflineEfficiency: Double {
        min(config.offlineEfficiency + lunarCodexEffects.offlineEfficiencyBonus, 0.95)
    }

    /// Select a cosmetic theme the player owns. Returns whether it changed.
    @discardableResult
    func setTheme(_ id: String) -> Bool {
        guard ownedThemeIDs.contains(id), theme != id else { return false }
        theme = id
        return true
    }

    func completeOnboarding() { hasCompletedOnboarding = true }

    /// Apply immediate side effects of owning entitlements: raise the persisted
    /// offline cap to match a convenience purchase, and revert to the default
    /// theme if the current one is no longer owned.
    private func applyEntitlementSideEffects() {
        let entitlementCap = entitlementOfflineCapHours
        if entitlementCap > offlineEarningCapHours {
            offlineEarningCapHours = min(entitlementCap, config.maxOfflineCapHours)
        }
        if !ownedThemeIDs.contains(theme) { theme = "default" }
    }

    // MARK: - Per-building upgrades (levels 1...10)

    /// Current upgrade level for a building (0 if none).
    func upgradeLevel(of buildingID: String) -> Int {
        upgradeLevels[buildingID] ?? 0
    }

    /// Whether a building is already at the maximum upgrade level.
    func isMaxLevel(_ tier: ProductionTier) -> Bool {
        upgradeLevel(of: tier.id) >= config.maxUpgradeLevel
    }

    /// Cost to raise a building to its next upgrade level.
    func upgradeCost(for tier: ProductionTier) -> Double {
        tier.upgradeCost(forLevel: upgradeLevel(of: tier.id), growth: config.upgradeCostGrowth)
    }

    /// Whether the player can upgrade this building now: it's unlocked, below max
    /// level, and affordable.
    func canUpgrade(_ tier: ProductionTier) -> Bool {
        isUnlocked(tier)
            && !isMaxLevel(tier)
            && amount(of: tier.costCurrency) >= upgradeCost(for: tier)
    }

    /// Raise a building's upgrade level by one. Returns whether it succeeded.
    @discardableResult
    func upgradeBuilding(_ tier: ProductionTier) -> Bool {
        guard canUpgrade(tier) else { return false }
        guard spend(tier.costCurrency, upgradeCost(for: tier)) else { return false }
        upgradeLevels[tier.id, default: 0] += 1
        return true
    }

    /// Unlocked buildings that can be upgraded right now (afford + below max).
    func upgradeableTiers() -> [ProductionTier] {
        config.tiers.filter { canUpgrade($0) }
    }

    // MARK: - Dream Orders

    /// The upcoming order board (the first element is the active order).
    var activeOrders: [DreamOrder] {
        orderGenerator.activeBoard(fulfilledCount: ordersFulfilled, size: config.activeOrderCount)
    }

    /// The single order the player can fulfil next.
    var activeOrder: DreamOrder? {
        orderGenerator.order(at: ordersFulfilled)
    }

    /// Whether the active order can be fulfilled with current resources.
    func canFulfill(_ order: DreamOrder) -> Bool {
        order.index == ordersFulfilled && amount(of: order.requestResource) >= order.requestAmount
    }

    /// Fulfil the active order: spend the request, grant the reward, advance the
    /// chain. Returns whether it succeeded.
    @discardableResult
    func fulfillOrder(_ order: DreamOrder) -> Bool {
        guard canFulfill(order) else { return false }
        guard spend(order.requestResource, order.requestAmount) else { return false }
        credit(order.rewardResource, order.rewardAmount)
        ordersFulfilled += 1
        return true
    }

    // MARK: - Mutations

    /// Credit a currency, also tracking lifetime totals.
    func credit(_ resource: ResourceType, _ value: Double) {
        guard value > 0, value.isFinite else { return }
        currencyAmounts[resource, default: 0] += value
        currencyLifetimeEarned[resource, default: 0] += value
    }

    /// Attempt to spend a currency. Returns `false` (and mutates nothing) if the
    /// player cannot afford it.
    @discardableResult
    func spend(_ resource: ResourceType, _ value: Double) -> Bool {
        guard value >= 0, value.isFinite else { return false }
        guard amount(of: resource) >= value else { return false }
        currencyAmounts[resource, default: 0] -= value
        return true
    }

    /// Advance the simulation by `delta` seconds of *active* production.
    /// Called by `ProductionEngine` on the main actor each tick. Production only
    /// accrues currencies; the player spends Moonlight on the Moon Restoration
    /// screen to restore biomes.
    func applyProduction(delta: TimeInterval) {
        guard delta > 0 else { return }
        let perResource = outputPerSecondByResource()
        for (resource, perSecond) in perResource {
            credit(resource, perSecond * delta)
        }
    }

    /// Apply a pre-computed bundle of offline earnings (already penalised and
    /// capped by `OfflineEarningsCalculator`).
    func applyOfflineEarnings(_ earnings: [ResourceType: Double]) {
        for (resource, value) in earnings {
            credit(resource, value)
        }
    }

    // MARK: - Moon restoration

    /// The moon's biomes (from config), in restoration order.
    var restorationNodes: [RestorationNode] {
        config.restorationNodes.sorted { $0.order < $1.order }
    }

    /// Overall moon restoration as a fraction of biomes restored (0...1).
    var moonRestoration: Double {
        let total = config.restorationNodes.count
        return total == 0 ? 0 : Double(restoredNodeIDs.count) / Double(total)
    }

    func isNodeRestored(_ node: RestorationNode) -> Bool {
        restoredNodeIDs.contains(node.id)
    }

    /// The next biome to restore (lowest-order unrestored node), or `nil` when
    /// the moon is fully restored.
    var nextRestorationNode: RestorationNode? {
        config.restorationNodes
            .sorted { $0.order < $1.order }
            .first { !isNodeRestored($0) }
    }

    /// Whether the given node can be restored now (it is next in order and the
    /// player can afford its Moonlight cost).
    func canRestore(_ node: RestorationNode) -> Bool {
        guard nextRestorationNode?.id == node.id else { return false }
        return amount(of: config.restorationCurrency) >= node.cost
    }

    /// Restore a biome by spending Moonlight. Returns whether it succeeded.
    @discardableResult
    func restoreNode(_ node: RestorationNode) -> Bool {
        guard canRestore(node) else { return false }
        guard spend(config.restorationCurrency, node.cost) else { return false }
        restoredNodeIDs.insert(node.id)
        bestRunMoonlightRestored = max(bestRunMoonlightRestored, moonRestoration)
        return true
    }

    /// Whether the player can buy one more of the given tier (engine API alias).
    func canBuyBuilding(_ tier: ProductionTier) -> Bool {
        canAfford(tier)
    }

    /// Purchase one building of the given tier if unlocked and affordable.
    /// Returns whether the purchase succeeded.
    @discardableResult
    func purchaseBuilding(_ tier: ProductionTier) -> Bool {
        guard isUnlocked(tier) else { return false }
        let cost = nextCost(for: tier)
        guard spend(tier.costCurrency, cost) else { return false }
        buildingCounts[tier.id, default: 0] += 1
        return true
    }

    /// Replace the offline cap (e.g. after an upgrade/IAP), clamped to config.
    func setOfflineCapHours(_ hours: Int) {
        offlineEarningCapHours = max(config.defaultOfflineCapHours,
                                     min(hours, config.maxOfflineCapHours))
    }

    /// Apply a completed New Moon Reset (prestige). Soft currencies, buildings
    /// and moon progress reset; Stardust, Lucid Shards and permanent upgrades
    /// are kept. See `TECHNICAL_PRD.md` §6.
    func applyPrestige(shardsEarned: Double) {
        for resource in ResourceType.allCases where resource.isSoftCurrency {
            currencyAmounts[resource] = 0
        }
        buildingCounts = [:]
        upgradeLevels.removeAll()        // building upgrades are run-scoped
        restoredNodeIDs.removeAll()
        // Re-lock all tiers except the first (re-unlock as you progress again).
        unlockedTierIDs = Set(config.tiers.first.map { [$0.id] } ?? [])
        credit(.lucidShards, shardsEarned)
        totalLucidShardsEarned += shardsEarned
        resetCount += 1
        // Lucid Resonance scales with reset count, so refresh codex effects now.
        recomputeCodexEffects()
        if let firstTier = config.tiers.first {
            currencyAmounts[firstTier.costCurrency] =
                config.startingMoonlight + lunarCodexEffects.startingMoonlightBonus
        }
    }

    func updateLastActive(_ date: Date) {
        lastActiveTimestamp = date
    }

    // MARK: - Snapshot projection

    /// Project the current state into a `Codable` snapshot for persistence.
    func snapshot(now: Date) -> GameSnapshot {
        GameSnapshot(
            schemaVersion: 2,
            currencyAmounts: encodeCurrencies(currencyAmounts),
            currencyLifetimeEarned: encodeCurrencies(currencyLifetimeEarned),
            buildingCounts: buildingCounts,
            upgradeLevels: upgradeLevels,
            unlockedTierIDs: Array(unlockedTierIDs),
            ordersFulfilled: ordersFulfilled,
            restoredNodeIDs: Array(restoredNodeIDs),
            resetCount: resetCount,
            totalLucidShardsEarned: totalLucidShardsEarned,
            bestRunMoonlightRestored: bestRunMoonlightRestored,
            permanentUpgradeIDs: Array(permanentUpgradeIDs),
            lunarCodexLevels: lunarCodexLevels,
            unlockedAchievementIDs: Array(unlockedAchievementIDs),
            lastDailyClaim: lastDailyClaim,
            dailyStreak: dailyStreak,
            entitlementProductIDs: Array(entitlementProductIDs),
            hasCompletedOnboarding: hasCompletedOnboarding,
            isMusicEnabled: isMusicEnabled,
            isSFXEnabled: isSFXEnabled,
            isNotificationsEnabled: isNotificationsEnabled,
            offlineEarningCapHours: offlineEarningCapHours,
            theme: theme,
            lastActiveTimestamp: now
        )
    }

    private func encodeCurrencies(_ values: [ResourceType: Double]) -> [String: Double] {
        var result: [String: Double] = [:]
        for (type, value) in values {
            result[type.rawValue] = value
        }
        return result
    }
}
