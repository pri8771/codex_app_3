# Prompt Log — Moonloom: Idle Dream Factory (moonloom)

**Game:** Moonloom: Idle Dream Factory
**Platform:** iOS 17.0+
**Purpose:** Complete record of all prompts used to plan, design, and implement Moonloom
**Last Updated:** 2026-06-27

---

## Legend

| Field | Description |
|-------|-------------|
| PROMPT-ID | Sequential identifier |
| Phase | Planning / Architecture / Implementation / Testing |
| Tool | ChatGPT / Claude Code / Claude (Browser) |
| Epic | Related epic from PROJECT_TRACKER.md |
| Status | ✅ Used / 🔄 Active / 📅 Queued |

---

## Phase 0: Ideation (ChatGPT Collaboration)

### PROMPT-001
**Date:** 2026-06-27 | **Phase:** Ideation | **Tool:** ChatGPT | **Epic:** E001 | **Status:** ✅ Used

**Prompt:**
> "I need an idle/incremental iOS game concept that: runs offline (no cloud), is written in Swift, is monetizable via microtransactions, is fairly complex with progression, has near-infinite replayability via prestige, has beautiful modern design, and feels like it was made by a large studio. Can you help develop a full concept?"

**Outcome:** Moonloom: Idle Dream Factory concept developed — dream factory with 12 tiers, New Moon Reset prestige, offline earnings, moth couriers, moon restoration narrative.

---

### PROMPT-002
**Date:** 2026-06-27 | **Phase:** Ideation | **Tool:** ChatGPT | **Epic:** E001 | **Status:** ✅ Used

**Prompt:**
> "For Moonloom: Idle Dream Factory, develop the complete game specification: all 12 production tiers, all currencies (soft and hard), the prestige system, offline mechanics, monetization catalog, and technical requirements."

**Outcome:** Complete Moonloom game specification defined (see TECHNICAL_PRD.md).

---

## Phase 1: Architecture (Claude Code)

### PROMPT-003
**Date:** 2026-07-01 (Planned) | **Phase:** Architecture | **Tool:** Claude Code | **Epic:** E002 | **Status:** 📅 Queued

**Prompt:**
> "You are the lead iOS architect for Moonloom: Idle Dream Factory — an idle/incremental game for iOS 17+. Tech stack: Swift 5.9, SwiftUI, SwiftData, StoreKit 2. No SpriteKit needed (pure SwiftUI).
>
> The game has:
> - 12 production tiers (buildings), each producing resources the next tier needs
> - 5 currencies: Whispers, Dreamthread, Moonlight, Stardust, Lucid Shards
> - Offline earnings: factory produces when app is closed (2h cap, upgradeable to 48h)
> - Prestige system: New Moon Reset — reset for Lucid Shards + permanent upgrades
> - IAP: cosmetics + convenience (StoreKit 2, no pay-to-win)
>
> Create a complete architecture plan:
> 1. Full folder structure (Clean Architecture + MVVM)
> 2. All Swift files needed with responsibilities
> 3. SwiftData models
> 4. Key protocols and interfaces
> 5. ProductionEngine design (how tick loop works, how offline is calculated)
>
> Format as a detailed architectural specification."

**Expected Output:** Complete Xcode architecture plan
**Planned For:** Sprint 1, Week 1

---

### PROMPT-004
**Date:** 2026-07-01 (Planned) | **Phase:** Architecture | **Tool:** ChatGPT | **Epic:** E002 | **Status:** 📅 Queued

**Prompt:**
> "Here is the architecture plan for Moonloom from our iOS architect: [PASTE CLAUDE CODE OUTPUT]. Review for: completeness, idle game best practices, potential performance issues, any missing components for offline earnings or prestige systems, and SwiftData usage patterns. Suggest improvements."

**Expected Output:** Architecture review
**Planned For:** Sprint 1, Week 1

---

## Phase 2: Implementation Prompts (Claude Code)

### PROMPT-005
**Date:** 2026-07-01 (Planned) | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E002 | **Status:** 📅 Queued

**Prompt:**
> "Create the Xcode project for Moonloom with:
> - App name: Moonloom
> - Bundle ID: com.[team].moonloom
> - Deployment target: iOS 17.0
> - Architecture: Clean Architecture + MVVM
> - Folder structure: [full structure from TECHNICAL_PRD.md]
>
> Create all stub files with boilerplate, imports, and TODO comments. Do not implement logic yet."

**Expected Output:** Complete Xcode project scaffold
**Planned For:** Sprint 1, Day 1

---

### PROMPT-006
**Date:** 2026-07-03 (Planned) | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E003 | **Status:** 📅 Queued

**Prompt:**
> "Implement all SwiftData @Model types for Moonloom:
>
> 1. BuildingRecord: id, tier (1-12), count, baseCPS, multiplier, isUnlocked, totalProduced, lastTickTimestamp
> 2. CurrencyRecord: type (enum: whispers/dreamthread/moonlight/stardust/lucidShards), amount, lifetimeEarned
> 3. PrestigeRecord: resetCount, totalLucidShardsEarned, permanentUpgrades, bestRun, lastResetDate
> 4. AchievementRecord: id, isUnlocked, progress, unlockedDate
> 5. SettingsRecord: music, sfx, notifications, offlineCapHours, theme, lastActiveTimestamp
> 6. UpgradeRecord: id, buildingID, cost, multiplierBoost, isPurchased
>
> Requirements: Sendable conformance, no force unwraps, full DocC comments, unit tests."

**Expected Output:** All @Model types + tests
**Planned For:** Sprint 1, Days 3-5

---

