import Foundation

/// Presentation logic for the Factory screen. A value type computed from the
/// observed `GameState`, keeping simulation/derivation out of the SwiftUI view.
@MainActor
struct FactoryViewModel {
    private let gameState: GameState
    private let formatter = NumberAbbreviator()

    init(gameState: GameState) {
        self.gameState = gameState
    }

    /// Tiers currently visible to the player, in tier order.
    var visibleTiers: [ProductionTier] {
        gameState.unlockedTiers
    }

    /// The next locked tier (shown as a teaser), if any.
    var nextLockedTier: ProductionTier? {
        gameState.config.tiers.first { !gameState.isUnlocked($0) }
    }

    /// Buildings required of the previous tier to unlock `tier`.
    func unlockHint(for tier: ProductionTier) -> String {
        guard let previous = gameState.config.tiers.first(where: { $0.tier == tier.tier - 1 }) else {
            return "Locked"
        }
        let have = gameState.count(of: previous.id)
        return "Own \(tier.unlockRequirement) × \(previous.name) to unlock (\(have)/\(tier.unlockRequirement))"
    }

    /// Headline moonlight-per-second across the factory.
    var moonlightPerSecondText: String {
        formatter.string(from: gameState.outputPerSecond(of: .moonlight))
    }

    var hasAnyBuilding: Bool {
        gameState.buildingCounts.values.contains { $0 > 0 }
    }

    /// Global production multiplier from milestones, e.g. "×1.25".
    var globalMultiplierText: String {
        String(format: "×%.2f", gameState.globalMultiplier)
    }

    /// Whether the global multiplier is above the 1.0 baseline (worth showing).
    var hasGlobalBonus: Bool {
        gameState.globalMultiplier > 1.0001
    }

    /// Count of unlocked, unpurchased upgrades (for the Upgrades button badge).
    var availableUpgradeCount: Int {
        gameState.availableUpgrades().count
    }

    /// Whether an order is ready to fulfil right now (for the Orders badge).
    var hasOrderReady: Bool {
        guard let order = gameState.activeOrder else { return false }
        return gameState.canFulfill(order)
    }

    /// The next-step hint for guided early progression, or `nil`.
    var nextObjective: String? {
        ProgressionGuide(state: gameState).nextObjective()
    }
}
