import Foundation

/// A single permanent upgrade in the Lunar Codex, bought with Lucid Shards and
/// kept across every New Moon Reset (MOONLOOM-PROMPT-005). Levels stack.
struct LunarCodexUpgrade: Identifiable, Sendable, Hashable {
    let id: String
    let name: String
    let detail: String
    let systemImage: String
    let maxLevel: Int
    /// Lucid Shard cost of the first level.
    let baseCost: Double
    /// Exponential growth of the cost per level.
    let costGrowth: Double
    let effect: Effect

    /// What an upgrade does, scaled by its level.
    enum Effect: Sendable, Hashable {
        /// Multiplicative production bonus to *all* tiers: `+perLevel` each level.
        case allProduction(perLevel: Double)
        /// Multiplicative bonus to tiers whose number is in `range`.
        case tierRangeProduction(lower: Int, upper: Int, perLevel: Double)
        /// Adds whole hours to the offline cap.
        case offlineCapHours(perLevel: Int)
        /// Adds to the offline efficiency fraction (e.g. 0.05 = +5%).
        case offlineEfficiency(perLevel: Double)
        /// Adds `perLevel × resetCount` to the prestige multiplier (scales as you
        /// reset more — "Lucid Resonance").
        case prestigePerReset(perLevel: Double)
        /// Adds starting Moonlight granted after each New Moon Reset.
        case startingMoonlight(perLevel: Double)
    }

    /// Cost to raise this upgrade from `currentLevel` to `currentLevel + 1`.
    func cost(forLevel currentLevel: Int) -> Double {
        baseCost * pow(costGrowth, Double(max(0, currentLevel)))
    }
}

/// The aggregated, level-scaled effects of the player's owned Lunar Codex
/// upgrades. Computed once and read in the hot production path.
struct LunarCodexEffects: Sendable, Equatable {
    var allProductionMultiplier: Double = 1.0
    /// (lower, upper, multiplier) bonuses applied per tier number.
    var tierRangeMultipliers: [TierRangeBonus] = []
    var offlineCapBonusHours: Int = 0
    var offlineEfficiencyBonus: Double = 0
    var prestigeBonus: Double = 0
    var startingMoonlightBonus: Double = 0

    struct TierRangeBonus: Sendable, Equatable {
        let lower: Int
        let upper: Int
        let multiplier: Double
    }

    /// Total production multiplier for a tier with the given tier number.
    func productionMultiplier(forTierNumber n: Int) -> Double {
        var m = allProductionMultiplier
        for bonus in tierRangeMultipliers where n >= bonus.lower && n <= bonus.upper {
            m *= bonus.multiplier
        }
        return m
    }
}

/// The Lunar Codex permanent-upgrade tree (10 upgrades) and the pure math that
/// turns owned levels into `LunarCodexEffects`. Kept stateless for testability.
struct LunarCodex: Sendable {

