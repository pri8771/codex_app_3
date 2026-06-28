import Foundation

/// Central, immutable configuration for the Moonloom idle economy.
///
/// All tunable values — tier definitions, cost/growth curves, prestige math,
/// and offline rules — live here so there are no scattered magic numbers in the
/// engine or UI (see `MOONLOOM-PROMPT-001` technical requirements). Later phases
/// tune these values; the engine reads them, never hard-codes them.
struct EconomyConfig: Sendable {

    // MARK: - Starting state

    /// Whispers granted to a brand-new save so the first building is affordable.
    let startingWhispers: Double = 15

    // MARK: - Production tiers (12)

    /// The 12 production tiers in order. Mirrors the README tier table and
    /// `TECHNICAL_PRD.md` §4. For the foundation, intermediate fictional
    /// resources (e.g. "Dream Fabric") are folded into the nearest tracked
    /// currency; the five tracked currencies are defined by `ResourceType`.
    let tiers: [ProductionTier] = [
        ProductionTier(
            id: "whisper_net", tier: 1, name: "Whisper Nets",
            summary: "Catch whispers from sleeping towns.",
            systemImage: "wind", produces: .whispers,
            baseOutputPerSecond: 0.1,
            costCurrency: .whispers, baseCost: 15, costGrowth: 1.15,
            unlockRequirement: 0
        ),
        ProductionTier(
            id: "lullaby_well", tier: 2, name: "Lullaby Wells",
            summary: "Amplify the whispers into a steady stream.",
            systemImage: "drop.fill", produces: .whispers,
            baseOutputPerSecond: 1,
            costCurrency: .whispers, baseCost: 100, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "dreamthread_spindle", tier: 3, name: "Dreamthread Spindles",
            summary: "Spin whispers into dreamthread.",
            systemImage: "scribble.variable", produces: .dreamthread,
            baseOutputPerSecond: 0.5,
            costCurrency: .whispers, baseCost: 1_100, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "memory_loom", tier: 4, name: "Memory Looms",
            summary: "Weave dreamthread into dream fabric.",
            systemImage: "square.grid.3x3.fill", produces: .dreamthread,
            baseOutputPerSecond: 4,
            costCurrency: .dreamthread, baseCost: 12_000, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "nightmare_filter", tier: 5, name: "Nightmare Filters",
            summary: "Purify dreams of their nightmares.",
            systemImage: "camera.filters", produces: .dreamthread,
            baseOutputPerSecond: 26,
            costCurrency: .dreamthread, baseCost: 130_000, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "star_dye_vat", tier: 6, name: "Star Dye Vats",
            summary: "Add starlight value to each dream.",
            systemImage: "paintpalette.fill", produces: .dreamthread,
            baseOutputPerSecond: 140,
            costCurrency: .dreamthread, baseCost: 1_400_000, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "moth_courier_nest", tier: 7, name: "Moth Courier Nests",
            summary: "Send moths to deliver dreams to the moon.",
            systemImage: "ant.fill", produces: .moonlight,
            baseOutputPerSecond: 0.8,
            costCurrency: .dreamthread, baseCost: 20_000_000, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "cloud_packaging_line", tier: 8, name: "Cloud Packaging Line",
            summary: "Package shipments for safe delivery.",
            systemImage: "shippingbox.fill", produces: .moonlight,
            baseOutputPerSecond: 8,
            costCurrency: .moonlight, baseCost: 100_000, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "dream_atlas", tier: 9, name: "Dream Atlas",
            summary: "Map faster delivery routes.",
            systemImage: "map.fill", produces: .moonlight,
            baseOutputPerSecond: 50,
            costCurrency: .moonlight, baseCost: 1_500_000, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "comet_shipping_dock", tier: 10, name: "Comet Shipping Dock",
            summary: "Express deliveries on comet-back.",
            systemImage: "sparkle", produces: .moonlight,
            baseOutputPerSecond: 300,
            costCurrency: .moonlight, baseCost: 25_000_000, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "lucid_observatory", tier: 11, name: "Lucid Observatory",
            summary: "Amplify moonlight at the source.",
            systemImage: "binoculars.fill", produces: .moonlight,
            baseOutputPerSecond: 2_000,
            costCurrency: .moonlight, baseCost: 400_000_000, costGrowth: 1.15,
            unlockRequirement: 1
        ),
        ProductionTier(
            id: "moonheart_engine", tier: 12, name: "Moonheart Engine",
            summary: "Power the moon's restoration itself.",
            systemImage: "moon.stars.fill", produces: .moonlight,
            baseOutputPerSecond: 15_000,
            costCurrency: .moonlight, baseCost: 8_000_000_000, costGrowth: 1.15,
            unlockRequirement: 1
        )
    ]

    /// Convenience lookup of a tier definition by its identifier.
    func tier(id: String) -> ProductionTier? {
        tiers.first { $0.id == id }
    }

    // MARK: - Moon restoration

    /// Total lifetime moonlight required to fully restore the moon (progress
    /// 0.0 → 1.0) within a single run. Foundation value; tuned in later phases.
    let moonlightForFullRestoration: Double = 1_000_000

