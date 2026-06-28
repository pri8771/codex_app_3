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

    // MARK: Upgrades / flags
    var purchasedUpgradeIDs: [String]

    // MARK: Orders
    var ordersFulfilled: Int

    // MARK: Moon restoration & prestige
    var moonRestoration: Double
    var resetCount: Int
    var totalLucidShardsEarned: Double
    var bestRunMoonlightRestored: Double
    var permanentUpgradeIDs: [String]

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
        GameSnapshot(
            schemaVersion: 1,
            currencyAmounts: [ResourceType.whispers.rawValue: config.startingWhispers],
            currencyLifetimeEarned: [ResourceType.whispers.rawValue: config.startingWhispers],
            buildingCounts: [:],
            purchasedUpgradeIDs: [],
            ordersFulfilled: 0,
            moonRestoration: 0,
            resetCount: 0,
            totalLucidShardsEarned: 0,
            bestRunMoonlightRestored: 0,
            permanentUpgradeIDs: [],
            isMusicEnabled: true,
            isSFXEnabled: true,
            isNotificationsEnabled: true,
            offlineEarningCapHours: config.defaultOfflineCapHours,
            theme: "default",
            lastActiveTimestamp: now
        )
    }
}
