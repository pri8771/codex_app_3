# Project Tracker — Moonloom: Idle Dream Factory (codex_app_3)

**Game:** Moonloom: Idle Dream Factory
**Platform:** iOS 17.0+
**Stack:** Swift / SwiftUI / SwiftData / StoreKit 2
**Last Updated:** 2026-06-28

> **Foundation milestone (2026-06-28, MOONLOOM-PROMPT-001):** the production
> foundation is implemented in `MoonloomApp/` + `MoonloomApp.xcodeproj` — app
> shell, 4-tab navigation (Factory / Moon Restoration / Shop / Settings),
> `GameState`, `EconomyConfig` (12 tiers), `ProductionEngine` actor, offline
> earnings, prestige math, SwiftData persistence, number formatting, haptics,
> and audio/analytics stubs, with XCTest suites. Epics E002–E007 are now partly
> complete (see per-epic status). Build/test were authored but not executed in
> the Linux authoring session — run on macOS + Xcode 16.
>
> **Phase 2 milestone (2026-06-28, MOONLOOM-PROMPT-002):** the core idle loop is
> now playable — full multiplier-stacked production, a building **upgrade**
> system (per-building ×2 tiers), **milestones** driving a global multiplier and
> the Dreamthread collection unlock, a **Dream Orders** quest/reward system, a
> **guided next-step** banner for the first five minutes, and reward/upgrade
> visual feedback. E004 complete; new test suites added (upgrades, milestones,
> orders, economy simulation).

---

## Legend

| Symbol | Meaning |
|--------|---------|
| 📅 | Not Started |
| 🔄 | In Progress |
| ✅ | Complete |
| ⏸ | Deferred |
| ⚠️ | Blocked |

**Story Points:** 1 = 0.5 day, 2 = 1 day, 3 = 1.5 days, 5 = 2.5 days, 8 = 4 days, 13 = 6.5 days

---

## EPIC E001: Project Setup & Documentation

**Status:** ✅ Complete | **Est SP:** 21 | **Actual SP:** 23

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T001-01 | Create GitHub repo (codex_app_3) | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | None |
| T001-02 | Create README.md | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-01 |
| T001-03 | Write Technical PRD | ✅ | 3 | 3 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-01 |
| T001-04 | Write Non-Technical PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-03 |
| T001-05 | Write Business Plan PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-04 |
| T001-06 | Write Monetization PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-05 |
| T001-07 | Write Private Beta PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-04 |
| T001-08 | Write Public Beta PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-07 |
| T001-09 | Write Go-to-Market PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-06 |
| T001-10 | Write Marketing Plan PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-09 |
| T001-11 | Write Investor Deck PRD | ✅ | 2 | 3 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-05 |
| T001-12 | Create PROJECT_TRACKER.md | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-03 |
| T001-13 | Create BUG_TRACKER.md | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-03 |
| T001-14 | Create PROMPT_LOG.md | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-03 |

---

## EPIC E002: Xcode Project Setup

**Status:** 🔄 In Progress | **Est SP:** 10

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T002-01 | Create Xcode project (MoonloomApp) | ✅ | 1 | 2026-07-01 | 2026-07-01 | E001 |
| T002-02 | iOS 17.0 deployment target | ✅ | 1 | 2026-07-01 | 2026-07-01 | T002-01 |
| T002-03 | Configure app icon + launch screen | 🔄 | 2 | 2026-07-01 | 2026-07-01 | T002-01 |
| T002-04 | Clean Architecture folder structure | ✅ | 2 | 2026-07-01 | 2026-07-02 | T002-01 |
| T002-05 | SwiftData ModelContainer setup | ✅ | 2 | 2026-07-02 | 2026-07-02 | T002-04 |
| T002-06 | StoreKit 2 configuration file | 📅 | 2 | 2026-07-02 | 2026-07-02 | T002-04 |

*T002-03: placeholder app icon set + generated launch screen in place; final
artwork pending (E009). T002-06: deferred to monetization phase (E008).*

---

