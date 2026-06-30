import XCTest
@testable import MoonloomApp

/// Round-trips the schema-v2 fields (Lunar Codex, achievements, daily login,
/// entitlements, onboarding) through the SwiftData repository.
final class PersistenceV2Tests: XCTestCase {

    func testV2FieldsRoundTrip() async throws {
        let config = EconomyConfig()
        let repository = SwiftDataGameStateRepository(
            modelContainer: AppDatabase.makeContainer(inMemory: true)
        )
        var snapshot = GameSnapshot.newGame(config: config, now: Date(timeIntervalSince1970: 1_000))
        snapshot.lunarCodexLevels = ["dream_efficiency": 3, "eternal_loom": 1]
        snapshot.unlockedAchievementIDs = ["first_light", "first_biome"]
        snapshot.lastDailyClaim = Date(timeIntervalSince1970: 500)
        snapshot.dailyStreak = 4
        snapshot.entitlementProductIDs = [ProductCatalog.celestialTheme, ProductCatalog.passMonthly]
        snapshot.hasCompletedOnboarding = true

        try await repository.save(snapshot)
        let loadedResult = try await repository.load()
        let loaded = try XCTUnwrap(loadedResult)

        XCTAssertEqual(loaded.schemaVersion, 2)
        XCTAssertEqual(loaded.lunarCodexLevels["dream_efficiency"], 3)
        XCTAssertEqual(loaded.lunarCodexLevels["eternal_loom"], 1)
        XCTAssertEqual(Set(loaded.unlockedAchievementIDs), ["first_light", "first_biome"])
        XCTAssertEqual(loaded.lastDailyClaim, Date(timeIntervalSince1970: 500))
        XCTAssertEqual(loaded.dailyStreak, 4)
        XCTAssertEqual(Set(loaded.entitlementProductIDs), [ProductCatalog.celestialTheme, ProductCatalog.passMonthly])
        XCTAssertTrue(loaded.hasCompletedOnboarding)
    }

    func testDeleteAllClearsProgressButPurchasesRecover() async throws {
        // A save wipe erases game progress; a real purchase comes back as soon as
        // StoreKit reconciliation re-supplies it (entitlements aren't destroyed).
        let config = EconomyConfig()
        let repository = SwiftDataGameStateRepository(
            modelContainer: AppDatabase.makeContainer(inMemory: true)
        )
        var snapshot = GameSnapshot.newGame(config: config, now: Date(timeIntervalSince1970: 1_000))
        snapshot.entitlementProductIDs = [ProductCatalog.celestialTheme]
        snapshot.dailyStreak = 9
        try await repository.save(snapshot)

        try await repository.deleteAll()
        let afterDelete = try await repository.load()
        XCTAssertNil(afterDelete, "Progress is gone after a wipe")

        // StoreKit reconciliation supplies the owned entitlement on the next save.
        var reconciled = GameSnapshot.newGame(config: config, now: Date(timeIntervalSince1970: 2_000))
        reconciled.entitlementProductIDs = [ProductCatalog.celestialTheme]
        try await repository.save(reconciled)
        let reloadedResult = try await repository.load()
        let reloaded = try XCTUnwrap(reloadedResult)
        XCTAssertTrue(reloaded.entitlementProductIDs.contains(ProductCatalog.celestialTheme))
        XCTAssertEqual(reloaded.dailyStreak, 0, "Daily streak was reset by the wipe")
    }
}
