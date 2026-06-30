import Foundation
import OSLog
#if canImport(UserNotifications)
import UserNotifications
#endif

/// Schedules cozy, non-spammy local reminders that the factory has been busy
/// while the player is away (MOONLOOM-PROMPT-008 / E005 T005-04).
///
/// Reminders fire at the player's offline cap (factory "full"), then at 8h and
/// 24h. They are scheduled when the app backgrounds and cancelled when it returns
/// to the foreground, so a returning player never sees a stale reminder. All
/// calls are safe no-ops where `UserNotifications` is unavailable (tests).
@MainActor
final class NotificationManager {

    private let logger = Logger(subsystem: "com.moonloom.app", category: "Notifications")

    #if canImport(UserNotifications)
    private let center = UNUserNotificationCenter.current()
    #endif

    /// Request permission to send reminders. Returns whether it was granted.
    @discardableResult
    func requestAuthorization() async -> Bool {
        #if canImport(UserNotifications)
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            logger.error("Authorization request failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
        #else
        return false
        #endif
    }

    /// Current authorization status.
    func isAuthorized() async -> Bool {
        #if canImport(UserNotifications)
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        #else
        return false
        #endif
    }

    /// Schedule the offline-reminder series. Existing pending reminders are
    /// cleared first so they never stack up.
    func scheduleOfflineReminders(offlineCapHours: Int) async {
        #if canImport(UserNotifications)
        guard await isAuthorized() else { return }
        cancelAll()

        let cap = max(1, offlineCapHours)
        let reminders: [(id: String, hours: Double, title: String, body: String)] = [
            ("moonloom.offline.cap", Double(cap),
             "Your factory is full 🌙",
             "The Dream Factory has woven all it can hold. Come collect your Moonlight."),
            ("moonloom.offline.8h", 8,
             "The moths are restless 🦋",
             "Your couriers have dreams to deliver. The moon is waiting."),
            ("moonloom.offline.24h", 24,
             "A day of dreams ✨",
             "It's been a while. Tap in to keep restoring the moon's light.")
        ]

        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            let interval = max(60, reminder.hours * 3_600)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
            do {
                try await center.add(request)
            } catch {
                logger.error("Failed to schedule \(reminder.id, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
        #endif
    }

    /// Cancel all pending reminders (call when the app returns to the foreground).
    func cancelAll() {
        #if canImport(UserNotifications)
        center.removeAllPendingNotificationRequests()
        #endif
    }
}