## EPIC E003: Data Models (SwiftData)

**Status:** 🔄 In Progress | **Est SP:** 18

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T003-01 | BuildingRecord @Model | ✅ | 3 | 2026-07-03 | 2026-07-04 | T002-05 |
| T003-02 | CurrencyRecord @Model | ✅ | 2 | 2026-07-04 | 2026-07-04 | T002-05 |
| T003-03 | PrestigeRecord @Model | ✅ | 2 | 2026-07-04 | 2026-07-05 | T002-05 |
| T003-04 | AchievementRecord @Model | 📅 | 2 | 2026-07-05 | 2026-07-05 | T002-05 |
| T003-05 | SettingsRecord @Model | ✅ | 2 | 2026-07-05 | 2026-07-06 | T002-05 |
| T003-06 | UpgradeRecord @Model | ✅ | 2 | 2026-07-06 | 2026-07-06 | T003-01 |
| T003-07 | CosmeticRecord @Model | 📅 | 2 | 2026-07-06 | 2026-07-07 | T002-05 |
| T003-08 | Unit tests for all models | 🔄 | 3 | 2026-07-07 | 2026-07-08 | T003-07 |

*Domain models + GameSnapshot also added. Achievement/Upgrade/Cosmetic records
deferred to their feature phases.*

---

## EPIC E004: Production Engine

**Status:** ✅ Complete | **Est SP:** 26

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T004-01 | ProductionEngine actor (tick loop) | ✅ | 5 | 2026-07-08 | 2026-07-10 | E003 |
| T004-02 | Building cost formula (exponential scaling) | ✅ | 3 | 2026-07-10 | 2026-07-11 | T004-01 |
| T004-03 | Upgrade multiplier system | ✅ | 5 | 2026-07-11 | 2026-07-13 | T004-02 |
| T004-04 | Global multiplier system | ✅ | 3 | 2026-07-13 | 2026-07-14 | T004-03 |
| T004-05 | Number formatting (K/M/B/T notation) | ✅ | 2 | 2026-07-14 | 2026-07-14 | T004-01 |
| T004-06 | Prestige multiplier integration | ✅ | 3 | 2026-07-14 | 2026-07-15 | T004-04 |
| T004-07 | Unit tests for production engine | ✅ | 5 | 2026-07-15 | 2026-07-17 | T004-06 |

*Phase 2: per-building upgrades + milestone-driven global multiplier implemented;
full multiplier stack verified by `EconomySimulationTests` / `UpgradeAndMilestoneTests`.*

---

## EPIC E005: Offline Earnings System

**Status:** 🔄 In Progress | **Est SP:** 13

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T005-01 | OfflineCalculator (time-based earnings) | ✅ | 5 | 2026-07-17 | 2026-07-19 | E004 |
| T005-02 | Offline cap enforcement (2h default) | ✅ | 2 | 2026-07-19 | 2026-07-20 | T005-01 |
| T005-03 | "Welcome back!" summary modal | ✅ | 3 | 2026-07-20 | 2026-07-21 | T005-01 |
| T005-04 | Local notifications (8h, 24h reminders) | 📅 | 3 | 2026-07-21 | 2026-07-22 | T005-02 |

---

## EPIC E006: Prestige System (New Moon Reset)

**Status:** 🔄 In Progress | **Est SP:** 21

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T006-01 | Prestige trigger conditions | ✅ | 3 | 2026-07-22 | 2026-07-23 | E004 |
| T006-02 | Lucid Shard calculation formula | ✅ | 3 | 2026-07-23 | 2026-07-24 | T006-01 |
| T006-03 | Reset logic (keep shards + upgrades, reset rest) | ✅ | 5 | 2026-07-24 | 2026-07-26 | T006-02 |
| T006-04 | Lunar Codex (permanent upgrade tree) | 📅 | 5 | 2026-07-26 | 2026-07-28 | T006-03 |
| T006-05 | New Moon Reset confirmation flow (UI) | ✅ | 3 | 2026-07-28 | 2026-07-29 | T006-03 |
| T006-06 | Unit tests for prestige system | ✅ | 2 | 2026-07-29 | 2026-07-30 | T006-04 |

