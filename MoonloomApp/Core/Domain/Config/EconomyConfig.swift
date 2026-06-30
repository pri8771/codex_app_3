import Foundation

/// Central, immutable configuration for the Moonloom idle economy.
///
/// All tunable values — tier definitions, cost/growth curves, prestige math,
/// and offline rules — live here so there are no scattered magic numbers in the
/// engine or UI (see `MOONLOOM-PROMPT-001`/`-004`).
///
/// **MOONLOOM-PROMPT-004 economy model:** per the Phase 4 brief ("Moonlight
/// unlock costs", "no building produces 0 Moonlight", per-building Moonlight
/// breakdown), all 12 tiers produce **Moonlight**, and unlock/buy/upgrade costs
/// and milestone thresholds are all denominated in Moonlight. This is a
/// deliberate, documented divergence from the PRD's multi-currency chain, made
/// to implement the written spec exactly (the canonical tier *names* from the
/// README are kept; Stardust still comes from orders, Lucid Shards from prestige).
struct EconomyConfig: Sendable {

    // MARK: - Starting state

    /// Moonlight granted to a brand-new save so the first building is affordable.
    let startingMoonlight: Double = 15

    // MARK: - Production tiers (12) — all produce Moonlight

    /// The 12 production tiers in order (canonical README names). Each has an
    /// explicit Moonlight unlock cost, per-unit buy cost, base production rate,
    /// and base upgrade cost — all fully specified here.
    let tiers: [ProductionTier] = [
        ProductionTier(
            id: "whisper_net", tier: 1, name: "Whisper Nets",
            summary: "Catch whispers from sleeping towns.",
            systemImage: "wind", produces: .moonlight,
            baseOutputPerSecond: 0.1,
            costCurrency: .moonlight, baseCost: 10, costGrowth: 1.15,
            unlockRequirement: 0, unlockCost: 0, baseUpgradeCost: 50
        ),
        ProductionTier(
            id: "lullaby_well", tier: 2, name: "Lullaby Wells",
            summary: "Amplify the whispers into a steady stream.",
            systemImage: "drop.fill", produces: .moonlight,
            baseOutputPerSecond: 1,
            costCurrency: .moonlight, baseCost: 120, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 100, baseUpgradeCost: 600
        ),
        ProductionTier(
            id: "dreamthread_spindle", tier: 3, name: "Dreamthread Spindles",
            summary: "Spin whispers into dreamthread.",
            systemImage: "scribble.variable", produces: .moonlight,
            baseOutputPerSecond: 8,
            costCurrency: .moonlight, baseCost: 1_500, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 1_200, baseUpgradeCost: 7_500
        ),
        ProductionTier(
            id: "memory_loom", tier: 4, name: "Memory Looms",
            summary: "Weave dreamthread into dream fabric.",
            systemImage: "square.grid.3x3.fill", produces: .moonlight,
            baseOutputPerSecond: 60,
            costCurrency: .moonlight, baseCost: 18_000, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 15_000, baseUpgradeCost: 90_000
        ),
        ProductionTier(
            id: "nightmare_filter", tier: 5, name: "Nightmare Filters",
            summary: "Purify dreams of their nightmares.",
            systemImage: "camera.filters", produces: .moonlight,
            baseOutputPerSecond: 450,
            costCurrency: .moonlight, baseCost: 200_000, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 180_000, baseUpgradeCost: 1_000_000
        ),
        ProductionTier(
            id: "star_dye_vat", tier: 6, name: "Star Dye Vats",
            summary: "Add starlight value to each dream.",
            systemImage: "paintpalette.fill", produces: .moonlight,
            baseOutputPerSecond: 3_000,
            costCurrency: .moonlight, baseCost: 2_500_000, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 2_200_000, baseUpgradeCost: 12_000_000
        ),
        ProductionTier(
            id: "moth_courier_nest", tier: 7, name: "Moth Courier Nests",
            summary: "Send moths to deliver dreams to the moon.",
            systemImage: "ant.fill", produces: .moonlight,
            baseOutputPerSecond: 20_000,
            costCurrency: .moonlight, baseCost: 30_000_000, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 28_000_000, baseUpgradeCost: 150_000_000
        ),
        ProductionTier(
            id: "cloud_packaging_line", tier: 8, name: "Cloud Packaging Line",
            summary: "Package shipments for safe delivery.",
            systemImage: "shippingbox.fill", produces: .moonlight,
            baseOutputPerSecond: 150_000,
            costCurrency: .moonlight, baseCost: 400_000_000, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 380_000_000, baseUpgradeCost: 2_000_000_000
        ),
        ProductionTier(
            id: "dream_atlas", tier: 9, name: "Dream Atlas",
            summary: "Map faster delivery routes.",
            systemImage: "map.fill", produces: .moonlight,
            baseOutputPerSecond: 1_000_000,
            costCurrency: .moonlight, baseCost: 5_000_000_000, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 4_800_000_000, baseUpgradeCost: 25_000_000_000
        ),
        ProductionTier(
            id: "comet_shipping_dock", tier: 10, name: "Comet Shipping Dock",
            summary: "Express deliveries on comet-back.",
            systemImage: "sparkle", produces: .moonlight,
            baseOutputPerSecond: 7_500_000,
            costCurrency: .moonlight, baseCost: 65_000_000_000, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 62_000_000_000, baseUpgradeCost: 300_000_000_000
        ),
        ProductionTier(
            id: "lucid_observatory", tier: 11, name: "Lucid Observatory",
            summary: "Amplify moonlight at the source.",
            systemImage: "binoculars.fill", produces: .moonlight,
            baseOutputPerSecond: 50_000_000,
            costCurrency: .moonlight, baseCost: 800_000_000_000, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 780_000_000_000, baseUpgradeCost: 4_000_000_000_000
        ),
        ProductionTier(
            id: "moonheart_engine", tier: 12, name: "Moonheart Engine",
            summary: "Power the moon's restoration itself.",
            systemImage: "moon.stars.fill", produces: .moonlight,
            baseOutputPerSecond: 350_000_000,
            costCurrency: .moonlight, baseCost: 10_000_000_000_000, costGrowth: 1.15,
            unlockRequirement: 1, unlockCost: 9_500_000_000_000, baseUpgradeCost: 50_000_000_000_000
        )
    ]

