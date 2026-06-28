import XCTest
@testable import MoonloomApp

@MainActor
final class EconomySimulationTests: XCTestCase {

    private let config = EconomyConfig()

    private func newGame() -> GameState {
        GameState(config: config, snapshot: .newGame(config: config, now: Date(timeIntervalSince1970: 0)))
    }

    func testInitialStateIsCorrect() {
        let state = newGame()
        XCTAssertEqual(state.amount(of: .whispers), config.startingWhispers, accuracy: 0.001)
        XCTAssertEqual(state.totalBuildingCount, 0)
        XCTAssertEqual(state.ordersFulfilled, 0)
        XCTAssertEqual(state.globalMultiplier, 1.0, accuracy: 0.0001)
    }

    func testSingleTickGeneratesResources() throws {
        let state = newGame()
        let tier = try XCTUnwrap(config.tier(id: "whisper_net"))
        XCTAssertTrue(state.purchaseBuilding(tier))
        let before = state.amount(of: .whispers)
        state.applyProduction(delta: 1.0)
        // 1 net × 0.1/s × 1s = 0.1 whispers.
        XCTAssertEqual(state.amount(of: .whispers), before + 0.1, accuracy: 0.0001)
    }

    func testDeterministicTickSameInputSameOutput() {
        let a = newGame()
        let b = newGame()
        for _ in 0..<100 { a.applyProduction(delta: 0.1) }
        for _ in 0..<100 { b.applyProduction(delta: 0.1) }
        XCTAssertEqual(a.amount(of: .whispers), b.amount(of: .whispers), accuracy: 0.0000001)
    }

    func testNoNaNOrInfinityDuringSimulation() throws {
        let state = newGame()
        // Build a small factory and simulate many ticks.
        let net = try XCTUnwrap(config.tier(id: "whisper_net"))
        state.credit(.whispers, 10_000)
        for _ in 0..<5 { state.purchaseBuilding(net) }
        for _ in 0..<1_000 { state.applyProduction(delta: 0.1) }

        for resource in ResourceType.allCases {
            let value = state.amount(of: resource)
            XCTAssertTrue(value.isFinite, "\(resource) is not finite")
            XCTAssertGreaterThanOrEqual(value, 0)
        }
    }

    /// Acceptance: a simulated new game can progress through the first 3 tiers.
    func testProgressThroughFirstThreeTiers() throws {
        let state = newGame()
        let net = try XCTUnwrap(config.tier(id: "whisper_net"))
        let well = try XCTUnwrap(config.tier(id: "lullaby_well"))
        let spindle = try XCTUnwrap(config.tier(id: "dreamthread_spindle"))

        // Tier 1: affordable from the starting balance.
        XCTAssertTrue(state.canBuyBuilding(net))
        XCTAssertTrue(state.purchaseBuilding(net))

        // Tier 2 unlocks once a Whisper Net is owned.
        XCTAssertTrue(state.isUnlocked(well))
        // Earn toward the Lullaby Well (simulating accumulated production).
        state.credit(.whispers, state.nextCost(for: well))
        XCTAssertTrue(state.purchaseBuilding(well))

        // Tier 3 unlocks once a Lullaby Well is owned.
        XCTAssertTrue(state.isUnlocked(spindle))
        state.credit(.whispers, state.nextCost(for: spindle))
        XCTAssertTrue(state.purchaseBuilding(spindle))

        XCTAssertGreaterThanOrEqual(state.count(of: "whisper_net"), 1)
        XCTAssertGreaterThanOrEqual(state.count(of: "lullaby_well"), 1)
        XCTAssertGreaterThanOrEqual(state.count(of: "dreamthread_spindle"), 1)

        // Dreamthread now actually generates once a Spindle exists.
        let before = state.amount(of: .dreamthread)
        state.applyProduction(delta: 1.0)
        XCTAssertGreaterThan(state.amount(of: .dreamthread), before)
    }

    func testSnapshotRoundTripPreservesPhase2State() throws {
        let state = newGame()
        let net = try XCTUnwrap(config.tier(id: "whisper_net"))
        state.credit(.whispers, 100_000)
        for _ in 0..<10 { state.purchaseBuilding(net) }
        let upgrade = try XCTUnwrap(config.upgrade(id: "whisper_net_mk2"))
        XCTAssertTrue(state.purchaseUpgrade(upgrade))
        let order = try XCTUnwrap(state.activeOrder)
        XCTAssertTrue(state.fulfillOrder(order))

        let snapshot = state.snapshot(now: Date(timeIntervalSince1970: 50))
        let restored = GameState(config: config, snapshot: snapshot)

        XCTAssertEqual(restored.count(of: "whisper_net"), 10)
        XCTAssertTrue(restored.isUpgradePurchased(upgrade))
        XCTAssertEqual(restored.ordersFulfilled, 1)
        XCTAssertEqual(restored.buildingMultiplier(for: "whisper_net"), 2.0, accuracy: 0.001)
    }
}