*Lunar Codex permanent-upgrade tree (T006-04) deferred to MOONLOOM-PROMPT-005.*

---

## EPIC E007: SwiftUI Interface

**Status:** 🔄 In Progress | **Est SP:** 55

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T007-01 | Main Factory Screen (12 building rows) | ✅ | 8 | 2026-08-01 | 2026-08-05 | E004 |
| T007-02 | Building upgrade panel | ✅ | 5 | 2026-08-05 | 2026-08-07 | T007-01 |
| T007-03 | Moon restoration progress bar/visual | ✅ | 5 | 2026-08-07 | 2026-08-09 | E006 |
| T007-04 | Currency display HUD | ✅ | 3 | 2026-08-09 | 2026-08-10 | T007-01 |
| T007-05 | Upgrade tree screen (Lunar Codex) | 📅 | 5 | 2026-08-10 | 2026-08-12 | E006 |
| T007-06 | Cosmetics shop screen | 🔄 | 5 | 2026-08-12 | 2026-08-14 | E008 |
| T007-07 | Achievement screen (200 achievements) | 📅 | 5 | 2026-08-14 | 2026-08-16 | None |
| T007-08 | Settings screen | ✅ | 2 | 2026-08-16 | 2026-08-17 | None |
| T007-09 | Onboarding / tutorial flow | 📅 | 5 | 2026-08-17 | 2026-08-19 | T007-01 |
| T007-10 | Offline earnings "welcome back" modal | ✅ | 3 | 2026-08-19 | 2026-08-20 | E005 |
| T007-11 | New Moon Reset confirmation screen | ✅ | 3 | 2026-08-20 | 2026-08-21 | E006 |
| T007-12 | Statistics/player history screen | 📅 | 3 | 2026-08-21 | 2026-08-22 | None |
| T007-13 | Animations + visual polish | 📅 | 3 | 2026-08-22 | 2026-08-23 | T007-01 |

*Shop screen (T007-06) is a non-charging catalog placeholder until StoreKit
(E008) lands. Tab navigation shell (Factory/Moon/Shop/Settings) complete.*

---

## EPIC E008: Monetization (StoreKit 2)

**Status:** 📅 Not Started | **Est SP:** 21

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T008-01 | Define all product IDs | 📅 | 1 | 2026-08-24 | 2026-08-24 | E002 |
| T008-02 | PurchaseManager (StoreKit 2 async) | 📅 | 5 | 2026-08-24 | 2026-08-26 | T008-01 |
| T008-03 | Product fetch + caching | 📅 | 2 | 2026-08-26 | 2026-08-26 | T008-02 |
| T008-04 | Purchase flow (all product types) | 📅 | 3 | 2026-08-26 | 2026-08-27 | T008-02 |
| T008-05 | Restore purchases | 📅 | 2 | 2026-08-27 | 2026-08-27 | T008-04 |
| T008-06 | Subscription management | 📅 | 3 | 2026-08-28 | 2026-08-29 | T008-04 |
| T008-07 | Entitlement persistence | 📅 | 2 | 2026-08-29 | 2026-08-29 | T008-05 |
| T008-08 | StoreKit sandbox testing | 📅 | 3 | 2026-08-29 | 2026-08-30 | T008-07 |

---

## EPIC E009: Asset Production

