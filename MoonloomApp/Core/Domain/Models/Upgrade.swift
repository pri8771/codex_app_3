import Foundation

/// Static definition of a building upgrade. Purchasing an upgrade permanently
/// (for the current run) multiplies its building's output by `multiplierBoost`.
///
/// Upgrades unlock once the player owns `requiredBuildingCount` of the target
/// building. Like `ProductionTier`, this is immutable configuration; whether an
/// upgrade is purchased is mutable state on `GameState`. See
/// `MOONLOOM-PROMPT-002` and `TECHNICAL_PRD.md` §4.
struct Upgrade: Identifiable, Sendable, Hashable {
    /// Stable identifier, e.g. `"whisper_net_mk2"`.
    let id: String
    /// The `ProductionTier.id` this upgrade boosts.
    let buildingID: String
    /// Display name, e.g. "Whisper Nets Mk2".
    let name: String
    /// Short description shown in the upgrade list.
    let detail: String
    /// Buildings of `buildingID` the player must own before this unlocks.
    let requiredBuildingCount: Int
    /// Cost to purchase.
    let cost: Double
    /// Currency the cost is paid in.
    let costCurrency: ResourceType
    /// Output multiplier applied to the building while purchased (e.g. 2.0 = ×2).
    let multiplierBoost: Double
}
