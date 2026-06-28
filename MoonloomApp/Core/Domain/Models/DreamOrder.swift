import Foundation

/// A "dream order" the player fulfils by delivering a quantity of a resource in
/// exchange for a reward (Stardust). Orders form a sequential quest chain that
/// both rewards the player and guides early progression. See the Phase 2 brief
/// ("one order/request system — fulfil dream orders for rewards").
struct DreamOrder: Identifiable, Sendable, Hashable {
    /// Stable id, e.g. `"order_3"`.
    let id: String
    /// Position in the sequential order chain (0-based).
    let index: Int
    /// Display title, e.g. "Dream Order #4".
    let title: String
    /// Short flavor line.
    let flavor: String
    /// Resource the player must deliver.
    let requestResource: ResourceType
    /// Amount of `requestResource` required.
    let requestAmount: Double
    /// Resource granted on fulfilment.
    let rewardResource: ResourceType
    /// Amount of `rewardResource` granted.
    let rewardAmount: Double
}