**Status:** 📅 Not Started | **Est SP:** 55

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T009-01 | App icon (all sizes) | 📅 | 2 | 2026-07-01 | 2026-07-02 | E002 |
| T009-02 | 12 building designs (idle factory style) | 📅 | 13 | 2026-07-07 | 2026-07-15 | E003 |
| T009-03 | Moth courier animation (flying to moon) | 📅 | 8 | 2026-07-15 | 2026-07-21 | T009-02 |
| T009-04 | Moon restoration visual sequence | 📅 | 8 | 2026-07-21 | 2026-07-27 | T009-03 |
| T009-05 | Factory background + ambient art | 📅 | 5 | 2026-07-27 | 2026-07-29 | T009-02 |
| T009-06 | UI components (buttons, panels, bars) | 📅 | 5 | 2026-07-29 | 2026-07-31 | E002 |
| T009-07 | Cosmetic theme artwork (3 packs) | 📅 | 8 | 2026-08-01 | 2026-08-07 | E002 |
| T009-08 | Background ambient music (2 tracks) | 📅 | 3 | 2026-08-01 | 2026-08-03 | None |
| T009-09 | SFX (building tap, milestone, reset) | 📅 | 3 | 2026-08-03 | 2026-08-05 | None |

---

## EPIC E010: QA & Testing

**Status:** 📅 Not Started | **Est SP:** 21

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T010-01 | Unit test coverage ≥ 80% | 📅 | 5 | 2026-09-01 | 2026-09-05 | E009 |
| T010-02 | Performance testing (Instruments) | 📅 | 3 | 2026-09-05 | 2026-09-07 | E007 |
| T010-03 | Memory leak audit | 📅 | 2 | 2026-09-07 | 2026-09-08 | T010-02 |
| T010-04 | IAP sandbox full test suite | 📅 | 3 | 2026-09-08 | 2026-09-09 | E008 |
| T010-05 | Offline earnings accuracy tests | 📅 | 3 | 2026-09-09 | 2026-09-10 | E005 |
| T010-06 | Device matrix testing (iPhone 12–16) | 📅 | 3 | 2026-09-10 | 2026-09-12 | E007 |
| T010-07 | Accessibility (VoiceOver) | 📅 | 2 | 2026-09-12 | 2026-09-13 | E007 |

---

## EPIC E011: Beta & Launch

**Status:** 📅 Not Started | **Est SP:** 21

| Task ID | Task | Status | Est SP | Est Start | Est End | Dependencies |
|---------|------|--------|--------|-----------|---------|--------------|
| T011-01 | TestFlight private beta (500 users) | 📅 | 3 | 2026-10-15 | 2026-11-15 | E010 |
| T011-02 | Beta feedback integration | 📅 | 8 | 2026-11-01 | 2026-11-30 | T011-01 |
| T011-03 | Public beta (5,000 users) | 📅 | 3 | 2026-12-01 | 2026-12-31 | T011-02 |
| T011-04 | App Store submission | 📅 | 3 | 2027-01-01 | 2027-01-07 | T011-03 |
| T011-05 | Launch day execution | 📅 | 4 | 2027-01-15 | 2027-01-15 | T011-04 |

---

## Summary Dashboard

| Epic | Name | Total SP | Status | Est Start | Est End |
|------|------|---------|--------|-----------|---------|
| E001 | Documentation | 21 | ✅ | 2026-06-27 | 2026-06-27 |
| E002 | Xcode Setup | 10 | 🔄 | 2026-07-01 | 2026-07-03 |
| E003 | Data Models | 18 | 🔄 | 2026-07-03 | 2026-07-08 |
| E004 | Production Engine | 26 | ✅ | 2026-07-08 | 2026-07-17 |
| E005 | Offline Earnings | 13 | 🔄 | 2026-07-17 | 2026-07-22 |
| E006 | Prestige System | 21 | 🔄 | 2026-07-22 | 2026-07-30 |
| E007 | SwiftUI Interface | 55 | 🔄 | 2026-08-01 | 2026-08-23 |
| E008 | Monetization | 21 | 📅 | 2026-08-24 | 2026-08-30 |
| E009 | Asset Production | 55 | 📅 | 2026-07-01 | 2026-08-07 |
| E010 | QA & Testing | 21 | 📅 | 2026-09-01 | 2026-09-13 |
| E011 | Beta & Launch | 21 | 📅 | 2026-10-15 | 2027-01-15 |
| **TOTAL** | | **282** | | **2026-06-27** | **2027-01-15** |

---

*Last Updated: 2026-06-28*
