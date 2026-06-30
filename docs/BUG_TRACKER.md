# Bug Tracker — Moonloom: Idle Dream Factory (moonloom)

**Game:** Moonloom: Idle Dream Factory
**Platform:** iOS 17.0+
**Last Updated:** 2026-06-30

---

## Legend

| Field | Values |
|-------|--------|
| **Status** | 🔴 Open / 🟡 In Progress / 🟢 Closed / ⚫ Deferred / 🔵 Cannot Reproduce |
| **Severity** | P0 (Crash) / P1 (Major) / P2 (Minor) / P3 (Cosmetic) |
| **Type** | Crash / Logic / UI / Performance / IAP / Data / Audio |

---

## Active Bugs

No active P0/P1/P2 bugs are currently known on `codex/production-readiness`.
The production build-out (MOONLOOM-PROMPT-009) builds clean and passes all 119
tests on an iPhone 17 simulator.

**Risks now mitigated by implementation:**
- RISK-005 (stale subscription): `PurchaseManager` reconciles entitlements from
  `Transaction.currentEntitlements` on every launch and on each transaction update.
- RISK-006 (offline entitlement check): entitlements persist in `EntitlementRecord`
  and drive gameplay offline-first, reconciled with StoreKit when available.
- RISK-007 (notification while open): reminders are scheduled only on background
  and cancelled on foreground.
- RISK-008 (reset/tick race): `performPrestige` stops the engine before reset.
- Corrupt store: `AppDatabase` now deletes a bad on-disk store and recreates it
  fresh (durable) before falling back to in-memory.

---

## Closed Bugs

| Bug ID | Title | Severity | Type | Status | Date | Device | Steps | Expected | Actual | Root Cause | Fix | Fixed Date |
|--------|-------|----------|------|--------|------|--------|-------|----------|--------|-----------|-----|-----------|
| BUG-001 | Foundation build/tests not executed in authoring environment | P2 | Process / CI | 🟢 | 2026-06-28 | N/A | Inspect foundation commits | Build/test should run on macOS | Authoring environment lacked Xcode | No macOS toolchain in original authoring session | Verified local Xcode build/test on 2026-06-29; added CI workflow on `codex/production-readiness` | 2026-06-29 |
| BUG-002 | GitHub Actions CI not verified on remote | P2 | Process / CI | 🟢 | 2026-06-29 | GitHub Actions | Push `codex/production-readiness` | GitHub Actions runs build/test for the branch | CI workflow did not exist before this branch | Missing iOS CI workflow | Added `.github/workflows/ios-ci.yml`, pushed branch, and verified `iOS CI` passed remotely | 2026-06-29 |
| BUG-003 | Number formatter renders 999,999 as 1000K | P2 | UI / Logic | 🟢 | 2026-06-29 | iPhone 17 simulator | Run `NumberAbbreviatorTests.testRolloverDoesNotProduce1000K` | `999_999` renders as `1M` | Formatter returned `1000K` | Rollover guard checked unrounded scaled value before display rounding | Roll up suffix when rounded scaled value reaches 1000 | 2026-06-29 |
| BUG-004 | SwiftData save/load/delete failures are silently ignored | P1 | Data | 🟢 | 2026-06-29 | iPhone 17 simulator | Inspect repository and milestone persistence paths | Persistence errors should propagate and be visible | `try?` discarded fetch/save/delete errors | Repository and milestone service APIs swallowed thrown SwiftData failures | Converted persistence APIs to throw, added root data warning, and covered save/load/delete with SwiftData tests | 2026-06-29 |

---

## Pre-Development Risk Register

| Risk ID | Area | Description | Likelihood | Mitigation |
|---------|------|-------------|-----------|-----------|
| RISK-001 | Production Engine | Timer drift causing incorrect CPS over time | Medium | Use precise Date comparison, not cumulative timer |
| RISK-002 | Production Engine | Double-tick on app resume from background | Medium | Track lastTickTimestamp precisely, resume from exact point |
| RISK-003 | SwiftData | Performance degradation with 100+ building records | Low | Use @Transient for computed values, minimize @Model mutations |
| RISK-004 | Offline Calc | Earnings calculation overflow (Double precision) | Low | Use BigDecimal or Decimal for large numbers |
| RISK-005 | StoreKit 2 | Subscription status stale (not refreshed) | Medium | Refresh on every app launch, not just purchase |
| RISK-006 | StoreKit 2 | Offline entitlement check fails | Low | Cache last known entitlement state locally |
| RISK-007 | Notifications | Notification fires while app is open | Medium | Check app state before scheduling |
| RISK-008 | Prestige | Race condition between reset and active production tick | Low | Use actor isolation, stop tick before reset |
| RISK-009 | Performance | Expensive re-renders on every production tick | High | Use @Observable + fine-grained updates, not full view refresh |
| RISK-010 | Audio | Background audio interrupted by calls/media | Medium | Use AVAudioSession .ambient category, duck properly |

---

## Bug Filing Template

```markdown
### BUG-[XXX]: [Short Title]

**Severity:** P0/P1/P2/P3
**Type:** Crash/Logic/UI/Performance/IAP/Data/Audio
**Status:** 🔴 Open
**Date:** YYYY-MM-DD
**Device:** [Model] / iOS [version]
**App Version:** [version] / Build [number]

#### Steps to Reproduce
1. 
2. 
3. 

#### Expected


#### Actual


#### Frequency
[ ] Always [ ] Sometimes (__%) [ ] Rare [ ] Cannot Reproduce

#### Attachments
- Screenshots:
- Crash log:
- Console:

#### Notes

```

---

## Statistics

| Metric | Count |
|--------|-------|
| Total Filed | 4 |
| Open 🔴 | 0 |
| In Progress 🟡 | 0 |
| Closed 🟢 | 4 |
| Deferred ⚫ | 0 |
| P0 Crashes | 0 |
| P1 Major | 0 |

---

*Bugs must be filed immediately when discovered. Never ship with P0 or P1 bugs.*
*Last Updated: 2026-06-29*