    /// All permanent upgrades, in display order.
    static let upgrades: [LunarCodexUpgrade] = [
        LunarCodexUpgrade(
            id: "dream_efficiency", name: "Dream Efficiency",
            detail: "+10% to all production per level.",
            systemImage: "wand.and.stars", maxLevel: 10,
            baseCost: 4, costGrowth: 1.55,
            effect: .allProduction(perLevel: 0.10)),
        LunarCodexUpgrade(
            id: "whisper_attunement", name: "Whisper Attunement",
            detail: "+20% to early tiers (1–3) per level.",
            systemImage: "wind", maxLevel: 5,
            baseCost: 3, costGrowth: 1.7,
            effect: .tierRangeProduction(lower: 1, upper: 3, perLevel: 0.20)),
        LunarCodexUpgrade(
            id: "dreamthread_mastery", name: "Dreamthread Mastery",
            detail: "+20% to mid tiers (4–6) per level.",
            systemImage: "scribble.variable", maxLevel: 5,
            baseCost: 8, costGrowth: 1.7,
            effect: .tierRangeProduction(lower: 4, upper: 6, perLevel: 0.20)),
        LunarCodexUpgrade(
            id: "courier_network", name: "Courier Network",
            detail: "+25% to delivery tiers (7–9) per level.",
            systemImage: "shippingbox.fill", maxLevel: 5,
            baseCost: 15, costGrowth: 1.75,
            effect: .tierRangeProduction(lower: 7, upper: 9, perLevel: 0.25)),
        LunarCodexUpgrade(
            id: "moonheart_surge", name: "Moonheart Surge",
            detail: "+30% to the final tiers (10–12) per level.",
            systemImage: "moon.stars.fill", maxLevel: 5,
            baseCost: 30, costGrowth: 1.8,
            effect: .tierRangeProduction(lower: 10, upper: 12, perLevel: 0.30)),
        LunarCodexUpgrade(
            id: "lunar_reservoir", name: "Lunar Reservoir",
            detail: "+4h offline cap per level.",
            systemImage: "clock.badge.checkmark", maxLevel: 6,
            baseCost: 10, costGrowth: 1.6,
            effect: .offlineCapHours(perLevel: 4)),
        LunarCodexUpgrade(
            id: "eternal_loom", name: "Eternal Loom",
            detail: "+5% offline efficiency per level.",
            systemImage: "infinity", maxLevel: 4,
            baseCost: 12, costGrowth: 1.8,
            effect: .offlineEfficiency(perLevel: 0.05)),
        LunarCodexUpgrade(
            id: "lucid_resonance", name: "Lucid Resonance",
            detail: "+2% production per past reset, per level.",
            systemImage: "sparkles", maxLevel: 10,
            baseCost: 20, costGrowth: 1.5,
            effect: .prestigePerReset(perLevel: 0.02)),
        LunarCodexUpgrade(
            id: "new_moon_blessing", name: "New Moon Blessing",
            detail: "Start each run with +100 Moonlight per level.",
            systemImage: "moonphase.new.moon", maxLevel: 5,
            baseCost: 5, costGrowth: 1.7,
            effect: .startingMoonlight(perLevel: 100)),
        LunarCodexUpgrade(
            id: "deep_efficiency", name: "Deep Dream Efficiency",
            detail: "+25% to all production per level.",
            systemImage: "burst.fill", maxLevel: 5,
            baseCost: 60, costGrowth: 1.9,
            effect: .allProduction(perLevel: 0.25))
    ]

    static func upgrade(id: String) -> LunarCodexUpgrade? {
        upgrades.first { $0.id == id }
    }

    /// Aggregate the level-scaled effects of all owned upgrades.
    /// - Parameters:
    ///   - levels: upgrade id → owned level.
    ///   - resetCount: used by `prestigePerReset` effects.
    static func effects(levels: [String: Int], resetCount: Int) -> LunarCodexEffects {
        var effects = LunarCodexEffects()
        var allProductionBonus = 0.0
        for upgrade in upgrades {
            let level = max(0, min(levels[upgrade.id] ?? 0, upgrade.maxLevel))
            guard level > 0 else { continue }
            switch upgrade.effect {
            case .allProduction(let perLevel):
                allProductionBonus += perLevel * Double(level)
            case .tierRangeProduction(let lower, let upper, let perLevel):
                effects.tierRangeMultipliers.append(.init(
                    lower: lower, upper: upper, multiplier: 1 + perLevel * Double(level)))
            case .offlineCapHours(let perLevel):
                effects.offlineCapBonusHours += perLevel * level
            case .offlineEfficiency(let perLevel):
                effects.offlineEfficiencyBonus += perLevel * Double(level)
            case .prestigePerReset(let perLevel):
                effects.prestigeBonus += perLevel * Double(level) * Double(max(0, resetCount))
            case .startingMoonlight(let perLevel):
                effects.startingMoonlightBonus += perLevel * Double(level)
            }
        }
        effects.allProductionMultiplier = 1 + allProductionBonus
        return effects
    }
}
