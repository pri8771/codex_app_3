import XCTest
@testable import MoonloomApp

@MainActor
final class AchievementTests: XCTestCase {

    private func makeState() -> GameState {
        let config = EconomyConfig()
        return GameState(config: config, snapshot: .newGame(config: config, now: Date(timeIntervalSince1970: 0)))
    }

    private func emptyContext() -> AchievementContext {
        AchievementContext(
            lifetimeMoonlight: 0, moonlightPerSecond: 0, totalBuildings: 0,
            perTierCount: [:], tiersUnlocked: 1, totalUpgradeLevels: 0,
            ordersFulfilled: 0, biomesRestored: 0, resetCount: 0,
            milestonesReached: 0, lifetimeStardust: 0)
    }

    func testCatalogIDsAreUnique() {
        let ids = AchievementCatalog.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertGreaterThanOrEqual(AchievementCatalog.all.count, 30)
    }

    func testContextSatisfiesThresholds() {
        var context = emptyContext()
        context.lifetimeMoonlight = 1_000
        XCTAssertTrue(context.satisfies(.lifetimeMoonlight(1_000)))
        XCTAssertFalse(context.satisfies(.lifetimeMoonlight(1_001)))
        context.totalBuildings = 10
        XCTAssertTrue(context.satisfies(.totalBuildings(10)))
        context.perTierCount = [1: 25]
        XCTAssertTrue(context.satisfies(.tierCount(tier: 1, count: 25)))
        XCTAssertFalse(context.satisfies(.tierCount(tier: 2, count: 1)))
    }

    func testNewlyUnlockedExcludesAlreadyUnlocked() {
        var context = emptyContext()
        context.lifetimeMoonlight = 1_000
        let first = AchievementCatalog.newlyUnlocked(context: context, alreadyUnlocked: [])
        XCTAssertTrue(first.contains { $0.id == "first_light" })
        let second = AchievementCatalog.newlyUnlocked(context: context, alreadyUnlocked: ["first_light"])
        XCTAssertFalse(second.contains { $0.id == "first_light" })
    }

    func testEvaluateGrantsStardustOnce() throws {
        let state = makeState()
        // Drive Moonlight-lifetime achievements (this also reaches the first
        // production milestone, so more than one achievement may unlock at once).
        state.credit(.moonlight, 1_000)
        let before = state.amount(of: .stardust)
        let newly = state.evaluateAchievements()
        XCTAssertTrue(newly.contains { $0.id == "first_light" })
        let expectedReward = newly.reduce(0) { $0 + $1.stardustReward }
        XCTAssertEqual(state.amount(of: .stardust), before + expectedReward, accuracy: 0.001)
        // Re-evaluating does not double-grant.
        let after = state.amount(of: .stardust)
        let again = state.evaluateAchievements()
        XCTAssertTrue(again.isEmpty)
        XCTAssertEqual(state.amount(of: .stardust), after, accuracy: 0.001)
        XCTAssertTrue(state.isAchievementUnlocked("first_light"))
    }

    func testRestorationAndPrestigeAchievements() throws {
        let state = makeState()
        let node = try XCTUnwrap(state.config.restorationNodes.first)
        state.credit(.moonlight, node.cost)
        XCTAssertTrue(state.restoreNode(node))
        let newly = state.evaluateAchievements()
        XCTAssertTrue(newly.contains { $0.id == "first_biome" })
    }
}
