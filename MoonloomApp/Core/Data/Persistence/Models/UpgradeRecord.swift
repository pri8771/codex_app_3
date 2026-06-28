import Foundation
import SwiftData

/// SwiftData persistence record for a purchased building upgrade.
/// See `TECHNICAL_PRD.md` §2 (UpgradeRecord) and `MOONLOOM-PROMPT-002`.
/// Only purchased upgrades are stored; definition data (cost, boost) lives in
/// `EconomyConfig`.
@Model
final class UpgradeRecord {
    /// `Upgrade.id`, unique per save.
    @Attribute(.unique) var id: String
    var buildingID: String
    var isPurchased: Bool

    init(id: String, buildingID: String, isPurchased: Bool) {
        self.id = id
        self.buildingID = buildingID
        self.isPurchased = isPurchased
    }
}