### PROMPT-007
**Date:** 2026-07-08 (Planned) | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E004 | **Status:** 📅 Queued

**Prompt:**
> "Implement the ProductionEngine for Moonloom:
>
> - ProductionEngine actor (thread-safe)
> - 0.1 second tick loop using Task.sleep
> - For each building: amount += count × baseCPS × multiplier × globalMultiplier × prestigeMultiplier × deltaTime
> - Building cost formula: baseCost × 1.15^count (exponential scaling)
> - Upgrade detection: unlock milestone upgrades when building count reaches threshold
> - Stop/resume for prestige reset
>
> Performance requirement: tick must complete in < 1ms
> Include: unit tests, performance tests"

**Expected Output:** ProductionEngine.swift + tests
**Planned For:** Sprint 2

---

### PROMPT-008
**Date:** 2026-07-17 (Planned) | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E005 | **Status:** 📅 Queued

**Prompt:**
> "Implement the offline earnings system for Moonloom:
>
> - On app launch: check SettingsRecord.lastActiveTimestamp
> - Calculate elapsed time (capped at offlineCapHours)
> - Apply 50% efficiency multiplier
> - For each building: offlineEarned = count × baseCPS × multiplier × elapsedTime × 0.5
> - Show 'Welcome back!' modal with breakdown
> - Schedule local notifications at 2h, 8h, 24h with custom messages
>
> Requirements: async/await, no race conditions with active tick, testable"

**Expected Output:** OfflineCalculator.swift + NotificationManager.swift + tests
**Planned For:** Sprint 3

---

### PROMPT-009
**Date:** 2026-07-22 (Planned) | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E006 | **Status:** 📅 Queued

**Prompt:**
> "Implement the prestige system (New Moon Reset) for Moonloom:
>
> - Trigger condition: moonRestoration >= prestigeThreshold (25% first reset, ×1.5 each subsequent)
> - Lucid Shards = floor(moonRestorationPercent × prestigeMultiplier × resetCountBonus)
> - On reset: all buildings → 0, all soft currencies → 0, keep Stardust + Lucid Shards + permanentUpgrades
> - Lunar Codex: upgrade tree unlocked with Lucid Shards (define 10 permanent upgrades)
> - New Moon Reset confirmation flow with: preview of shards earned, current stats, 'Are you sure?' gate
>
> Requirements: Atomic reset (no partial state), full unit tests"

**Expected Output:** PrestigeUseCase.swift + LunarCodexUpgrade.swift + PrestigeView.swift + tests
**Planned For:** Sprint 4

---

### PROMPT-010
**Date:** 2026-08-24 (Planned) | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E008 | **Status:** 📅 Queued

**Prompt:**
> "Implement StoreKit 2 monetization for Moonloom with these products:
>
> | ID | Type | Price |
> |----|------|-------|
> | com.moonloom.dream_pack_celestial | Non-consumable | $2.99 |
> | com.moonloom.dream_pack_ember | Non-consumable | $2.99 |
> | com.moonloom.moth_skin_golden | Non-consumable | $1.99 |
> | com.moonloom.moth_skin_shadow | Non-consumable | $1.99 |
> | com.moonloom.stardust_small | Consumable | $0.99 |
> | com.moonloom.stardust_medium | Consumable | $2.99 |
> | com.moonloom.stardust_large | Consumable | $7.99 |
> | com.moonloom.pass_monthly | Auto-renewable | $4.99/mo |
> | com.moonloom.offline_expansion | Non-consumable | $3.99 |
>
> Implement PurchaseManager (ObservableObject):
> - Fetch + cache products on launch
> - purchase(_ product: Product) async throws
> - restorePurchases() async
> - checkEntitlement(for id: String) async -> Bool
> - subscriptionStatus() async -> Status?
> - Persist entitlements in SwiftData
> - Process unfinished transactions on launch
>
> Include StoreKit configuration file + sandbox tests"

**Expected Output:** PurchaseManager.swift + Moonloom.storekit + tests
**Planned For:** Sprint 8

---

## Prompt Statistics

| Phase | Total | Used | Queued |
|-------|-------|------|--------|
| Ideation | 2 | 2 | 0 |
| Architecture | 2 | 0 | 2 |
| Implementation | 6 | 0 | 6 |
| Testing | 0 | 0 | 0 |
| **Total** | **10** | **2** | **8** |

---

*This log is the single source of truth for all AI prompts used in this project.*
*Last Updated: 2026-06-27*


---

## Phase 1: Claude Code Implementation (ChatGPT-Generated Prompts)

**Date Generated:** 2026-06-27
**Source:** ChatGPT (iOS Game Ideas Collaboration chat)
**Status:** All queued for Claude Code execution

---

### UNIVERSAL-PROMPT: Claude Code Rule Prompt
**Date:** 2026-06-27 | **Phase:** Setup | **Tool:** Claude Code | **Status:** 📅 Queued

**Paste this FIRST in Claude Code before starting implementation:**

```
You are working inside this GitHub repo. This project already has complete documentation: 9 PRDs, a project tracker, a bug tracker, and a prompt log.

Your job is to implement the app from the documentation, not redesign it.

Rules:
1. Read the local documentation before coding.
2. Treat the PRDs as the source of truth.
3. If a decision is already specified in the docs, follow it.
4. If a detail is missing, make the smallest production-quality decision that is consistent with the docs.
5. Do not ask me for clarification unless implementation is truly blocked.
6. Do not delete or rewrite the PRDs.
7. Keep the project tracker updated as work is completed.
8. Keep the bug tracker updated with discovered issues, fixed issues, and remaining issues.
9. Append each major implementation prompt and outcome to the prompt log.
10. Prioritize compiling, testable, production-oriented Swift code over mockups.
11. Avoid placeholder-only features. If something is stubbed, it must be clearly isolated, documented, and safe.
12. After each implementation phase, run the available build/tests or explain exactly why they could not be run.
13. Keep changes scoped to the current phase.
14. Prefer simple, maintainable architecture over clever abstractions.
15. Do not claim something is done unless it is implemented and verified.

Start by scanning the repo and summarizing:
- the app name
- target platform
- key docs found
- current implementation state
- highest-priority next implementation step

Then proceed with the requested phase.
```

