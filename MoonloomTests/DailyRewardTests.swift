import XCTest
@testable import MoonloomApp

final class DailyRewardTests: XCTestCase {

    private var utcCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    private func makeCalculator() -> DailyRewardCalculator {
        DailyRewardCalculator(rewardSchedule: [5, 7, 9, 12, 15, 18, 20], calendar: utcCalendar)
    }

    private let day0 = Date(timeIntervalSince1970: 0)          // 1970-01-01 00:00 UTC
    private var sameDay: Date { Date(timeIntervalSince1970: 3_600) }     // +1h, still day 0
    private var nextDay: Date { Date(timeIntervalSince1970: 86_400) }    // +1 day
    private var twoDaysLater: Date { Date(timeIntervalSince1970: 3 * 86_400) }

    func testRewardScheduleAndPlateau() {
        let calc = makeCalculator()
        XCTAssertEqual(calc.reward(forStreak: 1), 5)
        XCTAssertEqual(calc.reward(forStreak: 7), 20)
        XCTAssertEqual(calc.reward(forStreak: 12), 20, "Plateaus at the last scheduled value")
    }

    func testCanClaimRules() {
        let calc = makeCalculator()
        XCTAssertTrue(calc.canClaim(lastClaim: nil, now: day0), "Never claimed → can claim")
        XCTAssertFalse(calc.canClaim(lastClaim: day0, now: sameDay), "Same calendar day → cannot claim again")
        XCTAssertTrue(calc.canClaim(lastClaim: day0, now: nextDay), "Next day → can claim")
    }

    func testStreakProgression() {
        let calc = makeCalculator()
        XCTAssertEqual(calc.streakAfterClaim(lastClaim: nil, currentStreak: 0, now: day0), 1)
        XCTAssertEqual(calc.streakAfterClaim(lastClaim: day0, currentStreak: 1, now: nextDay), 2, "Consecutive day extends streak")
        XCTAssertEqual(calc.streakAfterClaim(lastClaim: day0, currentStreak: 5, now: twoDaysLater), 1, "A skipped day resets the streak")
    }

    func testClaimReturnsNilWhenAlreadyClaimedToday() {
        let calc = makeCalculator()
        XCTAssertNil(calc.claim(lastClaim: day0, currentStreak: 1, now: sameDay))
        let claim = calc.claim(lastClaim: day0, currentStreak: 1, now: nextDay)
        XCTAssertEqual(claim?.newStreak, 2)
        XCTAssertEqual(claim?.reward, 7)
    }

    @MainActor
    func testGameStateApplyDailyClaim() throws {
        let config = EconomyConfig()
        let state = GameState(config: config, snapshot: .newGame(config: config, now: day0))
        let calc = makeCalculator()
        let claim = try XCTUnwrap(state.availableDailyClaim(now: day0, calculator: calc))
        let before = state.amount(of: .stardust)
        state.applyDailyClaim(claim, now: day0)
        XCTAssertEqual(state.amount(of: .stardust), before + claim.reward, accuracy: 0.001)
        XCTAssertEqual(state.dailyStreak, 1)
        XCTAssertNotNil(state.lastDailyClaim)
        // Cannot claim again the same day.
        XCTAssertNil(state.availableDailyClaim(now: sameDay, calculator: calc))
    }
}
