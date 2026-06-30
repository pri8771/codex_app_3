import XCTest
@testable import MoonloomApp

@MainActor
final class LunarCodexTests: XCTestCase {

    private func makeState() -> GameState {
        let config = EconomyConfig()
        return GameState(config: config, snapshot: .newGame(config: config, now: Date(timeIntervalSince1970: 0)))
    }

    // MARK: - Pure effects math

    func testEmptyLevelsGiveNeutralEffects() {
        let effects = LunarCodex.effects(levels: [:], resetCount: 0)
        XCTAssertEqual(effects.allProductionMultiplier, 1.0, accuracy: 0.0001)
        XCTAssertEqual(effects.offlineCapBonusHours, 0)
        XCTAssertEqual(effects.offlineEfficiencyBonus, 0, accuracy: 0.0001)
        XCTAssertEqual(effects.prestigeBonus, 0, accuracy: 0.0001)
        XCTAssertEqual(effects.startingMoonlightBonus, 0, accuracy: 0.0001)
        XCTAssertEqual(effects.productionMultiplier(forTierNumber: 1), 1.0, accuracy: 0.0001)
    }

    func testAllProductionEffectStacksByLevel() {
        let effects = LunarCodex.effects(levels: ["dream_efficiency": 3], resetCount: 0)
        // +10% per level × 3 = ×1.30 for every tier.
        XCTAssertEqual(effects.allProductionMultiplier, 1.30, accuracy: 0.0001)
        XCTAssertEqual(effects.productionMultiplier(forTierNumber: 5), 1.30, accuracy: 0.0001)
    }

    func testTierRangeEffectOnlyAppliesInRange() {
        let effects = LunarCodex.effects(levels: ["whisper_attunement": 2], resetCount: 0)
        // +20% per level × 2 = ×1.40 for tiers 1–3 only.
        XCTAssertEqual(effects.productionMultiplier(forTierNumber: 2), 1.40, accuracy: 0.0001)
        XCTAssertEqual(effects.productionMultiplier(forTierNumber: 4), 1.0, accuracy: 0.0001)
    }

    func testPrestigeBonusScalesWithResetCount() {
        let effects = LunarCodex.effects(levels: ["lucid_resonance": 5], resetCount: 4)
        // +2% per level per reset = 0.02 × 5 × 4 = 0.40
        XCTAssertEqual(effects.prestigeBonus, 0.40, accuracy: 0.0001)
        // With no resets, the bonus is zero.
        let none = LunarCodex.effects(levels: ["lucid_resonance": 5], resetCount: 0)
        XCTAssertEqual(none.prestigeBonus, 0, accuracy: 0.0001)
    }

    func testCostGrowsExponentially() {
        let upgrade = try! XCTUnwrap(LunarCodex.upgrade(id: "dream_efficiency"))
        XCTAssertEqual(upgrade.cost(forLevel: 0), upgrade.baseCost, accuracy: 0.0001)
        XCTAssertEqual(upgrade.cost(forLevel: 1), upgrade.baseCost * upgrade.costGrowth, accuracy: 0.0001)
        XCTAssertGreaterThan(upgrade.cost(forLevel: 2), upgrade.cost(forLevel: 1))
    }

    func testCatalogIDsAreUnique() {
        let ids = LunarCodex.upgrades.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertEqual(LunarCodex.upgrades.count, 10)
    }

    // MARK: - GameState integration

    func testPurchaseDeductsShardsAndRaisesLevel() throws {
        let state = makeState()
        let upgrade = try XCTUnwrap(LunarCodex.upgrade(id: "dream_efficiency"))
        state.credit(.lucidShards, 100)
        let cost = state.codexCost(for: upgrade)
        XCTAssertTrue(state.purchaseCodexUpgrade(upgrade))
        XCTAssertEqual(state.codexLevel(of: upgrade.id), 1)
        XCTAssertEqual(state.amount(of: .lucidShards), 100 - cost, accuracy: 0.001)
    }

    func testPurchaseBoostsProduction() throws {
        let state = makeState()
        let tier = try XCTUnwrap(state.config.tier(id: "whisper_net"))
        XCTAssertTrue(state.purchaseBuilding(tier))
        let before = state.outputPerSecond(forTier: tier)
        state.credit(.lucidShards, 100)
        let upgrade = try XCTUnwrap(LunarCodex.upgrade(id: "dream_efficiency"))
        XCTAssertTrue(state.purchaseCodexUpgrade(upgrade))
        let after = state.outputPerSecond(forTier: tier)
        XCTAssertEqual(after, before * 1.10, accuracy: max(before * 0.001, 1e-9))
    }

    func testCannotPurchaseBeyondMaxLevel() throws {
        let state = makeState()
        let upgrade = try XCTUnwrap(LunarCodex.upgrade(id: "eternal_loom"))
        state.credit(.lucidShards, 1e9)
        for _ in 0..<upgrade.maxLevel { XCTAssertTrue(state.purchaseCodexUpgrade(upgrade)) }
        XCTAssertTrue(state.isCodexMaxed(upgrade))
        XCTAssertFalse(state.canPurchaseCodex(upgrade))
        XCTAssertFalse(state.purchaseCodexUpgrade(upgrade))
    }

    func testOfflineCapAndEfficiencyBonusesApply() throws {
        let state = makeState()
        state.credit(.lucidShards, 1e9)
        let reservoir = try XCTUnwrap(LunarCodex.upgrade(id: "lunar_reservoir"))
        XCTAssertTrue(state.purchaseCodexUpgrade(reservoir)) // +4h
        XCTAssertEqual(state.effectiveOfflineCapHours, state.config.defaultOfflineCapHours + 4)
        let loom = try XCTUnwrap(LunarCodex.upgrade(id: "eternal_loom"))
        XCTAssertTrue(state.purchaseCodexUpgrade(loom)) // +5% efficiency
        XCTAssertEqual(state.effectiveOfflineEfficiency, state.config.offlineEfficiency + 0.05, accuracy: 0.0001)
    }

    func testStartingMoonlightBonusAppliedOnPrestige() throws {
        let state = makeState()
        state.credit(.lucidShards, 1e9)
        let blessing = try XCTUnwrap(LunarCodex.upgrade(id: "new_moon_blessing"))
        XCTAssertTrue(state.purchaseCodexUpgrade(blessing)) // +100 starting Moonlight
        state.applyPrestige(shardsEarned: 0)
        XCTAssertEqual(state.amount(of: .moonlight), state.config.startingMoonlight + 100, accuracy: 0.001)
    }

    func testCodexSurvivesPrestige() throws {
        let state = makeState()
        state.credit(.lucidShards, 1e9)
        let upgrade = try XCTUnwrap(LunarCodex.upgrade(id: "dream_efficiency"))
        XCTAssertTrue(state.purchaseCodexUpgrade(upgrade))
        state.applyPrestige(shardsEarned: 0)
        XCTAssertEqual(state.codexLevel(of: upgrade.id), 1, "Lunar Codex upgrades are permanent across resets")
    }
}
