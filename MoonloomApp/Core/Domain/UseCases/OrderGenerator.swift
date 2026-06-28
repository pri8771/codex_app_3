import Foundation

/// Deterministically generates the `DreamOrder` quest chain from `EconomyConfig`.
///
/// Orders are a pure function of their index, so the same save always sees the
/// same orders (testable, resume-safe). Index `n`'s request scales
/// exponentially; the reward (Stardust) scales linearly.
struct OrderGenerator: Sendable {

    let config: EconomyConfig

    init(config: EconomyConfig = EconomyConfig()) {
        self.config = config
    }

    /// The order at a given chain index.
    func order(at index: Int) -> DreamOrder {
        let safeIndex = max(0, index)
        let cycle = config.orderRequestCycle
        let resource = cycle.isEmpty ? .whispers : cycle[safeIndex % cycle.count]
        let amount = (config.orderBaseAmount * pow(config.orderAmountGrowth, Double(safeIndex))).rounded()
        let reward = (config.orderBaseReward + Double(safeIndex) * config.orderRewardStep).rounded()
        return DreamOrder(
            id: "order_\(safeIndex)",
            index: safeIndex,
            title: "Dream Order #\(safeIndex + 1)",
            flavor: Self.flavor(for: resource),
            requestResource: resource,
            requestAmount: max(1, amount),
            rewardResource: .stardust,
            rewardAmount: max(1, reward)
        )
    }

    /// The visible board: the next `size` orders starting at `fulfilledCount`.
    /// The first element (index == `fulfilledCount`) is the active order.
    func activeBoard(fulfilledCount: Int, size: Int) -> [DreamOrder] {
        let start = max(0, fulfilledCount)
        let count = max(0, size)
        return (start..<(start + count)).map { order(at: $0) }
    }

    private static func flavor(for resource: ResourceType) -> String {
        switch resource {
        case .whispers: return "A sleeping village asks for gathered whispers."
        case .dreamthread: return "The weavers need spun dreamthread."
        case .moonlight: return "The moon calls for delivered moonlight."
        case .stardust: return "A collector seeks shimmering stardust."
        case .lucidShards: return "An old dreamer bargains for lucid shards."
        }
    }
}
