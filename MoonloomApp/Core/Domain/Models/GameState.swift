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

    /// Cached upgrade definitions grouped by building, built once from `config`
    /// so the hot production path avoids rebuilding the upgrade catalog.
    private let upgradesByBuilding: [String: [Upgrade]]
    /// Deterministic generator for the Dream Order chain.
    private let orderGenerator: OrderGenerator

    // MARK: - Currencies
    @Published private(set) var currencyAmounts: [ResourceType: Double]
    @Published private(set) var currencyLifetimeEarned: [ResourceType: Double]

    // MARK: - Buildings & upgrades
    @Published private(set) var buildingCounts: [String: Int]
    @Published private(set) var purchasedUpgradeIDs: Set<String>

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
        self.upgradesByBuilding = Dictionary(grouping: config.upgrades, by: \.buildingID)
        self.orderGenerator = OrderGenerator(config: config)
        self.currencyAmounts = Self.decodeCurrencies(snapshot.currencyAmounts)
        self.currencyLifetimeEarned = Self.decodeCurrencies(snapshot.currencyLifetimeEarned)
        self.buildingCounts = snapshot.buildingCounts
        self.purchasedUpgradeIDs = Set(snapshot.purchasedUpgradeIDs)
        self.ordersFulfilled = snapshot.ordersFulfilled
        self.restoredNodeIDs = Set(snapshot.restoredNodeIDs)
        self.resetCount = snapshot.resetCount
        self.totalLucidShardsEarned = snapshot.totalLucidShardsEarned
        self.bestRunMoonlightRestored = snapshot.bestRunMoonlightRestored
        self.permanentUpgradeIDs = Set(snapshot.permanentUpgradeIDs)
        self.isMusicEnabled = snapshot.isMusicEnabled
        self.isSFXEnabled = snapshot.isSFXEnabled
        self.isNotificationsEnabled = snapshot.isNotificationsEnabled
        self.offlineEarningCapHours = snapshot.offlineEarningCapHours
        self.theme = snapshot.theme
        self.lastActiveTimestamp = snapshot.lastActiveTimestamp
    }

    /// Overwrite all state from a snapshot in place (used after the async load
    /// at launch, so the observed `GameState` instance stays stable and the view
    /// tree is not torn down).
    func restore(from snapshot: GameSnapshot) {
        currencyAmounts = Self.decodeCurrencies(snapshot.currencyAmounts)
        currencyLifetimeEarned = Self.decodeCurrencies(snapshot.currencyLifetimeEarned)
        buildingCounts = snapshot.buildingCounts
        purchasedUpgradeIDs = Set(snapshot.purchasedUpgradeIDs)
        ordersFulfilled = snapshot.ordersFulfilled
        restoredNodeIDs = Set(snapshot.restoredNodeIDs)
        resetCount = snapshot.resetCount
        totalLucidShardsEarned = snapshot.totalLucidShardsEarned
        bestRunMoonlightRestored = snapshot.bestRunMoonlightRestored
        permanentUpgradeIDs = Set(snapshot.permanentUpgradeIDs)
        isMusicEnabled = snapshot.isMusicEnabled
        isSFXEnabled = snapshot.isSFXEnabled
        isNotificationsEnabled = snapshot.isNotificationsEnabled
        offlineEarningCapHours = snapshot.offlineEarningCapHours
        theme = snapshot.theme
        lastActiveTimestamp = snapshot.lastActiveTimestamp
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

    /// Tiers that are currently visible/unlocked to the player. A tier unlocks
    /// once the player owns at least `unlockRequirement` of the previous tier.
    var unlockedTiers: [ProductionTier] {
        config.tiers.filter { isUnlocked($0) }
    }

    /// Whether a tier is unlocked given current building counts.
    func isUnlocked(_ tier: ProductionTier) -> Bool {
        guard tier.tier > 1 else { return true }
        let previous = config.tiers.first { $0.tier == tier.tier - 1 }
        guard let previous else { return true }
        return count(of: previous.id) >= tier.unlockRequirement
    }

    /// Cost to buy one more of the given tier.
    func nextCost(for tier: ProductionTier) -> Double {
        tier.cost(forOwnedCount: count(of: tier.id))
    }

    /// Whether the player can afford one more of the given tier right now.
    func canAfford(_ tier: ProductionTier) -> Bool {
        amount(of: tier.costCurrency) >= nextCost(for: tier)
    }

    /// Output-per-second for a single tier, applying the full documented
    /// multiplier stack (`TECHNICAL_PRD.md` §4 / `MOONLOOM-PROMPT-002`):
    /// `count × baseCPS × upgradeMultiplier × globalMultiplier × prestigeMultiplier`.
    func outputPerSecond(forTier tier: ProductionTier) -> Double {
        Double(count(of: tier.id))
            * tier.baseOutputPerSecond
            * buildingMultiplier(for: tier.id)
            * globalMultiplier
            * prestigeMultiplier
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
        var result: [ResourceType: Double] = [:]
        for tier in config.tiers {
            let count = self.count(of: tier.id)
            guard count > 0 else { continue }
            let rate = Double(count)
                * tier.baseOutputPerSecond
                * buildingMultiplier(for: tier.id)
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
    /// Shard adds a small permanent boost (foundation value; tuned later).
    var prestigeMultiplier: Double {
        1.0 + (totalLucidShardsEarned * 0.02)
    }

    /// Product of all purchased upgrades' boosts for a building (1.0 if none).
    func buildingMultiplier(for buildingID: String) -> Double {
        guard let upgrades = upgradesByBuilding[buildingID] else { return 1 }
        return upgrades.reduce(1) { product, upgrade in
            purchasedUpgradeIDs.contains(upgrade.id) ? product * upgrade.multiplierBoost : product
        }
    }

    /// Global production multiplier from achieved milestones (1.0 + Σ bonuses).
    var globalMultiplier: Double {
        1.0 + config.milestones.reduce(0) { sum, milestone in
            isAchieved(milestone) ? sum + milestone.globalMultiplierBonus : sum
        }
    }

    /// Total number of buildings owned across all tiers.
    var totalBuildingCount: Int {
        buildingCounts.values.reduce(0, +)
    }

    // MARK: - Milestones

    /// Whether a milestone's condition is currently satisfied.
    func isAchieved(_ milestone: Milestone) -> Bool {
        switch milestone.condition {
        case .totalBuildings(let n):
            return totalBuildingCount >= n
        case .buildingCount(let buildingID, let n):
            return count(of: buildingID) >= n
        case .moonRestoration(let fraction):
            return moonRestoration >= fraction
        case .lifetimeEarned(let resource, let value):
            return (currencyLifetimeEarned[resource] ?? 0) >= value
        }
    }

    /// All currently-achieved milestones.
    var achievedMilestones: [Milestone] {
        config.milestones.filter(isAchieved)
    }

    // MARK: - Upgrades

    /// Whether a building owns enough copies to reveal this upgrade.
    func isUpgradeUnlocked(_ upgrade: Upgrade) -> Bool {
        count(of: upgrade.buildingID) >= upgrade.requiredBuildingCount
    }

    func isUpgradePurchased(_ upgrade: Upgrade) -> Bool {
        purchasedUpgradeIDs.contains(upgrade.id)
    }

    /// Unlocked, unpurchased, and currently affordable.
    func canBuyUpgrade(_ upgrade: Upgrade) -> Bool {
        isUpgradeUnlocked(upgrade)
            && !isUpgradePurchased(upgrade)
            && amount(of: upgrade.costCurrency) >= upgrade.cost
    }

    /// Unlocked but not yet purchased (the engine API `getAvailableUpgrades()`).
    func availableUpgrades() -> [Upgrade] {
        config.upgrades.filter { isUpgradeUnlocked($0) && !isUpgradePurchased($0) }
    }

    /// Available upgrades the player can afford right now.
    func affordableUpgrades() -> [Upgrade] {
        availableUpgrades().filter { amount(of: $0.costCurrency) >= $0.cost }
    }

    /// Purchase an upgrade if affordable. Returns whether it succeeded.
    @discardableResult
    func purchaseUpgrade(_ upgrade: Upgrade) -> Bool {
        guard canBuyUpgrade(upgrade) else { return false }
        guard spend(upgrade.costCurrency, upgrade.cost) else { return false }
        purchasedUpgradeIDs.insert(upgrade.id)
        return true
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

    /// Purchase one building of the given tier if affordable. Returns whether
    /// the purchase succeeded.
    @discardableResult
    func purchaseBuilding(_ tier: ProductionTier) -> Bool {
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
        purchasedUpgradeIDs.removeAll()  // building upgrades are run-scoped
        restoredNodeIDs.removeAll()
        credit(.lucidShards, shardsEarned)
        totalLucidShardsEarned += shardsEarned
        resetCount += 1
        currencyAmounts[.whispers] = config.startingWhispers
    }

    func updateLastActive(_ date: Date) {
        lastActiveTimestamp = date
    }

    // MARK: - Snapshot projection

    /// Project the current state into a `Codable` snapshot for persistence.
    func snapshot(now: Date) -> GameSnapshot {
        GameSnapshot(
            schemaVersion: 1,
            currencyAmounts: encodeCurrencies(currencyAmounts),
            currencyLifetimeEarned: encodeCurrencies(currencyLifetimeEarned),
            buildingCounts: buildingCounts,
            purchasedUpgradeIDs: Array(purchasedUpgradeIDs),
            ordersFulfilled: ordersFulfilled,
            restoredNodeIDs: Array(restoredNodeIDs),
            resetCount: resetCount,
            totalLucidShardsEarned: totalLucidShardsEarned,
            bestRunMoonlightRestored: bestRunMoonlightRestored,
            permanentUpgradeIDs: Array(permanentUpgradeIDs),
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
