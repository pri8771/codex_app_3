import Foundation
import OSLog

/// A game-analytics event. Extend the cases as features land.
enum AnalyticsEvent: Sendable {
    case appLaunched
    case offlineEarningsCollected(seconds: TimeInterval)
    case buildingPurchased(tierID: String, count: Int)
    case tierUnlocked(tierID: String)
    case upgradePurchased(tierID: String, level: Int)
    case orderFulfilled(index: Int, rewardAmount: Double)
    case prestigePerformed(resetCount: Int, shardsEarned: Double)
    case codexUpgradePurchased(id: String, level: Int)
    case achievementsUnlocked(count: Int)
    case dailyRewardClaimed(streak: Int)
    case purchaseCompleted(productID: String)
    case screenViewed(name: String)

    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .offlineEarningsCollected: return "offline_earnings_collected"
        case .buildingPurchased: return "building_purchased"
        case .tierUnlocked: return "tier_unlocked"
        case .upgradePurchased: return "upgrade_purchased"
        case .orderFulfilled: return "order_fulfilled"
        case .prestigePerformed: return "prestige_performed"
        case .codexUpgradePurchased: return "codex_upgrade_purchased"
        case .achievementsUnlocked: return "achievements_unlocked"
        case .dailyRewardClaimed: return "daily_reward_claimed"
        case .purchaseCompleted: return "purchase_completed"
        case .screenViewed: return "screen_viewed"
        }
    }
}

/// Event-logging service.
///
/// **Foundation stub:** routes events to the unified logging system only. No
/// third-party SDK and no network calls (consistent with the offline-first,
/// no-dependencies mandate). A real analytics sink can be added behind this
/// same interface later without touching call sites.
final class AnalyticsService: Sendable {

    private let logger = Logger(subsystem: "com.moonloom.app", category: "Analytics")

    func log(_ event: AnalyticsEvent) {
        logger.info("event=\(event.name, privacy: .public)")
    }
}
