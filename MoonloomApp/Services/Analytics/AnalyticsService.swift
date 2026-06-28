import Foundation
import OSLog

/// A game-analytics event. Extend the cases as features land.
enum AnalyticsEvent: Sendable {
    case appLaunched
    case offlineEarningsCollected(seconds: TimeInterval)
    case buildingPurchased(tierID: String, count: Int)
    case upgradePurchased(upgradeID: String)
    case orderFulfilled(index: Int, rewardAmount: Double)
    case prestigePerformed(resetCount: Int, shardsEarned: Double)
    case screenViewed(name: String)

    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .offlineEarningsCollected: return "offline_earnings_collected"
        case .buildingPurchased: return "building_purchased"
        case .upgradePurchased: return "upgrade_purchased"
        case .orderFulfilled: return "order_fulfilled"
        case .prestigePerformed: return "prestige_performed"
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
