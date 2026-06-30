import Foundation
import SwiftData

/// SwiftData persistence for an unlocked achievement (MOONLOOM-PROMPT-007).
/// One row per unlocked achievement; absence means "not yet unlocked".
/// Achievement definitions (title, description, reward) live in `AchievementCatalog`.
@Model
final class AchievementRecord {
    /// `Achievement.id`, unique per save.
    @Attribute(.unique) var id: String
    var unlockedDate: Date

    init(id: String, unlockedDate: Date) {
        self.id = id
        self.unlockedDate = unlockedDate
    }
}
