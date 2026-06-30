import Foundation
import SwiftData

/// SwiftData persistence record for player settings, last-active time, daily-login
/// streak, and onboarding state. See `TECHNICAL_PRD.md` §3. A single row per save.
///
/// The schema-v2 fields (`lastDailyClaim`, `dailyStreak`, `hasCompletedOnboarding`)
/// carry inline default values so SwiftData lightweight migration can add the
/// columns to a v1 store without data loss.
@Model
final class SettingsRecord {
    var isMusicEnabled: Bool
    var isSFXEnabled: Bool
    var isNotificationsEnabled: Bool
    var offlineEarningCapHours: Int
    var theme: String
    var lastActiveTimestamp: Date
    var lastDailyClaim: Date? = nil
    var dailyStreak: Int = 0
    var hasCompletedOnboarding: Bool = false

    init(
        isMusicEnabled: Bool,
        isSFXEnabled: Bool,
        isNotificationsEnabled: Bool,
        offlineEarningCapHours: Int,
        theme: String,
        lastActiveTimestamp: Date,
        lastDailyClaim: Date? = nil,
        dailyStreak: Int = 0,
        hasCompletedOnboarding: Bool = false
    ) {
        self.isMusicEnabled = isMusicEnabled
        self.isSFXEnabled = isSFXEnabled
        self.isNotificationsEnabled = isNotificationsEnabled
        self.offlineEarningCapHours = offlineEarningCapHours
        self.theme = theme
        self.lastActiveTimestamp = lastActiveTimestamp
        self.lastDailyClaim = lastDailyClaim
        self.dailyStreak = dailyStreak
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
