import XCTest
@testable import MoonloomApp

@MainActor
final class SettingsPersistenceTests: XCTestCase {

    private let config = EconomyConfig()

    private func newGame() -> GameState {
        GameState(config: config, snapshot: .newGame(config: config, now: Date(timeIntervalSince1970: 0)))
    }

    func testDefaultSettings() {
        let state = newGame()
        XCTAssertTrue(state.isMusicEnabled)
        XCTAssertTrue(state.isSFXEnabled)
        XCTAssertTrue(state.isNotificationsEnabled)
        XCTAssertEqual(state.offlineEarningCapHours, config.defaultOfflineCapHours)
        XCTAssertEqual(state.theme, "default")
    }

    func testSettingsSurviveSnapshotRoundTrip() {
        let state = newGame()
        state.isMusicEnabled = false
        state.isSFXEnabled = false
        state.isNotificationsEnabled = false
        state.theme = "ember"

        let snapshot = state.snapshot(now: Date(timeIntervalSince1970: 10))
        let restored = GameState(config: config, snapshot: snapshot)

        XCTAssertFalse(restored.isMusicEnabled)
        XCTAssertFalse(restored.isSFXEnabled)
        XCTAssertFalse(restored.isNotificationsEnabled)
        XCTAssertEqual(restored.theme, "ember")
    }

    func testOfflineCapClampedToValidRange() {
        let state = newGame()
        state.setOfflineCapHours(1)          // below default
        XCTAssertEqual(state.offlineEarningCapHours, config.defaultOfflineCapHours)
        state.setOfflineCapHours(999)        // above max
        XCTAssertEqual(state.offlineEarningCapHours, config.maxOfflineCapHours)
        state.setOfflineCapHours(12)
        XCTAssertEqual(state.offlineEarningCapHours, 12)
    }
}

@MainActor
final class ProductionRateAccuracyTests: XCTestCase {

    private let config = EconomyConfig()

    private func makeState(buildings: [String: Int], whispers: Double = 0) -> GameState {
        var snapshot = GameSnapshot.newGame(config: config, now: Date(timeIntervalSince1970: 0))
        snapshot.buildingCounts = buildings
        snapshot.currencyAmounts = [ResourceType.whispers.rawValue: whispers]
        return GameState(config: config, snapshot: snapshot)
    }

    func testRateScalesLinearlyBelowMilestone() throws {
        let tier = try XCTUnwrap(config.tier(id: "whisper_net"))
        // 5 nets: below the 10-building milestone, so global = 1.0.
        let state = makeState(buildings: ["whisper_net": 5])
        XCTAssertEqual(state.globalMultiplier, 1.0, accuracy: 0.0001)
        XCTAssertEqual(state.outputPerSecond(forTier: tier), 5 * 0.1, accuracy: 0.0001)
    }

    func testGlobalMilestoneKicksInAtTenBuildings() throws {
        let tier = try XCTUnwrap(config.tier(id: "whisper_net"))
        let nine = makeState(buildings: ["whisper_net": 9])
        XCTAssertEqual(nine.outputPerSecond(forTier: tier), 0.9, accuracy: 0.0001)

        let ten = makeState(buildings: ["whisper_net": 10])
        // global becomes 1.10 → 10 × 0.1 × 1.10 = 1.1.
        XCTAssertEqual(ten.outputPerSecond(forTier: tier), 1.1, accuracy: 0.0001)
    }

    func testUpgradeDoublesRate() throws {
        let tier = try XCTUnwrap(config.tier(id: "whisper_net"))
        let upgrade = try XCTUnwrap(config.upgrade(id: "whisper_net_mk2"))
        let state = makeState(buildings: ["whisper_net": 10], whispers: 100_000)
        let before = state.outputPerSecond(forTier: tier)
        XCTAssertTrue(state.purchaseUpgrade(upgrade))
        XCTAssertEqual(state.outputPerSecond(forTier: tier), before * 2, accuracy: 0.0001)
    }

    func testAggregateRateAcrossTiers() {
        // 5 nets (0.5 whispers/s) — only whisper-producing tier active.
        let state = makeState(buildings: ["whisper_net": 5])
        XCTAssertEqual(state.outputPerSecond(of: .whispers), 0.5, accuracy: 0.0001)
        XCTAssertEqual(state.outputPerSecond(of: .moonlight), 0, accuracy: 0.0001)
    }
}
