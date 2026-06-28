import Foundation
import SwiftData

/// SwiftData persistence record for prestige + run progress.
///
/// Extends the `TECHNICAL_PRD.md` §3 definition with two foundation fields:
/// `currentMoonRestoration` (the in-progress run's restoration, 0...1) and
/// `ordersFulfilled` (Dream Order chain progress). Purchased building upgrades
/// live in `UpgradeRecord`. A single row exists per save.
@Model
final class PrestigeRecord {
    var resetCount: Int
    var totalLucidShardsEarned: Double
    var permanentUpgrades: [String]
    var bestRunMoonlightRestored: Double
    var lastResetDate: Date?
    var currentMoonRestoration: Double
    var ordersFulfilled: Int
    var schemaVersion: Int

    init(
        resetCount: Int,
        totalLucidShardsEarned: Double,
        permanentUpgrades: [String],
        bestRunMoonlightRestored: Double,
        lastResetDate: Date?,
        currentMoonRestoration: Double,
        ordersFulfilled: Int,
        schemaVersion: Int
    ) {
        self.resetCount = resetCount
        self.totalLucidShardsEarned = totalLucidShardsEarned
        self.permanentUpgrades = permanentUpgrades
        self.bestRunMoonlightRestored = bestRunMoonlightRestored
        self.lastResetDate = lastResetDate
        self.currentMoonRestoration = currentMoonRestoration
        self.ordersFulfilled = ordersFulfilled
        self.schemaVersion = schemaVersion
    }
}