---

### MOONLOOM-PROMPT-001: Project Intake and Foundation
**Date:** 2026-06-28 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E002 | **Status:** ✅ Used

```
Implement Phase 1 for Moonloom: Idle Dream Factory.

Before coding:
1. Read all local PRDs and planning docs.
2. Read the project tracker, bug tracker, and prompt log.
3. Identify the intended app architecture, platform target, idle economy requirements, offline earnings requirements, prestige requirements, and MVP scope.
4. Inspect the current codebase and determine whether an iOS project already exists.

Implementation goal:
Create or complete the production foundation for the Moonloom iOS app.

Expected result:
A compiling iOS app with a clean SwiftUI shell, app state model, persistence foundation, and navigation to the major idle game screens.

Implement:
- App entry point
- Home/factory screen placeholder
- Upgrades screen placeholder
- Regions/sleeping towns screen placeholder
- Moon restoration screen placeholder
- Prestige/New Moon Reset screen placeholder
- Settings screen
- Save/load service foundation
- Central GameState model (ObservableObject, @MainActor)
- Central economy config structure (EconomyConfig)
- Time provider abstraction for offline earnings tests
- Number formatting utility (K/M/B/T/Qa/Qi notation for idle numbers)
- Basic haptics service
- Basic audio service stub
- Basic analytics/event logging stub

Technical requirements:
- Use SwiftUI (NO SpriteKit — pure SwiftUI idle game)
- Keep simulation logic out of views
- Make idle engine testable (actor-based ProductionEngine)
- Use central configs for costs, rates, unlocks, multipliers
- Use Codable + SwiftData for persistence
- Prefer deterministic simulation over timer spaghetti
- No force unwraps. Clean Architecture + MVVM. async/await. @MainActor on ViewModels. Sendable. iOS 17.0 minimum. No third-party dependencies.

Acceptance criteria:
- App builds successfully.
- User can navigate between Factory, Upgrades, Regions, Moon Restoration, Prestige, and Settings.
- Save/load service persists and restores simple GameState.
- Number formatter displays large values cleanly (1.23 K, 45.6 M, etc).
- Project tracker, bug tracker, and prompt log updated.
```

**Outcome (2026-06-28):** Foundation implemented as the `MoonloomApp/` Swift
package + `MoonloomApp.xcodeproj` (Xcode 16, iOS 17, file-system synchronized
groups; `project.yml` provided for XcodeGen regeneration).

Delivered:
- **App shell & navigation** — `@main MoonloomApp`, `AppContainer` (lightweight
  DI + lifecycle), `RootView` 4-tab `TabView`: **Factory / Moon Restoration /
  Shop / Settings**. (Acceptance: navigation between the four screens. The
  documented Upgrades/Regions/Prestige destinations are folded into these four
  per the latest foundation spec — Prestige lives on the Moon Restoration tab;
  building purchases live on the Factory tab.)
- **Central state** — `GameState` (`@MainActor ObservableObject`) holding 5
  currencies, building counts, upgrade flags, moon restoration, prestige data,
  and settings; with a `Codable`/`Sendable` `GameSnapshot` projection.
- **Economy config** — `EconomyConfig` with all **12 production tiers**
  (Whisper Nets → Moonheart Engine), exponential cost curve `baseCost·1.15^n`.
- **Production engine** — `actor ProductionEngine` (0.1 s tick, delta-time from
  an injected `TimeProvider` to avoid drift/double-tick — RISK-001/002).
- **Offline earnings** — `OfflineEarningsCalculator` (cap + 0.5 efficiency,
  TECHNICAL_PRD §5) with a "Welcome back" modal.
- **Prestige** — `PrestigeCalculator` + `GameState.applyPrestige` (New Moon
  Reset: zero soft currencies/buildings, keep Stardust/Lucid Shards/permanent
  upgrades) and a confirmation flow.
- **Persistence** — SwiftData `@Model` records (Currency/Building/Prestige/
  Settings) behind a `@ModelActor` `GameStateRepository`; safe in-memory
  fallback so a corrupt store can't crash launch.
- **Services** — `NumberAbbreviator` (K/M/B/T/Qa…), `HapticsService`, and
  documented, inert `AudioService` / `AnalyticsService` stubs.
- **Tests** — XCTest suites for number formatting (incl. `1000→"1K"`,
  `1e6→"1M"`, `1e12→"1T"`), offline earnings, prestige, economy, and GameState.

Verification note: the build/test toolchain (`xcodebuild`/Xcode) is macOS-only
and was **not available in this Linux session**, so the project was authored for
correctness but `xcodebuild build`/`test` were not executed here. Run them on a
macOS + Xcode 16 machine (commands in `MoonloomApp/README.md`). Tracked as
BUG-001 (process note).

Deferred (clearly isolated, safe stubs / later epics): live StoreKit purchasing,
audio playback, local notifications, achievements, full story sequence,
cosmetic theming.

---

### MOONLOOM-PROMPT-002: Core Idle Economy Engine
**Date:** 2026-06-28 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E004 | **Status:** ✅ Used

