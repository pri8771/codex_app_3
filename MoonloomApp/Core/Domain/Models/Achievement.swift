import Foundation

/// A single achievement (MOONLOOM-PROMPT-007). Unlocking grants Stardust once.
struct Achievement: Identifiable, Sendable, Hashable {
    let id: String
    let name: String
    let detail: String
    let systemImage: String
    let category: Category
    /// Stardust granted the first time it unlocks.
    let stardustReward: Double
    let condition: Condition

    enum Category: String, Sendable, CaseIterable {
        case production = "Production"
        case factory = "Factory"
        case restoration = "Restoration"
        case prestige = "Prestige"
        case orders = "Orders"
    }

    /// A threshold condition evaluated against an `AchievementContext`.
    enum Condition: Sendable, Hashable {
        case lifetimeMoonlight(Double)
        case moonlightPerSecond(Double)
        case totalBuildings(Int)
        case tierCount(tier: Int, count: Int)
        case tiersUnlocked(Int)
        case totalUpgradeLevels(Int)
        case ordersFulfilled(Int)
        case biomesRestored(Int)
        case resets(Int)
        case milestonesReached(Int)
        case lifetimeStardust(Double)
    }
}

/// Snapshot of the metrics achievements are evaluated against.
struct AchievementContext: Sendable {
    var lifetimeMoonlight: Double
    var moonlightPerSecond: Double
    var totalBuildings: Int
    var perTierCount: [Int: Int]   // tier number → count
    var tiersUnlocked: Int
    var totalUpgradeLevels: Int
    var ordersFulfilled: Int
    var biomesRestored: Int
    var resetCount: Int
    var milestonesReached: Int
    var lifetimeStardust: Double

    func satisfies(_ condition: Achievement.Condition) -> Bool {
        switch condition {
        case .lifetimeMoonlight(let v): return lifetimeMoonlight >= v
        case .moonlightPerSecond(let v): return moonlightPerSecond >= v
        case .totalBuildings(let v): return totalBuildings >= v
        case .tierCount(let tier, let v): return (perTierCount[tier] ?? 0) >= v
        case .tiersUnlocked(let v): return tiersUnlocked >= v
        case .totalUpgradeLevels(let v): return totalUpgradeLevels >= v
        case .ordersFulfilled(let v): return ordersFulfilled >= v
        case .biomesRestored(let v): return biomesRestored >= v
        case .resets(let v): return resetCount >= v
        case .milestonesReached(let v): return milestonesReached >= v
        case .lifetimeStardust(let v): return lifetimeStardust >= v
        }
    }
}

/// The achievement catalog and the pure evaluator that reports newly-satisfied
/// achievements. Stateless and deterministic for testing.
enum AchievementCatalog {

