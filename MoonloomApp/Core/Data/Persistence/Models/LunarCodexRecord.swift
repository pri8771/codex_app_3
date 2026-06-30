import Foundation
import SwiftData

/// SwiftData persistence for a Lunar Codex permanent-upgrade level
/// (MOONLOOM-PROMPT-005). One row per owned upgrade; the level survives New Moon
/// Resets (it is permanent). Upgrade definitions live in `LunarCodex`.
@Model
final class LunarCodexRecord {
    /// `LunarCodexUpgrade.id`, unique per save.
    @Attribute(.unique) var upgradeID: String
    var level: Int

    init(upgradeID: String, level: Int) {
        self.upgradeID = upgradeID
        self.level = level
    }
}
