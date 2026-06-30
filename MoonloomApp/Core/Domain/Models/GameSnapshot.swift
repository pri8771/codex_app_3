import Foundation

/// A flat, `Codable` + `Sendable` value snapshot of all persistent game state.
///
/// `GameState` (a `@MainActor` reference type) projects to and rehydrates from
/// this struct. Keeping a plain value type at the persistence boundary lets the
/// repository move state across concurrency domains safely and gives us a stable
/// schema for save/load and testing.
struct GameSnapshot: Codable, Sendable, Equatable {

    /// Schema version, for future migrations.
    var schemaVersion: Int

    // MARK: Currencies
    var currencyAmounts: [String: Double]
    var currencyLifetimeEarned: [String: Double]

    // MARK: Buildings (tier id → count)
    var buildingCounts: [String: Int]

    // MARK: Upgrades (tier id → level) & unlocked tiers
    var upgradeLevels: [String: Int]
    var unlockedTierIDs: [String]

    // MARK: Orders
    var ordersFulfilled: Int

    // MARK: Moon restoration & prestige
    var restoredNodeIDs: [String]
    var resetCount: Int
    var totalLucidShardsEarned: Double
    var bestRunMoonlightRestored: Double
    var permanentUpgradeIDs: [String]
    /// Lunar Codex permanent upgrade levels (upgrade id → level). Schema v2.
    var lunarCodexLevels: [String: Int]

    // MARK: Meta progression (persist across New Moon Reset). Schema v2.
    /// Achievement identifiers the player has unlocked.
    var unlockedAchievementIDs: [String]
    /// Most recent daily-reward claim (nil if never claimed).
    var lastDailyClaim: Date?
    /// Current consecutive-day login streak.
    var dailyStreak: Int
    /// StoreKit product identifiers the player owns / has active (entitlements).
    var entitlementProductIDs: [String]
    /// Whether the first-launch onboarding has been completed.
    var hasCompletedOnboarding: Bool

    // MARK: Settings
    var isMusicEnabled: Bool
    var isSFXEnabled: Bool
    var isNotificationsEnabled: Bool
    var offlineEarningCapHours: Int
    var theme: String

    // MARK: Timing
    var lastActiveTimestamp: Date

    /// A fresh save for a brand-new player.
    static func newGame(config: EconomyConfig, now: Date) -> GameSnapshot {
        let firstTierID = config.tiers.first?.id
        return GameSnapshot(
            schemaVersion: 2,
            // Seed Moonlight to afford the first building. Not counted as lifetime
            // earned, so milestones derive purely from production.
            currencyAmounts: [ResourceType.moonlight.rawValue: config.startingMoonlight],
            currencyLifetimeEarned: [:],
            buildingCounts: [:],
            upgradeLevels: [:],
            unlockedTierIDs: firstTierID.map { [$0] } ?? [],
            ordersFulfilled: 0,
            restoredNodeIDs: [],
            resetCount: 0,
            totalLucidShardsEarned: 0,
            bestRunMoonlightRestored: 0,
            permanentUpgradeIDs: [],
            lunarCodexLevels: [:],
            unlockedAchievementIDs: [],
            lastDailyClaim: nil,
            dailyStreak: 0,
            entitlementProductIDs: [],
            hasCompletedOnboarding: false,
            isMusicEnabled: true,
            isSFXEnabled: true,
            isNotificationsEnabled: true,
            offlineEarningCapHours: config.defaultOfflineCapHours,
            theme: "default",
            lastActiveTimestamp: now
        )
    }
}