    /// Convenience lookup of a tier definition by its identifier.
    func tier(id: String) -> ProductionTier? {
        tiers.first { $0.id == id }
    }

    /// The tier immediately before `tier` in unlock order, if any.
    func previousTier(of tier: ProductionTier) -> ProductionTier? {
        tiers.first { $0.tier == tier.tier - 1 }
    }

    // MARK: - Per-building upgrades (levels 1...10)

    /// Maximum upgrade level per building.
    let maxUpgradeLevel: Int = 10
    /// Output multiplier each upgrade level applies (stacking): `1.5^level`.
    let upgradeMultiplierPerLevel: Double = 1.5
    /// Exponential growth of upgrade cost per level: `baseUpgradeCost * 1.8^level`.
    let upgradeCostGrowth: Double = 1.8

    /// Output multiplier for a building at the given upgrade level.
    func upgradeMultiplier(forLevel level: Int) -> Double {
        pow(upgradeMultiplierPerLevel, Double(max(0, level)))
    }

    // MARK: - Milestones (global multiplier from cumulative Moonlight)

    /// Cumulative lifetime-Moonlight thresholds. Each crossed threshold grants a
    /// permanent global multiplier bonus.
    let milestoneMoonlightThresholds: [Double] = [
        1_000, 10_000, 100_000, 1_000_000, 10_000_000, 100_000_000,
        1_000_000_000, 10_000_000_000, 100_000_000_000, 1_000_000_000_000
    ]
    /// Global multiplier bonus per milestone reached (+10%).
    let milestoneBonusPerMilestone: Double = 0.10
    /// Safety cap on the total global multiplier (never exceeds 5×).
    let maxGlobalMultiplier: Double = 5.0

