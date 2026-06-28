import Foundation
import SwiftData

/// SwiftData persistence record for prestige + run progress.
///
/// Extends the `TECHNICAL_PRD.md` §3 definition with foundation fields:
/// `restoredNodeIDs` (the in-progress run's restored biomes) and
/// `ordersFulfilled` (Dream Order chain progress). Purchased building upgrades
/// live in `UpgradeRecord`. A single row exists per save.
@Model
final class PrestigeRecord {
    var resetCount: Int
    var totalLucidShardsEarned: Double
    var permanentUpgrades: [String]
    var bestRunMoonlightRestored: Double
    var lastResetDate: Date?
    var restoredNodeIDs: [String]
    var ordersFulfilled: Int
    var schemaVersion: Int

    init(
        resetCount: Int,
        totalLucidShardsEarned: Double,
        permanentUpgrades: [String],
        bestRunMoonlightRestored: Double,
        lastResetDate: Date?,
        restoredNodeIDs: [String],
        ordersFulfilled: Int,
        schemaVersion: Int
    ) {
        self.resetCount = resetCount
        self.totalLucidShardsEarned = totalLucidShardsEarned
        self.permanentUpgrades = permanentUpgrades
        self.bestRunMoonlightRestored = bestRunMoonlightRestored
        self.lastResetDate = lastResetDate
        self.restoredNodeIDs = restoredNodeIDs
        self.ordersFulfilled = ordersFulfilled
        self.schemaVersion = schemaVersion
    }
}