    static let all: [Achievement] = [
        // Production — lifetime Moonlight
        ach("first_light", "First Light", "Earn your first 1,000 Moonlight.", "sparkle", .production, 5, .lifetimeMoonlight(1_000)),
        ach("moon_glow", "Moon Glow", "Earn 100,000 lifetime Moonlight.", "sparkles", .production, 8, .lifetimeMoonlight(100_000)),
        ach("silver_tide", "Silver Tide", "Earn 10 million lifetime Moonlight.", "moon.fill", .production, 12, .lifetimeMoonlight(10_000_000)),
        ach("lunar_fortune", "Lunar Fortune", "Earn 1 billion lifetime Moonlight.", "moon.stars.fill", .production, 20, .lifetimeMoonlight(1_000_000_000)),
        ach("moonfall", "Moonfall", "Earn 100 billion lifetime Moonlight.", "moon.haze.fill", .production, 30, .lifetimeMoonlight(100_000_000_000)),
        ach("trillion_dreams", "Trillion Dreams", "Earn 1 trillion lifetime Moonlight.", "moon.circle.fill", .production, 50, .lifetimeMoonlight(1_000_000_000_000)),
        // Production rate
        ach("steady_loom", "Steady Loom", "Reach 1,000 Moonlight/sec.", "gauge.with.dots.needle.50percent", .production, 8, .moonlightPerSecond(1_000)),
        ach("dream_torrent", "Dream Torrent", "Reach 1 million Moonlight/sec.", "gauge.with.dots.needle.67percent", .production, 18, .moonlightPerSecond(1_000_000)),
        ach("river_of_light", "River of Light", "Reach 1 billion Moonlight/sec.", "gauge.with.dots.needle.100percent", .production, 35, .moonlightPerSecond(1_000_000_000)),
        // Factory — buildings
        ach("ground_broken", "Ground Broken", "Build your first 10 buildings.", "hammer.fill", .factory, 5, .totalBuildings(10)),
        ach("busy_factory", "Busy Factory", "Own 50 buildings.", "building.2.fill", .factory, 8, .totalBuildings(50)),
        ach("dream_works", "Dream Works", "Own 100 buildings.", "building.columns.fill", .factory, 12, .totalBuildings(100)),
        ach("grand_loom", "Grand Loom", "Own 250 buildings.", "square.grid.3x3.fill", .factory, 20, .totalBuildings(250)),
        ach("loom_empire", "Loom Empire", "Own 500 buildings.", "square.grid.4x3.fill", .factory, 35, .totalBuildings(500)),
        // Factory — specific tiers
        ach("whisper_keeper", "Whisper Keeper", "Own 25 Whisper Nets.", "wind", .factory, 6, .tierCount(tier: 1, count: 25)),
        ach("courier_master", "Courier Master", "Own 25 Moth Courier Nests.", "ant.fill", .factory, 15, .tierCount(tier: 7, count: 25)),
        ach("heart_of_the_moon", "Heart of the Moon", "Own 10 Moonheart Engines.", "moon.stars.fill", .factory, 40, .tierCount(tier: 12, count: 10)),
        // Factory — tiers unlocked
        ach("spinning_up", "Spinning Up", "Unlock 3 production tiers.", "lock.open.fill", .factory, 6, .tiersUnlocked(3)),
        ach("halfway_woven", "Halfway Woven", "Unlock 6 production tiers.", "lock.open.fill", .factory, 12, .tiersUnlocked(6)),
        ach("master_weaver", "Master Weaver", "Unlock 9 production tiers.", "lock.open.fill", .factory, 22, .tiersUnlocked(9)),
        ach("full_assembly", "Full Assembly", "Unlock all 12 production tiers.", "checkmark.seal.fill", .factory, 40, .tiersUnlocked(12)),
        // Factory — upgrades
        ach("tinkerer", "Tinkerer", "Reach 10 total upgrade levels.", "wand.and.stars", .factory, 8, .totalUpgradeLevels(10)),
        ach("artificer", "Artificer", "Reach 30 total upgrade levels.", "wand.and.stars.inverse", .factory, 16, .totalUpgradeLevels(30)),
        ach("perfectionist", "Perfectionist", "Reach 60 total upgrade levels.", "star.circle.fill", .factory, 28, .totalUpgradeLevels(60)),
        // Milestones
        ach("first_milestone", "Momentum", "Reach your first production milestone.", "flag.fill", .production, 6, .milestonesReached(1)),
        ach("milestone_maven", "Milestone Maven", "Reach 5 production milestones.", "flag.checkered", .production, 14, .milestonesReached(5)),
        ach("milestone_master", "Milestone Master", "Reach all 10 production milestones.", "flag.2.crossed.fill", .production, 30, .milestonesReached(10)),
        // Orders
        ach("first_order", "First Delivery", "Fulfil your first Dream Order.", "scroll.fill", .orders, 5, .ordersFulfilled(1)),
        ach("order_regular", "Reliable Courier", "Fulfil 5 Dream Orders.", "scroll", .orders, 10, .ordersFulfilled(5)),
        ach("order_veteran", "Dream Logistics", "Fulfil 15 Dream Orders.", "doc.plaintext.fill", .orders, 18, .ordersFulfilled(15)),
        ach("order_legend", "Legend of the Board", "Fulfil 30 Dream Orders.", "rosette", .orders, 30, .ordersFulfilled(30)),
        // Restoration
        ach("first_biome", "First Silver", "Restore your first moon biome.", "moonphase.waxing.crescent", .restoration, 8, .biomesRestored(1)),
        ach("half_moon", "Half Moon", "Restore 4 moon biomes.", "moonphase.first.quarter", .restoration, 18, .biomesRestored(4)),
        ach("full_moon", "Full Moon", "Restore the moon completely.", "moonphase.full.moon", .restoration, 50, .biomesRestored(8)),
        // Prestige
        ach("new_moon", "New Moon", "Perform your first New Moon Reset.", "moonphase.new.moon", .prestige, 15, .resets(1)),
        ach("cycle_keeper", "Cycle Keeper", "Perform 3 New Moon Resets.", "arrow.triangle.2.circlepath", .prestige, 30, .resets(3)),
        ach("eternal_cycle", "Eternal Cycle", "Perform 10 New Moon Resets.", "infinity", .prestige, 75, .resets(10)),
        // Stardust
        ach("stardust_saver", "Stardust Saver", "Earn 50 lifetime Stardust.", "sparkle", .orders, 0, .lifetimeStardust(50)),
        ach("stardust_baron", "Stardust Baron", "Earn 250 lifetime Stardust.", "sparkles", .orders, 0, .lifetimeStardust(250))
    ]

    private static func ach(_ id: String, _ name: String, _ detail: String, _ image: String,
                            _ category: Achievement.Category, _ reward: Double,
                            _ condition: Achievement.Condition) -> Achievement {
        Achievement(id: id, name: name, detail: detail, systemImage: image,
                    category: category, stardustReward: reward, condition: condition)
    }

    static func achievement(id: String) -> Achievement? {
        all.first { $0.id == id }
    }

    /// Achievements newly satisfied by `context` that aren't already unlocked.
    static func newlyUnlocked(context: AchievementContext, alreadyUnlocked: Set<String>) -> [Achievement] {
        all.filter { !alreadyUnlocked.contains($0.id) && context.satisfies($0.condition) }
    }
}
