import Foundation

/// Pure, deterministic daily-login-reward math (MOONLOOM-PROMPT-007).
///
/// Players may claim once per calendar day. Claiming on the day after the last
/// claim extends the streak; a skipped day resets it to 1. Rewards scale with
/// the streak from 5 Stardust up to 20 at a 7-day streak, then plateau.
struct DailyRewardCalculator: Sendable {

    /// Stardust reward per streak day (index 0 = day 1). Plateaus at the last value.
    let rewardSchedule: [Double]
    private let calendar: Calendar

    init(rewardSchedule: [Double] = [5, 7, 9, 12, 15, 18, 20], calendar: Calendar = .current) {
        self.rewardSchedule = rewardSchedule
        self.calendar = calendar
    }

    /// Stardust granted for a given (1-based) streak length.
    func reward(forStreak streak: Int) -> Double {
        guard streak >= 1, !rewardSchedule.isEmpty else { return rewardSchedule.first ?? 0 }
        let index = min(streak - 1, rewardSchedule.count - 1)
        return rewardSchedule[index]
    }

    /// Whether the player can claim a daily reward now (never claimed, or last
    /// claim was on an earlier calendar day).
    func canClaim(lastClaim: Date?, now: Date) -> Bool {
        guard let lastClaim else { return true }
        return !calendar.isDate(lastClaim, inSameDayAs: now) && now >= lastClaim
    }

    /// The streak the player would have after claiming now.
    /// Consecutive day → +1; same day → unchanged; gap or first → 1.
    func streakAfterClaim(lastClaim: Date?, currentStreak: Int, now: Date) -> Int {
        guard let lastClaim else { return 1 }
        if calendar.isDate(lastClaim, inSameDayAs: now) { return max(1, currentStreak) }
        let startOfLast = calendar.startOfDay(for: lastClaim)
        let startOfNow = calendar.startOfDay(for: now)
        let days = calendar.dateComponents([.day], from: startOfLast, to: startOfNow).day ?? 0
        return days == 1 ? max(1, currentStreak) + 1 : 1
    }

    /// Result of a claim: the new streak and the Stardust to grant.
    struct Claim: Sendable, Equatable {
        let newStreak: Int
        let reward: Double
    }

    /// Evaluate a claim. Returns `nil` if not claimable right now.
    func claim(lastClaim: Date?, currentStreak: Int, now: Date) -> Claim? {
        guard canClaim(lastClaim: lastClaim, now: now) else { return nil }
        let streak = streakAfterClaim(lastClaim: lastClaim, currentStreak: currentStreak, now: now)
        return Claim(newStreak: streak, reward: reward(forStreak: streak))
    }
}