```
Implement Phase 2 for Moonloom: the core idle economy engine.

Before coding:
1. Read the economy, resource, upgrade tier, passive income, and progression PRDs.
2. Inspect the current foundation from Phase 1.
3. Do not redesign the game. Implement the documented Moonloom economy.

Implementation goal:
Build a deterministic, testable idle economy simulation independent of UI.

Implement core models:
- GameState (all persistent state)
- ResourceType enum: whispers, dreamthread, moonlight, stardust, lucidShards
- CurrencyRecord (amount, lifetimeEarned, lastUpdated)
- BuildingRecord (id, tier, count, baseCPS, multiplier, isUnlocked, totalProduced)
- UpgradeRecord (id, buildingID, cost, multiplierBoost, isPurchased)
- ProductionTier (tier definition, unlock conditions, cost formula)
- EconomyConfig (all tunable values — no scattered literals)
- Milestone (when reached, apply bonus)

Implement production chain:
- Tier 1: Whisper Nets generate Whispers passively
- Tier 2: Lullaby Wells amplify Whispers
- Tier 3: Dreamthread Spindles convert Whispers → Dreamthread
- Tier 4: Memory Looms convert Dreamthread → Dream Fabric
- Tier 5: Nightmare Filters purify dreams
- Tier 6: Star Dye Vats add starlight value
- Tier 7: Moth Courier Nests deliver → Moonlight
- Tier 8: Cloud Packaging Line packages shipments
- Tier 9: Dream Atlas improves routes
- Tier 10: Comet Shipping Dock express deliveries
- Tier 11: Lucid Observatory amplifies Moonlight
- Tier 12: Moonheart Engine powers Moon Restoration

Production formula:
production_per_second = building_count × baseCPS × upgradeMultiplier × globalMultiplier × prestigeMultiplier

Building cost formula:
cost(n) = baseCost × 1.15^count (standard idle exponential)

Implement engine APIs:
- ProductionEngine actor (0.1s tick loop using Task.sleep)
- tick(deltaTime:) → updates all currencies
- buyBuilding(tier:) async → deducts cost, increments count
- buyUpgrade(id:) async → deducts cost, applies multiplier
- canBuyBuilding/canBuyUpgrade
- calculateProductionRates() → for UI display
- getAvailableUpgrades() → unlocked but unpurchased
- serialize/deserialize GameState

Performance: tick must complete in < 1ms

Testing:
Add unit tests for:
- initial state correctness
- resource generation (single tick)
- building purchase (cost deduction, count increment)
- cost scaling formula
- upgrade multiplier application
- upgrade unlock conditions
- milestone activation
- multiplier stacking order
- deterministic tick simulation (same input → same output)
- no NaN/Infinity in normal simulation

Acceptance criteria:
- Economy engine compiles independently of UI.
- Tests pass.
- A simulated new game can progress through first 3 tiers.
- All economy values come from EconomyConfig.
- No production logic in SwiftUI views.
- Trackers updated.
```

**Refined brief (2026-06-28):** Phase 2 was run with an expanded, playability-
focused brief — prove "is the idle reward loop satisfying?" by building ONE
complete loop: auto-generation, a production station + upgrade path, an
order/request system, a milestone-driven collection unlock, offline earnings
display, guided first-5-minutes progression, and reward/upgrade visual feedback.
(Monetization, multi-prestige, dozens of buildings, and live events were
explicitly out of scope.)

**Outcome (2026-06-28):** Implemented on top of the Phase 1 foundation.

Economy engine (UI-independent, in `Core/Domain`):
- Full multiplier-stacked production: `count × baseCPS × upgradeMult ×
  globalMult × prestigeMult` (`GameState.outputPerSecond(forTier:)`).
- **Upgrades**: `Upgrade` model + `EconomyConfig.upgrades` (4 per tier,
  unlock at 10/25/50/100 owned, ×2 each, cost from config). `GameState`
  purchase/unlock/affordability APIs; `UpgradeRecord` persistence.
- **Milestones**: `Milestone` model + catalog driving the global multiplier and
  the Dreamthread "collection unlock"; `isAchieved`/`globalMultiplier`.
- **Dream Orders**: `DreamOrder` + deterministic `OrderGenerator` (sequential
  quest chain, Stardust rewards); `fulfillOrder` spends request → grants reward
  → advances the chain; `ordersFulfilled` persisted.
- **Guidance**: `ProgressionGuide.nextObjective()` gives the single best next
  step for the first five minutes.
- Engine APIs added: `canBuyBuilding/canBuyUpgrade`, `availableUpgrades`,
  `calculateProductionRates`, serialize/deserialize via `GameSnapshot`.

UI (live, wired to the engine):
- `FactoryView` shows live production, global multiplier, a guidance banner, and
  Orders/Upgrades entry points with "ready" badges. `BuildingRowView` uses the
  full rate and animates counts.
- `UpgradesView` (before → after rate feedback), `OrdersView` (progress + reward
  burst animation), `RewardBurstView` celebration.

Tests added: `UpgradeAndMilestoneTests`, `OrderTests`, `EconomySimulationTests`
(initial state, single-tick generation, deterministic ticks, no NaN/Infinity,
progression through the first 3 tiers, multiplier stacking, snapshot round-trip).

Verification note: same as BUG-001 — authored on Linux without an Xcode
toolchain, so `xcodebuild build`/`test` were not executed here; run on macOS +
Xcode 16.

---

### MOONLOOM-PROMPT-003: Main Factory UI and Upgrade Flow
**Date:** 2026-06-28 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E007 | **Status:** ✅ Used

