import Foundation

/// Produces the single most useful "what to do next" hint for the player, so the
/// first five minutes are understandable without a tutorial (Phase 2 brief:
/// "first 5 minutes of guided progression").
///
/// Pure presentation logic over a read-only view of game state; `@MainActor`
/// only because it reads the main-actor `GameState`. Returns `nil` once the
/// player is clearly self-directed (deep into the game).
@MainActor
struct ProgressionGuide {

    private let state: GameState

    init(state: GameState) {
        self.state = state
    }

    /// A short, imperative next step, or `nil` if no nudge is needed.
    func nextObjective() -> String? {
        let formatter = NumberAbbreviator()
        let tiers = state.config.tiers

        // 1. Bootstrap: build the very first production station.
        if state.totalBuildingCount == 0, let first = tiers.first {
            return "Tap Buy on \(first.name) to start gathering Whispers."
        }

        // 2. A ready order is the highest-value action (free Stardust).
        if let order = state.activeOrder, state.canFulfill(order) {
            return "A Dream Order is ready — open Orders to claim \(formatter.string(from: order.rewardAmount)) Stardust."
        }

        // 3. Drive the collection unlock: reach the tier that introduces Dreamthread.
        if let spindle = tiers.first(where: { $0.id == "dreamthread_spindle" }),
           !state.isUnlocked(spindle),
           let gating = tiers.first(where: { $0.tier == spindle.tier - 1 }) {
            let have = state.count(of: gating.id)
            return "Buy \(spindle.unlockRequirement) × \(gating.name) (\(have)/\(spindle.unlockRequirement)) to unlock Dreamthread."
        }

        // 4. Nudge toward an affordable upgrade (clear power spike).
        if let upgrade = state.affordableUpgrades().first {
            return "You can afford \(upgrade.name) — upgrade to boost production."
        }

        // 5. Otherwise, point at the next order's requirement.
        if let order = state.activeOrder {
            return "Gather \(formatter.string(from: order.requestAmount)) \(order.requestResource.displayName) for the next Dream Order."
        }

        return nil
    }
}
