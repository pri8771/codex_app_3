import XCTest
@testable import MoonloomApp

@MainActor
final class UpgradeAndMilestoneTests: XCTestCase {

    private let config = EconomyConfig()

    /// Build a state with explicit building counts and whisper balance.
    private func makeState(buildings: [String: Int], whispers: Double) -> GameState {
        var snapshot = GameSnapshot.newGame(config: config, now: Date(timeIntervalSince1970: 0))
        snapshot.buildingCounts = buildings
        snapshot.currencyAmounts = [ResourceType.whispers.rawValue: whispers]
        snapshot.currencyLifetimeEarned = [ResourceType.whispers.rawValue: whispers]
        return GameState(config: config, snapshot: snapshot)
    }

    // MARK: Upgrades

    func testUpgradeCostMatchesConfigFormula() throws {
        let upgrade = try XCTUnwrap(config.upgrade(id: "whisper_net_mk2"))
        // baseCost 15 × threshold 10 × costFactor 12 = 1800.
        XCTAssertEqual(upgrade.cost, 15 * 10 * 12, accuracy: 0.001)
        XCTAssertEqual(upgrade.requiredBuildingCount, 10)
        XCTAssertEqual(upgrade.multiplierBoost, 2.0)
        XCTAssertEqual(upgrade.costCurrency, .whispers)
    }

    func testUpgradeLockedUntilBuildingThreshold() throws {
        let upgrade = try XCTUnwrap(config.upgrade(id: "whisper_net_mk2"))
        let few = makeState(buildings: ["whisper_net": 5], whispers: 10_000)
        XCTAssertFalse(few.isUpgradeUnlocked(upgrade))
        XCTAssertFalse(few.canBuyUpgrade(upgrade))

        let enough = makeState(buildings: ["whisper_net": 10], whispers: 10_000)
        XCTAssertTrue(enough.isUpgradeUnlocked(upgrade))
        XCTAssertTrue(enough.canBuyUpgrade(upgrade))
    }

    func testPurchaseUpgradeDeductsCostAndAppliesMultiplier() throws {
        let upgrade = try XCTUnwrap(config.upgrade(id: "whisper_net_mk2"))
        let state = makeState(buildings: ["whisper_net": 10], whispers: 5_000)

        let tier = try XCTUnwrap(config.tier(id: "whisper_net"))
        let before = state.outputPerSecond(forTier: tier)

        XCTAssertTrue(state.purchaseUpgrade(upgrade))
        XCTAssertEqual(state.amount(of: .whispers), 5_000 - 1_800, accuracy: 0.001)
        XCTAssertEqual(state.buildingMultiplier(for: "whisper_net"), 2.0, accuracy: 0.001)
        XCTAssertEqual(state.outputPerSecond(forTier: tier), before * 2, accuracy: 0.0001)
        // Cannot buy the same upgrade twice.
        XCTAssertFalse(state.canBuyUpgrade(upgrade))
    }

    func testAvailableUpgradesExcludesPurchasedAndLocked() throws {
        let state = makeState(buildings: ["whisper_net": 10], whispers: 100_000)
        let available = state.availableUpgrades()
        // whisper_net_mk2 (req 10) available; mk3 (req 25) still locked.
        XCTAssertTrue(available.contains { $0.id == "whisper_net_mk2" })
        XCTAssertFalse(available.contains { $0.id == "whisper_net_mk3" })
    }

    // MARK: Milestones

    func testTotalBuildingsMilestoneRaisesGlobalMultiplier() {
        let none = makeState(buildings: [:], whispers: 0)
        XCTAssertEqual(none.globalMultiplier, 1.0, accuracy: 0.0001)

        let ten = makeState(buildings: ["whisper_net": 10], whispers: 0)
        // Only the "own 10 buildings" milestone (+0.10) is achieved.
        XCTAssertEqual(ten.globalMultiplier, 1.10, accuracy: 0.0001)
    }

    func testMultiplierStackingOrder() throws {
        // 10 nets + mk2 upgrade (×2) + totalBuildings(10) milestone (×1.10).
        let state = makeState(buildings: ["whisper_net": 10], whispers: 5_000)
        let upgrade = try XCTUnwrap(config.upgrade(id: "whisper_net_mk2"))
        XCTAssertTrue(state.purchaseUpgrade(upgrade))

        let tier = try XCTUnwrap(config.tier(id: "whisper_net"))
        // 10 × 0.1 × 2 (upgrade) × 1.10 (global) × 1.0 (prestige) = 2.2.
        XCTAssertEqual(state.outputPerSecond(forTier: tier), 2.2, accuracy: 0.0001)
    }
}