```
Implement Phase 3 for Moonloom: playable factory UI and upgrade purchasing.

Implementation goal:
Turn the economy engine into an interactive idle game screen.

Implement:
- Main factory screen showing all 12 building tiers
- Currency totals updating in real-time through simulation ticks
- Production rate display (per second for each resource)
- Building purchase buttons with count, cost, and CPS contribution
- Upgrade list grouped by tier
- Buy upgrade buttons (enabled/disabled based on affordability)
- Cost display with large number formatting
- Next unlock/milestone progress bar
- Visual representation of dream factory (building icons, upgrade counts)
- Moth courier animation if included in MVP
- App lifecycle handling (simulation pauses/resumes on app state change)
- Haptics on purchase and unlock
- Lightweight animations for resource gain, purchases, tier unlocks
- Moon restoration progress indicator in header

Important design goal:
This should feel like an idle game from first launch:
- Numbers should rise immediately
- Upgrades should be purchasable within 30 seconds
- Production should accelerate visually
- New tiers should unlock within first few minutes
- Player should always see next goal

Acceptance criteria:
- Player earns resources passively while app is open.
- Player can buy buildings and upgrades.
- Upgrades increase production rates.
- Locked tiers unlock through progression.
- UI remains responsive (60fps).
- App builds. Tests pass. Trackers updated.
```

**Refined brief (2026-06-28):** Phase 3 was run with a polish-focused brief —
prove "does the factory feel cozy and alive?" via animation/feedback rather than
new systems. (No StoreKit, events, or prestige layers.)

**Outcome (2026-06-28):** Polished the Phase 2 loop into a cozy, alive factory.

Note on currency: the brief said "Mooncoins," which is not a documented
currency. Per the PRDs, **Moonlight** is the progression currency that powers
Moon Restoration, and the Non-Technical PRD describes restoring the moon **biome
by biome** — so restoration nodes were implemented as biomes costing Moonlight.

Delivered:
- **Moon Restoration reworked to real, spendable nodes**: `RestorationNode`
  model + 8 biomes in `EconomyConfig` (escalating Moonlight costs). `moonRestoration`
  is now the fraction of biomes restored; `GameState.restoreNode` spends Moonlight,
  reveals a story beat, and updates best-run. `MoonRestorationView` shows
  restored/next/locked biomes with a sparkle celebration. Persistence migrated
  (`PrestigeRecord.restoredNodeIDs`, `GameSnapshot.restoredNodeIDs`).
- **All 12 tiers always visible**; locked tiers render greyed with a
  "Next unlock at X" hint (`BuildingRowView`).
- **Building visual states**: idle (dim) / producing (pulsing glow) / maxed
  (golden crown + glow).
- **Animated counters** (currency HUD + per-tier rate via `.contentTransition(.numericText())`),
  **bouncing "order ready" badge**, **upgrade confirmation flash**, and a
  **staggered offline-earnings reveal**.
- **Tier-unlock / milestone celebrations** (toast + haptic + sound) detected in
  `AppContainer`, plus a gentle ~1Hz production *sound* pulse (haptics reserved
  for discrete events to protect battery).
- **Sound + haptic hooks** on purchase, upgrade, order, unlock, milestone, and
  biome restore via `AudioService`/`HapticsService`.
- **Smarter `ProgressionGuide`** (now suggests restoring a biome / saving Moonlight).
- **Reduced-motion support** throughout (animations gated by
  `accessibilityReduceMotion`).

Tests added/updated: `MoonRestorationTests` (node costs, sequential restore,
spend, fraction, prestige clear), `SettingsAndRateTests` (settings persistence,
production-rate accuracy at various upgrade/milestone levels).

Verification note: same as BUG-001 — authored on Linux without an Xcode
toolchain; `xcodebuild build`/`test` not executed here.

---

### MOONLOOM-PROMPT-004: Offline Earnings
**Date:** 2026-06-28 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E005 | **Status:** ✅ Used

```
Implement Phase 4 for Moonloom: offline earnings.

Before coding:
1. Read the offline earnings, save/load, monetization, and retention PRDs.
2. Inspect current GameState, persistence, and simulation loop.

Implementation goal:
When the player closes and reopens the app, Moonloom simulates earned progress while away.

Implement:
- lastSavedAt timestamp in SettingsRecord
- OfflineCalculator actor (deterministic, testable)
- Offline cap: default 2 hours, upgradeable to 12h (Offline Expansion IAP) and up to 48h (Moonloom Pass)
- Offline efficiency: 50% of active production rate
- OfflineSummary model (resources earned per tier, time elapsed, cap applied)
- "Welcome back!" summary modal showing breakdown of offline earnings
- Claim button (applies earnings to GameState)
- Protection against clock manipulation (cap at max allowed time)
- Save immediately after claiming offline rewards
- Schedule local notifications: 2h, 8h, 24h with custom messages

Test with mocked TimeProvider:
- no offline earnings on first launch
- basic offline earnings after 1 hour
- offline cap enforcement (2h default)
- offline efficiency multiplier (50%)
- upgrade increasing offline cap
- offline earnings with multiple active tiers
- resource conversion during offline simulation
- negative/invalid time handling

Acceptance criteria:
- Closing/reopening app grants offline earnings correctly.
- Offline summary clearly shows what was earned.
- Offline earnings respect caps and efficiency multipliers.
- Rewards persist after claiming.
- Tests pass. App builds. Trackers updated.
```

**Refined brief (2026-06-28) — "Full Economy Expansion":** the user expanded
Phase 4 into a five-part economy pass (all 12 tiers with unlock costs; leveled
per-building upgrades; a `MilestoneService` actor with SwiftData; offline
per-building breakdown; an economy balance test suite), explicitly overriding
the narrower offline-only prompt.