    // MARK: - Moon restoration (biome nodes)

    /// Currency spent to restore the moon's biomes (Moonlight).
    let restorationCurrency: ResourceType = .moonlight

    /// The moon's biomes, restored in order by spending Moonlight. Restoring a
    /// node advances overall moon restoration and reveals a story beat.
    let restorationNodes: [RestorationNode] = [
        RestorationNode(id: "biome_tranquil_sea", order: 1, name: "The Tranquil Sea",
                        story: "The first silver light returns to the Tranquil Sea. Somewhere, a child sleeps soundly again.",
                        cost: 500),
        RestorationNode(id: "biome_whispering_craters", order: 2, name: "Whispering Craters",
                        story: "The craters fill with soft glow, and the old whispers find their echo.",
                        cost: 2_500),
        RestorationNode(id: "biome_lullaby_highlands", order: 3, name: "Lullaby Highlands",
                        story: "Across the highlands, forgotten lullabies hum themselves back into being.",
                        cost: 12_000),
        RestorationNode(id: "biome_dreaming_maria", order: 4, name: "The Dreaming Maria",
                        story: "The great dark seas brighten; dreamers below sail them once more.",
                        cost: 60_000),
        RestorationNode(id: "biome_mothlight_gardens", order: 5, name: "Mothlight Gardens",
                        story: "Gardens of light bloom where the moth couriers first learned to fly.",
                        cost: 300_000),
        RestorationNode(id: "biome_lucid_pole", order: 6, name: "The Lucid Pole",
                        story: "At the pole, the moon remembers how to dream of itself.",
                        cost: 1_500_000),
        RestorationNode(id: "biome_sea_of_returning", order: 7, name: "Sea of Returning Dreams",
                        story: "Every dream ever lost washes gently back onto a glowing shore.",
                        cost: 8_000_000),
        RestorationNode(id: "biome_moonheart_summit", order: 8, name: "The Moonheart Summit",
                        story: "The summit blazes. The moon is whole — and the world below dreams in full color.",
                        cost: 40_000_000)
    ]

    func restorationNode(id: String) -> RestorationNode? {
        restorationNodes.first { $0.id == id }
    }

    /// Total Moonlight to fully restore the moon (sum of all node costs).
    var totalRestorationCost: Double {
        restorationNodes.reduce(0) { $0 + $1.cost }
    }

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

    // MARK: - Offline earnings — see TECHNICAL_PRD.md §5 / MOONLOOM-PROMPT-004

    /// Default offline earning cap in hours for a new save.
    let defaultOfflineCapHours: Int = 2
    /// Offline cap after the Offline Expansion (Phase 4 spec: 12h).
    let expandedOfflineCapHours: Int = 12
    /// Maximum offline cap reachable from settings/entitlements (Moonloom Pass).
    let maxOfflineCapHours: Int = 48
    /// Hard ceiling on the *effective* offline cap once Lunar Codex bonuses stack.
    let hardOfflineCapHours: Int = 96
    /// Efficiency multiplier applied to offline (vs. active) production.
    let offlineEfficiency: Double = 0.5

    /// Production tick interval in seconds (`TECHNICAL_PRD.md` §4).
    let tickInterval: Double = 0.1

    /// Cadence of the gentle "production pulse" sound feedback, so it fires at a
    /// cozy heartbeat rather than on every 0.1s tick.
    let productionPulseInterval: Double = 1.0

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
    /// Which resource each order requests, cycling by order index. All orders
    /// request Moonlight (the production currency); rewards are Stardust.
    let orderRequestCycle: [ResourceType] = [.moonlight]

    // MARK: - Daily login reward (MOONLOOM-PROMPT-007)

    /// Stardust granted by streak day (index 0 = day 1); plateaus at the last value.
    let dailyRewardSchedule: [Double] = [5, 7, 9, 12, 15, 18, 20]
}
