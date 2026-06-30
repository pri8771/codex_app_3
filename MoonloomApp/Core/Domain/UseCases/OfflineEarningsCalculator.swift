import Foundation

/// Pure, deterministic calculation of offline earnings.
///
/// Implements `TECHNICAL_PRD.md` §5 / `MOONLOOM-PROMPT-004`: cap elapsed time at
/// the player's offline cap, apply the offline efficiency penalty, award
/// `rate × cappedTime × efficiency`, and produce a **per-building breakdown**
/// (already reflecting upgrade and global multipliers, which are baked into the
/// per-tier rates passed in). Kept free of UI/state so it is trivially testable.
struct OfflineEarningsCalculator: Sendable {

    let config: EconomyConfig

    init(config: EconomyConfig = EconomyConfig()) {
        self.config = config
    }

    /// Earnings attributed to a single building tier.
    struct TierEarning: Sendable, Equatable, Identifiable {
        let tierID: String
        let tierName: String
        let resource: ResourceType
        let amount: Double
        var id: String { tierID }
    }

    /// Result of an offline calculation.
    struct Result: Sendable, Equatable {
        /// Raw seconds elapsed since the player was last active.
        var elapsedSeconds: TimeInterval
        /// Seconds actually credited after applying the offline cap.
        var creditedSeconds: TimeInterval
        /// Earnings per resource (already penalised and capped) — what to credit.
        var earnings: [ResourceType: Double]
        /// Per-building breakdown (empty for the resource-only convenience API).
        var perTier: [TierEarning]

        /// Whether anything meaningful was earned (used to decide whether to
        /// show the "Welcome back!" modal).
        var hasEarnings: Bool {
            earnings.values.contains { $0 > 0 }
        }

        /// Whether the elapsed time hit the offline cap.
        var capApplied: Bool {
            creditedSeconds < elapsedSeconds - 0.001
        }

        /// The building that earned the most while away.
        var mostProductiveTier: TierEarning? {
            perTier.max { $0.amount < $1.amount }
        }
    }

    /// Seconds credited after applying the offline cap (never negative).
    private func creditedSeconds(lastActive: Date, now: Date, capHours: Int) -> (elapsed: TimeInterval, credited: TimeInterval) {
        let elapsed = max(0, now.timeIntervalSince(lastActive))
        let capSeconds = TimeInterval(max(0, capHours)) * 3_600
        return (elapsed, min(elapsed, capSeconds))
    }

    /// Per-resource offline calculation (no per-building breakdown).
    /// - Parameters:
    ///   - efficiency: offline efficiency fraction (defaults to the config value;
    ///     pass higher to reflect Lunar Codex / Eternal Loom bonuses).
    ///   - multiplier: extra multiplier on offline earnings (Moonloom Pass → 2×).
    func calculate(
        perSecond: [ResourceType: Double],
        capHours: Int,
        lastActive: Date,
        now: Date,
        efficiency: Double? = nil,
        multiplier: Double = 1
    ) -> Result {
        let eff = efficiency ?? config.offlineEfficiency
        let (elapsed, credited) = creditedSeconds(lastActive: lastActive, now: now, capHours: capHours)
        var earnings: [ResourceType: Double] = [:]
        if credited > 0 {
            for (resource, rate) in perSecond where rate > 0 {
                earnings[resource] = rate * credited * eff * multiplier
            }
        }
        return Result(elapsedSeconds: elapsed, creditedSeconds: credited, earnings: earnings, perTier: [])
    }

    /// Per-building offline calculation with a full breakdown.
    /// - Parameters:
    ///   - perTier: each producing tier and its active per-second rate
    ///     (which already includes upgrade + global + prestige multipliers).
    ///   - efficiency: offline efficiency fraction (defaults to the config value).
    ///   - multiplier: extra multiplier on offline earnings (Moonloom Pass → 2×).
    func calculate(
        perTier: [(tier: ProductionTier, perSecond: Double)],
        capHours: Int,
        lastActive: Date,
        now: Date,
        efficiency: Double? = nil,
        multiplier: Double = 1
    ) -> Result {
        let eff = efficiency ?? config.offlineEfficiency
        let (elapsed, credited) = creditedSeconds(lastActive: lastActive, now: now, capHours: capHours)
        var earnings: [ResourceType: Double] = [:]
        var breakdown: [TierEarning] = []
        if credited > 0 {
            for entry in perTier where entry.perSecond > 0 {
                let amount = entry.perSecond * credited * eff * multiplier
                guard amount > 0 else { continue }
                earnings[entry.tier.produces, default: 0] += amount
                breakdown.append(TierEarning(
                    tierID: entry.tier.id,
                    tierName: entry.tier.name,
                    resource: entry.tier.produces,
                    amount: amount
                ))
            }
        }
        breakdown.sort { $0.amount > $1.amount }
        return Result(elapsedSeconds: elapsed, creditedSeconds: credited, earnings: earnings, perTier: breakdown)
    }
}