**Economy-model decision:** the brief specifies "Moonlight unlock costs" and
"no building produces 0 Moonlight" with a per-building Moonlight breakdown — a
**single-Moonlight production economy**. This diverges from the PRD's
multi-currency chain (whispers → dreamthread → moonlight). Per the user's
explicit, repeated direction ("the full spec overrides"), all 12 tiers now
produce **Moonlight**, with Moonlight-denominated unlock/buy/upgrade costs and
milestone thresholds. The canonical README tier *names* were kept (the brief's
alt names conflicted with the PRD and the built game); Stardust still comes from
orders and Lucid Shards from prestige. Documented here rather than rewriting the
PRDs.

**Outcome (2026-06-28):**
- **All 12 tiers** now have explicit Moonlight `unlockCost` + `baseUpgradeCost`
  in `EconomyConfig`; tiers unlock **sequentially** (no skipping) by paying the
  unlock cost; each produces Moonlight at an escalating base rate.
- **Per-building upgrades (levels 0…10)**: each level ×1.5 (stacking), cost
  `baseUpgradeCost × 1.8^level`. `GameState.upgradeBuilding`,
  `buildingMultiplier = 1.5^level`; `UpgradesView` shows level, current ×, cost
  to next, and before → after rate. `UpgradeRecord` stores level.
- **MilestoneService (actor + SwiftData)**: cumulative-Moonlight thresholds
  (1K…1T), +10% global per milestone, **capped at 5×**, persisted monotonically
  in `MilestoneRecord`. Pure `MilestoneCalculator` does the math; `AppContainer`
  re-evaluates ~1×/s and applies the multiplier to the production tick + HUD.
- **Offline per-building breakdown**: `OfflineEarningsCalculator` now returns a
  per-tier breakdown + most-productive building + cap-applied flag (multipliers
  baked into the per-tier rates); the Welcome-back modal shows the breakdown.
- **Economy balance pass**: `EconomyBalanceTests` verifies 12 tiers, no zero
  base rate, monotonic costs, no Double overflow at max upgrade level, and the
  ≤5× milestone cap.

Tests updated/added: `GameStateTests`, `EconomySimulationTests`, `OrderTests`,
`SettingsAndRateTests`, `UpgradeAndMilestoneTests` (now upgrade-level +
`MilestoneCalculator`), `OfflineEarningsCalculatorTests` (per-building),
`EconomyBalanceTests`.

Verification note: same as BUG-001 — authored on Linux without an Xcode
toolchain; `xcodebuild build`/`test` not executed here. This phase changed the
persistence schema (UpgradeRecord, MilestoneRecord, PrestigeRecord), so a
SwiftData migration check on-device is warranted.

---

### MOONLOOM-PROMPT-005: Prestige System (New Moon Reset)
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E006 | **Status:** 📅 Queued

```
Implement Phase 5 for Moonloom: New Moon Reset prestige system.

Before coding:
1. Read the prestige, Lucid Shards, permanent upgrades, reset rules, and late-progression PRDs.

Implementation goal:
Add Moonloom's full MVP prestige loop.

Prestige eligibility:
- First reset: player must restore ≥ 25% of moon
- Each subsequent: previous threshold × 1.5 (up to 100%)

Lucid Shard calculation:
lucid_shards = floor(moonRestorationPercent × prestigeMultiplier × resetCountBonus)

Implement:
- PrestigeRecord @Model (resetCount, totalLucidShardsEarned, permanentUpgrades, bestRun, lastResetDate)
- PrestigeUseCase (eligibility check, shard calculation, reset execution)
- New Moon Reset confirmation screen (preview: shards to earn, what resets, what persists)
- New Moon Reset execution (atomic — no partial state)
- Lucid Shards currency
- Lunar Codex screen (permanent upgrade tree with 10 upgrades)
- Lucid Shard spending flow
- Prestige multipliers applied to economy engine

What resets on New Moon Reset:
- All building counts → 0
- All soft currencies (Whispers, Dreamthread, Moonlight) → 0
- Moon restoration progress → 0

What PERSISTS:
- Stardust (premium soft currency)
- Lucid Shards (cumulative)
- All Lunar Codex permanent upgrades
- Prestige count history
- Cosmetics/unlocked skins

Lunar Codex upgrade examples (10 upgrades):
1. Dream Efficiency I: +10% all production
2. Dream Efficiency II: +25% all production
3. Offline Cap I: +4h offline cap
4. Moth Speed I: +20% Moonlight generation
5. Whisper Attunement: +50% Tier 1-3 production
6. Lucid Resonance: +5% per prestige (stacks)
7. New Moon Blessing: start next run with 100 Whispers
8. Dreamthread Mastery: +100% Tier 4-6 production
9. Moonheart Surge: +200% final tier production
10. Eternal Loom: offline efficiency +10% (to 60%)

Testing:
- prestige unavailable before threshold
- prestige reward calculation
- reset clears correct fields
- reset preserves correct fields
- Lucid Shard spending
- permanent multiplier application
- second run progresses faster after prestige

Acceptance criteria:
- Player reaches prestige eligibility, previews and executes New Moon Reset.
- Player receives Lucid Shards, correct state persists.
- Permanent upgrades affect future runs.
- Tests pass. App builds. Trackers updated.
```

---

### MOONLOOM-PROMPT-006: Full 12-Tier Production System
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E004 | **Status:** 📅 Queued

