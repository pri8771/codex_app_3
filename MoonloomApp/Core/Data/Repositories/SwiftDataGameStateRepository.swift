import Foundation
import SwiftData

/// SwiftData-backed `GameStateRepository`.
///
/// Implemented as a `@ModelActor` so all `ModelContext` access is serialised on
/// the actor's own executor — safe to call from any task. It maps the flat
/// `GameSnapshot` onto the documented per-entity records and back.
@ModelActor
actor SwiftDataGameStateRepository: GameStateRepository {

    func load() async throws -> GameSnapshot? {
        let currencies = try modelContext.fetch(FetchDescriptor<CurrencyRecord>())
        let buildings = try modelContext.fetch(FetchDescriptor<BuildingRecord>())
        let upgrades = try modelContext.fetch(FetchDescriptor<UpgradeRecord>())
        let prestige = try modelContext.fetch(FetchDescriptor<PrestigeRecord>()).first
        let settings = try modelContext.fetch(FetchDescriptor<SettingsRecord>()).first
        let achievements = try modelContext.fetch(FetchDescriptor<AchievementRecord>())
        let codex = try modelContext.fetch(FetchDescriptor<LunarCodexRecord>())
        let entitlements = try modelContext.fetch(FetchDescriptor<EntitlementRecord>())

        // No save yet: signal "new game" to the caller.
        guard let prestige, let settings else { return nil }

        var codexLevels: [String: Int] = [:]
        for record in codex where record.level > 0 {
            codexLevels[record.upgradeID] = record.level
        }

        var amounts: [String: Double] = [:]
        var lifetime: [String: Double] = [:]
        for record in currencies {
            amounts[record.type] = record.amount
            lifetime[record.type] = record.lifetimeEarned
        }

        var counts: [String: Int] = [:]
        for record in buildings where record.count > 0 {
            counts[record.id] = record.count
        }

        var levels: [String: Int] = [:]
        for record in upgrades where record.level > 0 {
            levels[record.buildingID] = record.level
        }

        return GameSnapshot(
            schemaVersion: prestige.schemaVersion,
            currencyAmounts: amounts,
            currencyLifetimeEarned: lifetime,
            buildingCounts: counts,
            upgradeLevels: levels,
            unlockedTierIDs: prestige.unlockedTierIDs,
            ordersFulfilled: prestige.ordersFulfilled,
            restoredNodeIDs: prestige.restoredNodeIDs,
            resetCount: prestige.resetCount,
            totalLucidShardsEarned: prestige.totalLucidShardsEarned,
            bestRunMoonlightRestored: prestige.bestRunMoonlightRestored,
            permanentUpgradeIDs: prestige.permanentUpgrades,
            lunarCodexLevels: codexLevels,
            unlockedAchievementIDs: achievements.map(\.id),
            lastDailyClaim: settings.lastDailyClaim,
            dailyStreak: settings.dailyStreak,
            entitlementProductIDs: entitlements.filter(\.isActive).map(\.productID),
            hasCompletedOnboarding: settings.hasCompletedOnboarding,
            isMusicEnabled: settings.isMusicEnabled,
            isSFXEnabled: settings.isSFXEnabled,
            isNotificationsEnabled: settings.isNotificationsEnabled,
            offlineEarningCapHours: settings.offlineEarningCapHours,
            theme: settings.theme,
            lastActiveTimestamp: settings.lastActiveTimestamp
        )
    }

    func save(_ snapshot: GameSnapshot) async throws {
        let now = snapshot.lastActiveTimestamp

        // Currencies (upsert by type).
        let existingCurrencies = try modelContext.fetch(FetchDescriptor<CurrencyRecord>())
        var currencyByType = Dictionary(existingCurrencies.map { ($0.type, $0) }) { first, _ in first }
        for (type, amount) in snapshot.currencyAmounts {
            let lifetime = snapshot.currencyLifetimeEarned[type] ?? amount
            if let record = currencyByType[type] {
                record.amount = amount
                record.lifetimeEarned = lifetime
                record.lastUpdated = now
            } else {
                let record = CurrencyRecord(type: type, amount: amount,
                                            lifetimeEarned: lifetime, lastUpdated: now)
                modelContext.insert(record)
                currencyByType[type] = record
            }
        }

        // Buildings (upsert by id). Tier metadata is sourced from EconomyConfig.
        // Buildings missing from the snapshot (e.g. cleared by prestige) are
        // reset to 0, mirroring the upgrade-level handling below — otherwise a
        // New Moon Reset would silently revert on the next load.
        let config = EconomyConfig()
        let existingBuildings = try modelContext.fetch(FetchDescriptor<BuildingRecord>())
        var buildingByID = Dictionary(existingBuildings.map { ($0.id, $0) }) { first, _ in first }
        for record in existingBuildings where (snapshot.buildingCounts[record.id] ?? 0) == 0 {
            record.count = 0
        }
        for (id, count) in snapshot.buildingCounts {
            let definition = config.tier(id: id)
            if let record = buildingByID[id] {
                record.count = count
                record.lastTickTimestamp = now
            } else {
                let record = BuildingRecord(
                    id: id,
                    tier: definition?.tier ?? 0,
                    count: count,
                    baseCPS: definition?.baseOutputPerSecond ?? 0,
                    multiplier: 1,
                    isUnlocked: true,
                    totalProduced: 0,
                    lastTickTimestamp: now
                )
                modelContext.insert(record)
                buildingByID[id] = record
            }
        }

        // Upgrade levels (upsert by building id). Buildings missing from the
        // snapshot (e.g. cleared by prestige) are reset to level 0.
        let existingUpgrades = try modelContext.fetch(FetchDescriptor<UpgradeRecord>())
        var upgradeByID = Dictionary(existingUpgrades.map { ($0.buildingID, $0) }) { first, _ in first }
        for record in existingUpgrades where (snapshot.upgradeLevels[record.buildingID] ?? 0) == 0 {
            record.level = 0
        }
        for (buildingID, level) in snapshot.upgradeLevels where level > 0 {
            if let record = upgradeByID[buildingID] {
                record.level = level
            } else {
                let record = UpgradeRecord(buildingID: buildingID, level: level)
                modelContext.insert(record)
                upgradeByID[buildingID] = record
            }
        }

        // Prestige / run progress (single row).
        let prestige = try modelContext.fetch(FetchDescriptor<PrestigeRecord>()).first
        if let prestige {
            prestige.resetCount = snapshot.resetCount
            prestige.totalLucidShardsEarned = snapshot.totalLucidShardsEarned
            prestige.permanentUpgrades = snapshot.permanentUpgradeIDs
            prestige.bestRunMoonlightRestored = snapshot.bestRunMoonlightRestored
            prestige.restoredNodeIDs = snapshot.restoredNodeIDs
            prestige.unlockedTierIDs = snapshot.unlockedTierIDs
            prestige.ordersFulfilled = snapshot.ordersFulfilled
            prestige.schemaVersion = snapshot.schemaVersion
        } else {
            modelContext.insert(PrestigeRecord(
                resetCount: snapshot.resetCount,
                totalLucidShardsEarned: snapshot.totalLucidShardsEarned,
                permanentUpgrades: snapshot.permanentUpgradeIDs,
                bestRunMoonlightRestored: snapshot.bestRunMoonlightRestored,
                lastResetDate: nil,
                restoredNodeIDs: snapshot.restoredNodeIDs,
                unlockedTierIDs: snapshot.unlockedTierIDs,
                ordersFulfilled: snapshot.ordersFulfilled,
                schemaVersion: snapshot.schemaVersion
            ))
        }

        // Lunar Codex permanent upgrades (upsert by upgrade id; permanent, so
        // never removed). Levels are monotonic across New Moon Resets.
        let existingCodex = try modelContext.fetch(FetchDescriptor<LunarCodexRecord>())
        var codexByID = Dictionary(existingCodex.map { ($0.upgradeID, $0) }) { first, _ in first }
        for (upgradeID, level) in snapshot.lunarCodexLevels where level > 0 {
            if let record = codexByID[upgradeID] {
                record.level = level
            } else {
                let record = LunarCodexRecord(upgradeID: upgradeID, level: level)
                modelContext.insert(record)
                codexByID[upgradeID] = record
            }
        }

        // Achievements (insert-only; an unlocked achievement never re-locks).
        let existingAchievements = try modelContext.fetch(FetchDescriptor<AchievementRecord>())
        let achievedIDs = Set(existingAchievements.map(\.id))
        for id in snapshot.unlockedAchievementIDs where !achievedIDs.contains(id) {
            modelContext.insert(AchievementRecord(id: id, unlockedDate: now))
        }

        // Entitlements (upsert by product id). The snapshot's set is authoritative
        // for which entitlements are currently active.
        let activeProductIDs = Set(snapshot.entitlementProductIDs)
        let existingEntitlements = try modelContext.fetch(FetchDescriptor<EntitlementRecord>())
        var entitlementByID = Dictionary(existingEntitlements.map { ($0.productID, $0) }) { first, _ in first }
        for record in existingEntitlements {
            record.isActive = activeProductIDs.contains(record.productID)
        }
        for productID in activeProductIDs where entitlementByID[productID] == nil {
            let record = EntitlementRecord(productID: productID, purchaseDate: now, isActive: true)
            modelContext.insert(record)
            entitlementByID[productID] = record
        }

        // Settings (single row).
        let settings = try modelContext.fetch(FetchDescriptor<SettingsRecord>()).first
        if let settings {
            settings.isMusicEnabled = snapshot.isMusicEnabled
            settings.isSFXEnabled = snapshot.isSFXEnabled
            settings.isNotificationsEnabled = snapshot.isNotificationsEnabled
            settings.offlineEarningCapHours = snapshot.offlineEarningCapHours
            settings.theme = snapshot.theme
            settings.lastActiveTimestamp = snapshot.lastActiveTimestamp
            settings.lastDailyClaim = snapshot.lastDailyClaim
            settings.dailyStreak = snapshot.dailyStreak
            settings.hasCompletedOnboarding = snapshot.hasCompletedOnboarding
        } else {
            modelContext.insert(SettingsRecord(
                isMusicEnabled: snapshot.isMusicEnabled,
                isSFXEnabled: snapshot.isSFXEnabled,
                isNotificationsEnabled: snapshot.isNotificationsEnabled,
                offlineEarningCapHours: snapshot.offlineEarningCapHours,
                theme: snapshot.theme,
                lastActiveTimestamp: snapshot.lastActiveTimestamp,
                lastDailyClaim: snapshot.lastDailyClaim,
                dailyStreak: snapshot.dailyStreak,
                hasCompletedOnboarding: snapshot.hasCompletedOnboarding
            ))
        }

        try modelContext.save()
    }

    func deleteAll() async throws {
        try modelContext.delete(model: CurrencyRecord.self)
        try modelContext.delete(model: BuildingRecord.self)
        try modelContext.delete(model: UpgradeRecord.self)
        try modelContext.delete(model: PrestigeRecord.self)
        try modelContext.delete(model: SettingsRecord.self)
        try modelContext.delete(model: AchievementRecord.self)
        try modelContext.delete(model: LunarCodexRecord.self)
        // NOTE: EntitlementRecord is intentionally NOT deleted — a save wipe must
        // not revoke real purchases. Entitlements re-reconcile from StoreKit.
        // MilestoneRecord is owned by MilestoneService (reset via its own reset()).
        try modelContext.save()
    }
}
