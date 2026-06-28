import Foundation

/// Presentation logic for the Upgrades panel. Computes, for each upgrade of an
/// unlocked building, the before/after production rate so the player gets clear
/// upgrade feedback (Phase 2 brief). Keeps math out of the view.
@MainActor
struct UpgradesViewModel {
    private let gameState: GameState
    private let formatter = NumberAbbreviator()

    init(gameState: GameState) {
        self.gameState = gameState
    }

    enum Availability: Equatable {
        case available           // unlocked, affordable
        case unaffordable        // unlocked, too expensive
        case locked(remaining: Int) // need more of the building
    }

    struct Row: Identifiable {
        let upgrade: Upgrade
        let tierName: String
        let produces: ResourceType
        let availability: Availability
        let beforeRatePerSecond: Double
        let afterRatePerSecond: Double
    }

    /// Owned-upgrade count (for the header summary).
    var ownedCount: Int {
        gameState.config.upgrades.filter { gameState.isUpgradePurchased($0) }.count
    }

    /// Not-yet-purchased upgrades for unlocked buildings, in progression order.
    var rows: [Row] {
        let tiersByID = Dictionary(uniqueKeysWithValues: gameState.config.tiers.map { ($0.id, $0) })
        return gameState.config.upgrades
            .filter { upgrade in
                guard let tier = tiersByID[upgrade.buildingID] else { return false }
                return gameState.isUnlocked(tier) && !gameState.isUpgradePurchased(upgrade)
            }
            .sorted { lhs, rhs in
                let lt = tiersByID[lhs.buildingID]?.tier ?? 0
                let rt = tiersByID[rhs.buildingID]?.tier ?? 0
                if lt != rt { return lt < rt }
                return lhs.requiredBuildingCount < rhs.requiredBuildingCount
            }
            .compactMap { upgrade in
                guard let tier = tiersByID[upgrade.buildingID] else { return nil }
                let before = gameState.outputPerSecond(forTier: tier)
                let after = before * upgrade.multiplierBoost
                let availability: Availability
                if !gameState.isUpgradeUnlocked(upgrade) {
                    let remaining = upgrade.requiredBuildingCount - gameState.count(of: upgrade.buildingID)
                    availability = .locked(remaining: max(0, remaining))
                } else if gameState.amount(of: upgrade.costCurrency) >= upgrade.cost {
                    availability = .available
                } else {
                    availability = .unaffordable
                }
                return Row(
                    upgrade: upgrade,
                    tierName: tier.name,
                    produces: tier.produces,
                    availability: availability,
                    beforeRatePerSecond: before,
                    afterRatePerSecond: after
                )
            }
    }

    func format(_ value: Double) -> String { formatter.string(from: value) }
}