```
Implement Phase 6 for Moonloom: full 12-tier production system and passive loops.

Implementation goal:
Expand Moonloom from basic loop into full 12-tier interconnected economy.

All 12 tiers must be implemented:
1. Whisper Nets — generates Whispers (base: 0.1/sec, cost: 10)
2. Lullaby Wells — amplifies Whispers (base: 0.5/sec, cost: 75)
3. Dreamthread Spindles — converts Whispers→Dreamthread (base: 2/sec, cost: 500)
4. Memory Looms — weaves Dreamthread (base: 8/sec, cost: 3K)
5. Nightmare Filters — purifies dreams (base: 25/sec, cost: 20K)
6. Star Dye Vats — starlit dreams (base: 75/sec, cost: 150K)
7. Moth Courier Nests — delivers→Moonlight (base: 200/sec, cost: 1M)
8. Cloud Packaging Line — packages (base: 500/sec, cost: 8M)
9. Dream Atlas — optimizes routes (base: 1.5K/sec, cost: 65M)
10. Comet Shipping Dock — express (base: 5K/sec, cost: 500M)
11. Lucid Observatory — amplifies Moonlight (base: 20K/sec, cost: 4B)
12. Moonheart Engine — powers moon (base: 100K/sec, cost: 30B)

Each tier needs:
- Unique icon (placeholder SVG acceptable)
- Unlock condition (previous tier count threshold)
- 5+ milestone upgrades (×2 multiplier at 10, 25, 50, 100, 200 owned)
- Tier description string
- Custom production animation if practical

Passive automation unlocks:
- At 25 owned: building produces 2x when app is foregrounded for 30+ sec
- At 100 owned: building autoclicks once per second
- At 250 owned: building generates 10% bonus from adjacent tiers

UI grouping:
- Group early (1-4), mid (5-8), late (9-12) tiers
- Show locked tiers greyed with unlock requirement visible
- Filter: "All / Available / Locked"

Economy balancing targets:
- First building purchase: ~10 seconds
- First prestige eligibility: ~30-45 minutes of active play
- Second prestige: ~15 minutes (with bonuses)

Testing:
- All 12 tier configs load without error
- All tier IDs are unique
- All costs are positive and properly scaling
- All unlock conditions are reachable
- Tier unlock progression is testable
- No NaN/Infinity in 60-minute simulated playthrough

Acceptance criteria:
- All 12 tiers exist, unlock, and function correctly.
- Economy remains stable (no runaway inflation).
- Tests pass. App builds. Trackers updated.
```

---

### MOONLOOM-PROMPT-007: Moon Restoration, Story, and Retention
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E007 | **Status:** 📅 Queued

```
Implement Phase 7 for Moonloom: moon restoration, story progression, and retention systems.

Implementation goal:
Give Moonloom its unique story-world progression layer beyond numbers going up.

Implement:
- Moon restoration progress model (0-100% across 5 phases)
- Moon phases: New Moon → Crescent → Half → Gibbous → Full Moon
- Each phase requires increasing Moonlight cost
- Moon restoration screen with visual moon phase indicator
- Story snippets unlocking at each restoration threshold (10%, 25%, 50%, 75%, 100%)
- Phase bonuses:
  * 10%: +5% all production
  * 25%: Unlock Tier 8-9
  * 50%: +20% offline efficiency
  * 75%: Unlock Tier 10-12
  * 100%: New Moon Reset eligibility
- Sleeping regions screen (5 regions, each contributing passive Whispers)
- Region unlock: spend Moonlight to unlock new sleeping town
- Daily login reward (5 Stardust day 1, scaling up to 20 Stardust at 7-day streak)
- Achievement system (50 MVP achievements)
- "Next goal" smart prompt (always showing nearest achievable milestone)

Integrate:
- Economy feeds moon restoration (spend Moonlight)
- Restoration feeds economy (bonuses + unlocks)
- Prestige preserves restoration bonuses (resets progress, keeps permanent unlocks)

Acceptance criteria:
- Player can restore moon phases by spending Moonlight.
- Each phase gives visible bonus or unlock.
- Story snippets are readable.
- Daily reward works and persists.
- Tests pass. App builds. Trackers updated.
```

---

### MOONLOOM-PROMPT-008: Monetization, Polish, and Production Readiness
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E008 | **Status:** 📅 Queued

```
Implement Phase 8 for Moonloom: monetization hooks, settings, and production polish.

StoreKit 2 products to implement:
| Product ID | Type | Price |
|com.moonloom.dream_pack_celestial | Non-consumable | $2.99 |
|com.moonloom.dream_pack_ember | Non-consumable | $2.99 |
|com.moonloom.moth_skin_golden | Non-consumable | $1.99 |
|com.moonloom.moth_skin_shadow | Non-consumable | $1.99 |
|com.moonloom.stardust_small | Consumable | $0.99 (50 Stardust) |
|com.moonloom.stardust_medium | Consumable | $2.99 (175 Stardust) |
|com.moonloom.stardust_large | Consumable | $7.99 (500 Stardust) |
|com.moonloom.pass_monthly | Auto-renewable | $4.99/mo |
|com.moonloom.offline_expansion | Non-consumable | $3.99 |

PurchaseManager (StoreKit 2 async):
- loadProducts() async
- purchase(_ product: Product) async throws → Transaction
- restorePurchases() async
- checkEntitlement(for id: String) async → Bool
- subscriptionStatus() async → Product.SubscriptionInfo.Status?
- Persist entitlements in SwiftData
- Process unfinished transactions on app launch

Settings screen:
- Music toggle (persisted)
- Haptics toggle (persisted)
- Notifications toggle (persisted)
- Privacy/data controls

Production polish:
- App icon and launch screen
- Error-safe SwiftData persistence with migration guard
- Performance audit (memory < 80MB, tick < 1ms)
- Accessibility labels for all major controls
- Remove debug-only UI (gate behind DEBUG build flag)
- Centralize all magic numbers in EconomyConfig

Verification flow:
Launch → Earn → Buy upgrades → Unlock tiers → Close/reopen → Claim offline earnings → Restore moon → Prestige → Buy Lucid upgrade → Progress faster

Acceptance criteria:
- App builds cleanly.
- Tests pass.
- Core MVP loop works end-to-end.
- StoreKit 2 sandbox flows work.
- Persistence is robust.
- Trackers fully updated with final audit.
```

