import XCTest
@testable import MoonloomApp

final class OrderGeneratorTests: XCTestCase {

    private let generator = OrderGenerator()
    private let config = EconomyConfig()

    func testFirstOrderMatchesConfig() {
        let order = generator.order(at: 0)
        XCTAssertEqual(order.index, 0)
        XCTAssertEqual(order.requestResource, .whispers)
        XCTAssertEqual(order.requestAmount, 50, accuracy: 0.001)
        XCTAssertEqual(order.rewardResource, .stardust)
        XCTAssertEqual(order.rewardAmount, 3, accuracy: 0.001)
    }

    func testOrderRequestScalesExponentially() {
        let third = generator.order(at: 2)
        // 50 × 1.8^2 = 162, reward 3 + 2×2 = 7, resource cycles to dreamthread.
        XCTAssertEqual(third.requestAmount, 162, accuracy: 0.001)
        XCTAssertEqual(third.rewardAmount, 7, accuracy: 0.001)
        XCTAssertEqual(third.requestResource, .dreamthread)
    }

    func testGenerationIsDeterministic() {
        XCTAssertEqual(generator.order(at: 5), generator.order(at: 5))
    }

    func testActiveBoardWindow() {
        let board = generator.activeBoard(fulfilledCount: 3, size: 3)
        XCTAssertEqual(board.map(\.index), [3, 4, 5])
    }
}

@MainActor
final class OrderFulfillmentTests: XCTestCase {

    private let config = EconomyConfig()

    private func makeState(whispers: Double, ordersFulfilled: Int) -> GameState {
        var snapshot = GameSnapshot.newGame(config: config, now: Date(timeIntervalSince1970: 0))
        snapshot.currencyAmounts = [ResourceType.whispers.rawValue: whispers]
        snapshot.ordersFulfilled = ordersFulfilled
        return GameState(config: config, snapshot: snapshot)
    }

    func testCannotFulfillWithoutEnoughResource() {
        let state = makeState(whispers: 10, ordersFulfilled: 0)
        let order = try? XCTUnwrap(state.activeOrder)
        XCTAssertNotNil(order)
        if let order { XCTAssertFalse(state.canFulfill(order)) }
    }

    func testFulfillSpendsRequestAndGrantsReward() throws {
        let state = makeState(whispers: 100, ordersFulfilled: 0)
        let order = try XCTUnwrap(state.activeOrder)
        XCTAssertTrue(state.canFulfill(order))

        XCTAssertTrue(state.fulfillOrder(order))
        XCTAssertEqual(state.amount(of: .whispers), 100 - order.requestAmount, accuracy: 0.001)
        XCTAssertEqual(state.amount(of: .stardust), order.rewardAmount, accuracy: 0.001)
        XCTAssertEqual(state.ordersFulfilled, 1)
    }

    func testFulfillingAdvancesToNextOrder() throws {
        let state = makeState(whispers: 100, ordersFulfilled: 0)
        let first = try XCTUnwrap(state.activeOrder)
        XCTAssertTrue(state.fulfillOrder(first))
        let next = try XCTUnwrap(state.activeOrder)
        XCTAssertEqual(next.index, 1)
        // The already-fulfilled order can no longer be fulfilled.
        XCTAssertFalse(state.canFulfill(first))
    }

    func testStaleOrderCannotBeFulfilled() {
        // An order not at the current front index is never fulfillable.
        let state = makeState(whispers: 1_000_000, ordersFulfilled: 0)
        let future = OrderGenerator(config: config).order(at: 2)
        XCTAssertFalse(state.canFulfill(future))
        XCTAssertFalse(state.fulfillOrder(future))
    }
}
