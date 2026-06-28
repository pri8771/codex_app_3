import Foundation
import SwiftData

/// SwiftData-backed `GameStateRepository`.
///
/// Implemented as a `@ModelActor` so all `ModelContext` access is serialised on
/// the actor's own executor — safe to call from any task. It maps the flat
/// `GameSnapshot` onto the documented per-entity records and back.
@ModelActor
actor SwiftDataGameStateRepository: GameStateRepository {

    func load() async -> GameSnapshot? {
        let currencies = (try? modelContext.fetch(FetchDescriptor<CurrencyRecord>())) ?? []
        let buildings = (try? modelContext.fetch(FetchDescriptor<BuildingRecord>())) ?? []
        let upgrades = (try? modelContext.fetch(FetchDescriptor<UpgradeRecord>())) ?? []
        let prestige = (try? modelContext.fetch(FetchDescriptor<PrestigeRecord>()))?.first
        let settings = (try? modelContext.fetch(FetchDescriptor<SettingsRecord>()))?.first

        // No save yet: signal "new game" to the caller.
        guard let prestige, let settings else { return nil }

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

        let purchasedUpgrades = upgrades.filter(\.isPurchased).map(\.id)

        return GameSnapshot(
            schemaVersion: prestige.schemaVersion,
            currencyAmounts: amounts,
            currencyLifetimeEarned: lifetime,
            buildingCounts: counts,
            purchasedUpgradeIDs: purchasedUpgrades,
            ordersFulfilled: prestige.ordersFulfilled,
            moonRestoration: prestige.currentMoonRestoration,
            resetCount: prestige.resetCount,
            totalLucidShardsEarned: prestige.totalLucidShardsEarned,
            bestRunMoonlightRestored: prestige.bestRunMoonlightRestored,
            permanentUpgradeIDs: prestige.permanentUpgrades,
            isMusicEnabled: settings.isMusicEnabled,
            isSFXEnabled: settings.isSFXEnabled,
            isNotificationsEnabled: settings.isNotificationsEnabled,
            offlineEarningCapHours: settings.offlineEarningCapHours,
            theme: settings.theme,
            lastActiveTimestamp: settings.lastActiveTimestamp
        )
    }

    func save(_ snapshot: GameSnapshot) async {
        let now = snapshot.lastActiveTimestamp

        // Currencies (upsert by type).
        let existingCurrencies = (try? modelContext.fetch(FetchDescriptor<CurrencyRecord>())) ?? []
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
        let config = EconomyConfig()
        let existingBuildings = (try? modelContext.fetch(FetchDescriptor<BuildingRecord>())) ?? []
        var buildingByID = Dictionary(existingBuildings.map { ($0.id, $0) }) { first, _ in first }
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

        // Upgrades (upsert by id). Stores the purchased set; rows for upgrades no
        // longer purchased (e.g. cleared by prestige) are marked unpurchased.
        let purchasedSet = Set(snapshot.purchasedUpgradeIDs)
        let existingUpgrades = (try? modelContext.fetch(FetchDescriptor<UpgradeRecord>())) ?? []
        var upgradeByID = Dictionary(existingUpgrades.map { ($0.id, $0) }) { first, _ in first }
        for record in existingUpgrades where record.isPurchased && !purchasedSet.contains(record.id) {
            record.isPurchased = false
        }
        for id in purchasedSet {
            if let record = upgradeByID[id] {
                record.isPurchased = true
            } else {
                let buildingID = config.upgrade(id: id)?.buildingID ?? ""
                let record = UpgradeRecord(id: id, buildingID: buildingID, isPurchased: true)
                modelContext.insert(record)
                upgradeByID[id] = record
            }
        }

        // Prestige / run progress (single row).
        let prestige = (try? modelContext.fetch(FetchDescriptor<PrestigeRecord>()))?.first
        if let prestige {
            prestige.resetCount = snapshot.resetCount
            prestige.totalLucidShardsEarned = snapshot.totalLucidShardsEarned
            prestige.permanentUpgrades = snapshot.permanentUpgradeIDs
            prestige.bestRunMoonlightRestored = snapshot.bestRunMoonlightRestored
            prestige.currentMoonRestoration = snapshot.moonRestoration
            prestige.ordersFulfilled = snapshot.ordersFulfilled
            prestige.schemaVersion = snapshot.schemaVersion
        } else {
            modelContext.insert(PrestigeRecord(
                resetCount: snapshot.resetCount,
                totalLucidShardsEarned: snapshot.totalLucidShardsEarned,
                permanentUpgrades: snapshot.permanentUpgradeIDs,
                bestRunMoonlightRestored: snapshot.bestRunMoonlightRestored,
                lastResetDate: nil,
                currentMoonRestoration: snapshot.moonRestoration,
                ordersFulfilled: snapshot.ordersFulfilled,
                schemaVersion: snapshot.schemaVersion
            ))
        }

        // Settings (single row).
        let settings = (try? modelContext.fetch(FetchDescriptor<SettingsRecord>()))?.first
        if let settings {
            settings.isMusicEnabled = snapshot.isMusicEnabled
            settings.isSFXEnabled = snapshot.isSFXEnabled
            settings.isNotificationsEnabled = snapshot.isNotificationsEnabled
            settings.offlineEarningCapHours = snapshot.offlineEarningCapHours
            settings.theme = snapshot.theme
            settings.lastActiveTimestamp = snapshot.lastActiveTimestamp
        } else {
            modelContext.insert(SettingsRecord(
                isMusicEnabled: snapshot.isMusicEnabled,
                isSFXEnabled: snapshot.isSFXEnabled,
                isNotificationsEnabled: snapshot.isNotificationsEnabled,
                offlineEarningCapHours: snapshot.offlineEarningCapHours,
                theme: snapshot.theme,
                lastActiveTimestamp: snapshot.lastActiveTimestamp
            ))
        }

        try? modelContext.save()
    }

    func deleteAll() async {
        try? modelContext.delete(model: CurrencyRecord.self)
        try? modelContext.delete(model: BuildingRecord.self)
        try? modelContext.delete(model: UpgradeRecord.self)
        try? modelContext.delete(model: PrestigeRecord.self)
        try? modelContext.delete(model: SettingsRecord.self)
        try? modelContext.save()
    }
}