---

### MOONLOOM-AUDIT: Final Repo Completion Audit
**Date:** 2026-06-27 | **Phase:** QA | **Tool:** Claude Code | **Status:** 📅 Queued

```
Perform a full implementation audit for this Moonloom repo.

Tasks:
1. Read all PRDs.
2. Read the project tracker.
3. Read the bug tracker.
4. Read the prompt log.
5. Inspect the current codebase.
6. Compare implemented features against documented MVP requirements.
7. Build the app.
8. Run the test suite.
9. Identify missing, incomplete, broken, or placeholder-only features.
10. Fix any small or moderate issues you can safely fix now.
11. Do not start major redesigns.
12. Update the project tracker, bug tracker, and prompt log.

Return:
- Build result
- Test result
- MVP completeness percentage estimate
- Features fully implemented
- Features partially implemented
- Known bugs
- Risks before App Store submission
- Recommended next implementation prompt, if any
```

---

## Suggested Execution Order

**For Moonloom / moonloom:**
1. UNIVERSAL-PROMPT (rule setup)
2. MOONLOOM-PROMPT-001 (foundation)
3. MOONLOOM-PROMPT-002 (economy engine)
4. MOONLOOM-PROMPT-003 (factory UI)
5. MOONLOOM-PROMPT-004 (offline earnings)
6. MOONLOOM-PROMPT-005 (prestige)
7. MOONLOOM-PROMPT-006 (full 12 tiers)
8. MOONLOOM-PROMPT-007 (restoration + story)
9. MOONLOOM-PROMPT-008 (monetization + polish)
10. MOONLOOM-AUDIT (final audit)

---

## Prompt Statistics (Updated)

| Phase | Total | Used | Queued |
|-------|-------|------|--------|
| Ideation (ChatGPT) | 2 | 2 | 0 |
| Architecture | 2 | 0 | 2 |
| Claude Code Universal | 1 | 0 | 1 |
| Claude Code Implementation | 8 | 4 | 4 |
| Claude Code Audit | 1 | 0 | 1 |
| **Total** | **14** | **6** | **8** |

---

## MOONLOOM-PROMPT-009: Production Build-Out (Phases 5–8 + Polish)

**Date:** 2026-06-30 | **Phase:** Implementation | **Tool:** Claude Code | **Epics:** E005–E009 | **Status:** ✅ Used

**Context:** Direct instruction to develop the app from its Phase-1–4 state to
80–90% production readiness, with all design done by Claude. Reviewed
`pri8771/moonloom` (GitHub) and the strategic planning thread in
`pri8771/conversation` (`Moonloom.md`). That thread — written while the authors
believed the repo was docs-only — recommended deprioritizing Moonloom; the
user's direct build instruction supersedes it. Its design DNA was honored:
cozy, **non-extractive monetization** (no ads/FOMO/pay-to-win), honest economy,
and aesthetic-first polish.

**Implemented (all queued prompts MOONLOOM-PROMPT-005…008, now ✅):**
- **Prestige / Lunar Codex (005, E006):** 10 permanent Lucid-Shard upgrades with
  a pure effects aggregator wired into the multiplier/offline/prestige stack;
  `LunarCodexView`. Codex levels persist across resets.
- **Story / retention (007, E007):** 38 achievements + evaluator (Stardust
  rewards), daily-login streak rewards (5→20 Stardust), Statistics screen,
  first-launch Onboarding.
- **Monetization (008, E008):** StoreKit 2 `PurchaseManager` (load / purchase /
  restore / transaction listener / entitlement reconciliation), `Moonloom.storekit`
  config wired into the scheme, entitlement persistence, Shop wired to real
  purchases, and applied effects (Stardust packs, Offline Expansion, Moonloom
  Pass 2×/48h, cosmetic themes).
- **Design (Claude, E009):** programmatic 1024 app icon (full moon + dreamthread
  ring), token-based design system, three cosmetic `ThemePalette`s that re-skin
  the app, reusable card/button styles.
- **Offline notifications (E005 T005-04):** `NotificationManager` schedules
  offline-cap/8h/24h reminders on background, cancels on foreground.
- **Persistence v2:** new `@Model` records (Achievement/LunarCodex/Entitlement),
  schema v2 lightweight migration, hardened corrupt-store recovery.
- **Accessibility:** VoiceOver labels on new screens; reduced-motion respected.

**Economy decision:** the open question is resolved — the single-Moonlight
production economy is canonical (documented in `EconomyConfig` and CURRENT_STATUS).

**Verification:** `xcodebuild build` clean; `xcodebuild test` → **119 tests, 0
failures** (was 89) on an iPhone 17 simulator; app installs/launches; onboarding
renders. Remaining: real ASC products + sandbox-device IAP, final audio/art,
device/accessibility QA, Instruments, TestFlight.

---

*Last updated: 2026-06-30 — MOONLOOM-PROMPT-009 (production build-out, Phases 5–8 + polish) implemented*
