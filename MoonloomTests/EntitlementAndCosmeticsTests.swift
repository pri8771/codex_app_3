import XCTest
@testable import MoonloomApp

@MainActor
final class EntitlementAndCosmeticsTests: XCTestCase {

    private func makeState() -> GameState {
        let config = EconomyConfig()
        return GameState(config: config, snapshot: .newGame(config: config, now: Date(timeIntervalSince1970: 0)))
    }

    func testProductCatalogMappings() {
        XCTAssertEqual(ProductCatalog.stardustAmount(for: ProductCatalog.stardustSmall), 50)
        XCTAssertEqual(ProductCatalog.stardustAmount(for: ProductCatalog.stardustLarge), 500)
        XCTAssertNil(ProductCatalog.stardustAmount(for: ProductCatalog.celestialTheme))
        XCTAssertTrue(ProductCatalog.isConsumable(ProductCatalog.stardustMedium))
        XCTAssertFalse(ProductCatalog.isConsumable(ProductCatalog.offlineExpansion))
        XCTAssertEqual(ProductCatalog.themeID(for: ProductCatalog.emberTheme), "ember")
        XCTAssertEqual(ProductCatalog.mothSkinID(for: ProductCatalog.goldenMoth), "golden")
        XCTAssertEqual(ProductCatalog.offlineCapHours(for: ProductCatalog.offlineExpansion), 12)
        XCTAssertEqual(ProductCatalog.offlineCapHours(for: ProductCatalog.passMonthly), 48)
        XCTAssertEqual(ProductCatalog.offlineMultiplier(for: ProductCatalog.passMonthly), 2.0)
        XCTAssertEqual(ProductCatalog.allProductIDs.count, 9)
    }

    func testOfflineExpansionRaisesCap() {
        let state = makeState()
        XCTAssertEqual(state.effectiveOfflineCapHours, state.config.defaultOfflineCapHours)
        state.grantEntitlement(ProductCatalog.offlineExpansion)
        XCTAssertGreaterThanOrEqual(state.effectiveOfflineCapHours, 12)
    }

    func testPassGivesMultiplierAndCap() {
        let state = makeState()
        XCTAssertEqual(state.offlineEntitlementMultiplier, 1.0, accuracy: 0.0001)
        XCTAssertFalse(state.hasMoonloomPass)
        state.grantEntitlement(ProductCatalog.passMonthly)
        XCTAssertTrue(state.hasMoonloomPass)
        XCTAssertEqual(state.offlineEntitlementMultiplier, 2.0, accuracy: 0.0001)
        XCTAssertEqual(state.effectiveOfflineCapHours, 48)
    }

    func testThemeOwnershipAndSelection() {
        let state = makeState()
        XCTAssertEqual(state.ownedThemeIDs, ["default"])
        XCTAssertFalse(state.setTheme("celestial"), "Cannot select an unowned theme")
        XCTAssertEqual(state.theme, "default")

        state.grantEntitlement(ProductCatalog.celestialTheme)
        XCTAssertTrue(state.ownedThemeIDs.contains("celestial"))
        XCTAssertTrue(state.setTheme("celestial"))
        XCTAssertEqual(state.theme, "celestial")
    }

    func testMothSkinOwnership() {
        let state = makeState()
        XCTAssertTrue(state.ownedMothSkinIDs.isEmpty)
        state.grantEntitlement(ProductCatalog.shadowMoth)
        XCTAssertTrue(state.ownedMothSkinIDs.contains("shadow"))
    }

    func testSetEntitlementsReplacesActiveSet() {
        let state = makeState()
        state.grantEntitlement(ProductCatalog.celestialTheme)
        _ = state.setTheme("celestial")
        // StoreKit reconciles with an empty set (e.g. entitlement revoked).
        state.setEntitlements([])
        XCTAssertFalse(state.ownsEntitlement(ProductCatalog.celestialTheme))
        XCTAssertEqual(state.theme, "default", "Reverts to default theme when ownership is lost")
    }
}
