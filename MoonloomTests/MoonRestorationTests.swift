import XCTest
@testable import MoonloomApp

final class RestorationConfigTests: XCTestCase {

    private let config = EconomyConfig()

    func testNodesAreOrderedSequentially() {
        XCTAssertEqual(config.restorationNodes.map(\.order), Array(1...config.restorationNodes.count))
    }

    func testTotalRestorationCostIsSumOfNodes() {
        let expected = config.restorationNodes.reduce(0) { $0 + $1.cost }
        XCTAssertEqual(config.totalRestorationCost, expected, accuracy: 0.001)
    }

    func testRestorationCurrencyIsMoonlight() {
        XCTAssertEqual(config.restorationCurrency, .moonlight)
    }

    func testNodeLookup() {
        XCTAssertEqual(config.restorationNode(id: "biome_tranquil_sea")?.order, 1)
        XCTAssertNil(config.restorationNode(id: "nope"))
    }
}

@MainActor
final class MoonRestorationTests: XCTestCase {

    private let config = EconomyConfig()

    private func makeState(moonlight: Double, restored: [String] = []) -> GameState {
        var snapshot = GameSnapshot.newGame(config: config, now: Date(timeIntervalSince1970: 0))
        snapshot.currencyAmounts = [ResourceType.moonlight.rawValue: moonlight]
        snapshot.restoredNodeIDs = restored
        return GameState(config: config, snapshot: snapshot)
    }

    func testNewGameHasZeroRestoration() {
        XCTAssertEqual(makeState(moonlight: 0).moonRestoration, 0, accuracy: 0.0001)
    }

    func testRestoreFirstNodeSpendsMoonlightAndAdvances() throws {
        let state = makeState(moonlight: 1_000)
        let first = try XCTUnwrap(state.nextRestorationNode)
        XCTAssertEqual(first.order, 1)
        XCTAssertTrue(state.canRestore(first))

        XCTAssertTrue(state.restoreNode(first))
        XCTAssertEqual(state.amount(of: .moonlight), 1_000 - first.cost, accuracy: 0.001)
        XCTAssertTrue(state.isNodeRestored(first))
        // 1 of N biomes restored.
        XCTAssertEqual(state.moonRestoration, 1.0 / Double(config.restorationNodes.count), accuracy: 0.0001)
    }

    func testCannotRestoreOutOfOrder() throws {
        let state = makeState(moonlight: 1_000_000)
        let third = config.restorationNodes[2]
        XCTAssertFalse(state.canRestore(third))
        XCTAssertFalse(state.restoreNode(third))
    }

    func testCannotRestoreWithoutEnoughMoonlight() throws {
        let state = makeState(moonlight: 100) // first node costs 500
        let first = try XCTUnwrap(state.nextRestorationNode)
        XCTAssertFalse(state.canRestore(first))
        XCTAssertFalse(state.restoreNode(first))
    }

    func testRestorationFractionAfterTwoNodes() {
        let twoIDs = [config.restorationNodes[0].id, config.restorationNodes[1].id]
        let state = makeState(moonlight: 0, restored: twoIDs)
        XCTAssertEqual(state.moonRestoration, 2.0 / Double(config.restorationNodes.count), accuracy: 0.0001)
        // The next node is the third.
        XCTAssertEqual(state.nextRestorationNode?.order, 3)
    }

    func testPrestigeClearsRestoredNodes() {
        let state = makeState(moonlight: 0, restored: [config.restorationNodes[0].id])
        XCTAssertGreaterThan(state.moonRestoration, 0)
        state.applyPrestige(shardsEarned: 0)
        XCTAssertEqual(state.moonRestoration, 0, accuracy: 0.0001)
        // After reset the next biome is the first one again.
        XCTAssertEqual(state.nextRestorationNode?.order, 1)
    }
}
