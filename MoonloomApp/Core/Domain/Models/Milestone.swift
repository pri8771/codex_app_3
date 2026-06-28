import Foundation

/// A progression milestone that, once its condition is met, contributes a
/// permanent-feeling bonus to the global production multiplier and can gate a
/// "collection unlock" (e.g. revealing a new dream resource). See
/// `MOONLOOM-PROMPT-002` ("Milestone — when reached, apply bonus").
struct Milestone: Identifiable, Sendable, Hashable {

    /// What the player must achieve for this milestone to activate.
    enum Condition: Sendable, Hashable {
        /// Own at least this many buildings in total.
        case totalBuildings(Int)
        /// Own at least this many of a specific building.
        case buildingCount(buildingID: String, count: Int)
        /// Reach this fraction of moon restoration (0...1).
        case moonRestoration(Double)
        /// Earn at least this much of a resource over the player's lifetime.
        case lifetimeEarned(ResourceType, Double)
    }

    let id: String
    let name: String
    let detail: String
    let condition: Condition
    /// Added to the global production multiplier when achieved (e.g. 0.1 = +10%).
    let globalMultiplierBonus: Double
}