    // MARK: - Prestige (New Moon Reset) — see TECHNICAL_PRD.md §6

    /// Moon restoration fraction required for the first New Moon Reset.
    let firstPrestigeThreshold: Double = 0.25
    /// Each subsequent reset raises the threshold by this factor (capped at 1.0).
    let prestigeThresholdGrowth: Double = 1.5
    /// Base multiplier in the Lucid Shard formula.
    let prestigeShardMultiplier: Double = 100
    /// Per-reset bonus added to the shard formula's reset bonus term.
    let prestigeResetBonusPerReset: Double = 0.1

    /// Restoration threshold required to perform the `resetCount`-th reset.
    func prestigeThreshold(forResetCount resetCount: Int) -> Double {
        let raised = firstPrestigeThreshold * pow(prestigeThresholdGrowth, Double(max(resetCount, 0)))
        return min(raised, 1.0)
    }

    // MARK: - Offline earnings — see TECHNICAL_PRD.md §5

    /// Default offline earning cap in hours for a new save.
    let defaultOfflineCapHours: Int = 2
    /// Maximum offline cap reachable via upgrades/IAP.
    let maxOfflineCapHours: Int = 48
    /// Efficiency multiplier applied to offline (vs. active) production.
    let offlineEfficiency: Double = 0.5

    /// Production tick interval in seconds (`TECHNICAL_PRD.md` §4).
    let tickInterval: Double = 0.1

    // MARK: - Upgrades (per-building multipliers)

    /// Building counts at which successive upgrades for a tier unlock.
    let upgradeUnlockThresholds: [Int] = [10, 25, 50, 100]
    /// Output multiplier each purchased upgrade applies to its building.
    let upgradeMultiplierBoost: Double = 2.0
    /// Cost scaling for an upgrade relative to its building's base cost.
    let upgradeCostFactor: Double = 12

    /// Every upgrade across all 12 tiers, derived from `tiers` (so all economy
    /// values remain centralised — no scattered literals).
    var upgrades: [Upgrade] {
        tiers.flatMap { tier -> [Upgrade] in
            upgradeUnlockThresholds.enumerated().map { offset, threshold in
                Upgrade(
                    id: "\(tier.id)_mk\(offset + 2)",
                    buildingID: tier.id,
                    name: "\(tier.name) Mk\(offset + 2)",
                    detail: "Doubles \(tier.name) output (requires \(threshold)).",
                    requiredBuildingCount: threshold,
                    cost: tier.baseCost * Double(threshold) * upgradeCostFactor,
                    costCurrency: tier.costCurrency,
                    multiplierBoost: upgradeMultiplierBoost
                )
            }
        }
    }

    func upgrades(forBuilding buildingID: String) -> [Upgrade] {
        upgrades.filter { $0.buildingID == buildingID }
    }

    func upgrade(id: String) -> Upgrade? {
        upgrades.first { $0.id == id }
    }

    // MARK: - Milestones (global multipliers + collection unlocks)

    /// Progression milestones. Building-count milestones reward growing your
    /// factory; the restoration milestone rewards lasting progress.
    var milestones: [Milestone] {
        [
            Milestone(id: "ms_buildings_10", name: "Cottage Industry",
                      detail: "Own 10 buildings.",
                      condition: .totalBuildings(10), globalMultiplierBonus: 0.10),
            Milestone(id: "ms_buildings_25", name: "Dream Workshop",
                      detail: "Own 25 buildings.",
                      condition: .totalBuildings(25), globalMultiplierBonus: 0.15),
            Milestone(id: "ms_buildings_50", name: "Dream Foundry",
                      detail: "Own 50 buildings.",
                      condition: .totalBuildings(50), globalMultiplierBonus: 0.25),
            Milestone(id: "ms_spindle_1", name: "First Thread",
                      detail: "Spin your first Dreamthread Spindle.",
                      condition: .buildingCount(buildingID: "dreamthread_spindle", count: 1),
                      globalMultiplierBonus: 0.10),
            Milestone(id: "ms_moonlight_1k", name: "Glimmer",
                      detail: "Earn 1K lifetime Moonlight.",
                      condition: .lifetimeEarned(.moonlight, 1_000), globalMultiplierBonus: 0.20),
            Milestone(id: "ms_restore_25", name: "Crescent",
                      detail: "Restore the moon to 25%.",
                      condition: .moonRestoration(0.25), globalMultiplierBonus: 0.25)
        ]
    }

    // MARK: - Dream Orders

    /// Number of upcoming orders shown on the board at once.
    let activeOrderCount: Int = 3
    /// Request amount for the first order.
    let orderBaseAmount: Double = 50
    /// Exponential growth of successive order request amounts.
    let orderAmountGrowth: Double = 1.8
    /// Stardust reward for the first order.
    let orderBaseReward: Double = 3
    /// Additional Stardust reward per successive order.
    let orderRewardStep: Double = 2
    /// Which resource each order requests, cycling by order index.
    let orderRequestCycle: [ResourceType] = [.whispers, .whispers, .dreamthread, .moonlight]
}
