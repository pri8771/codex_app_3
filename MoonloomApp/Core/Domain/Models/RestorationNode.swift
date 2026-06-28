import Foundation

/// One restorable "biome" of the moon. The player spends Moonlight to restore
/// nodes in order; each restored node reveals a short story beat (see
/// `NON_TECHNICAL_PRD.md` — "each biome of the moon you restore reveals new
/// story snippets"). Overall moon restoration is the fraction of nodes restored.
struct RestorationNode: Identifiable, Sendable, Hashable {
    /// Stable id, e.g. `"biome_tranquil_sea"`.
    let id: String
    /// Restoration order (1-based); nodes are restored sequentially.
    let order: Int
    /// Biome name shown on the Moon Restoration screen.
    let name: String
    /// Story snippet revealed when this biome is restored.
    let story: String
    /// Moonlight cost to restore this biome.
    let cost: Double
}
