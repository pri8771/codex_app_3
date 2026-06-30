# Moonloom — Launch Readiness (v1)

> **Moonloom** is a cozy, offline-first idle/incremental iOS game: you run a small dream factory that harvests *whispers* from sleeping towns, spins them into *dreamthread*, weaves them into *dreams*, and restores a faded moon — all of which keeps producing while the app is closed. It targets casual players who enjoy calm, low-pressure progression in short check-ins. **Implementation maturity: pre-build / docs-only.** The repository today contains only Markdown (a README, a canonical `PROJECT_DOCUMENTATION.md`, nine PRDs, and three trackers). There is **no Xcode project, no Swift Package, no source code, and no tests** (verified: `find` over the repo returns zero `.swift`/`.xcodeproj`/`Package.swift`/`.storekit`/`Info.plist`/`.xcprivacy` files). The existing docs describe a far larger product than v1 should attempt (12+ production tiers, five currencies, prestige, subscriptions, events, achievements, cosmetics). Per the Codex↔Claude product conversation (`Moonloom.md`), **v1 is deliberately cut to an economy prototype**: 3 stations, 1 resource chain, 1 restoration milestone, 1 soft currency, and a real offline-earnings calculation — built first as a **headless, testable Swift simulation** before any SwiftUI/SpriteKit. This document is the authoritative build-to spec for that v1; the larger docs are reconciled to it.

---

## 1. PRD / Launch Scope

### Problem & insight
Idle/incremental games are a large, durable mobile genre, but the dominant titles look dated and feel mechanically noisy. The opportunity is a *cozy* idle game: calm aesthetics, honest math, no manipulation. The core insight is genre-specific: **an idle game lives or dies on whether the first five minutes and the first offline return feel satisfying** — a beautiful fiction cannot rescue a brittle or confusing economy. Therefore v1 must prove the *economy* in a simulation before any art or screens are built.

### Target user
- **Primary:** Casual mobile players (≈25–40) who enjoy "numbers go up" progression in short 2–5 minute sessions (commute, lunch, before bed) and want a calm, attractive game rather than an aggressive one.
- **Secondary:** Cozy-game fans drawn by the moon/dream aesthetic who may not normally play idle games, plus the r/incremental_games community as early adopters and balance critics.

### Value proposition (one sentence)
A cozy, offline-first idle game where a small dream factory keeps weaving and restoring the moon while you're away — honest math, no energy gates, no FOMO.

### Positioning / category & pitch
- **Category:** Casual Games › Idle / Incremental.
- **One-sentence pitch:** *"While the world sleeps, your factory dreams."* — a calm idle game about restoring the moon, one whisper at a time.

### Platform & tech baseline
- **Platform:** iOS (target iOS 17.0+, per existing docs).
- **Language/UI (planned):** Swift 5.9+, SwiftUI. **SpriteKit is not required** for v1.
- **v1 build order (decisive):** the economy ships first as a **pure-Swift, UI-independent, deterministic simulation** in a Swift Package (testable with XCTest / Swift Testing, no simulator needed). SwiftUI is layered on only after the economy curve is tuned.
- **Persistence:** local only. Start with `Codable` + a single save file (or `UserDefaults` for the prototype); SwiftData is **optional** and deferred until the model is stable — it is not needed to prove the loop.
- **Networking:** none. Fully offline.
- **Dependencies:** Apple frameworks only; no third-party packages.

### Business model (only what the repo supports/plans)
- v1 ships with **no monetization** — the loop must earn trust first (explicit conclusion of `Moonloom.md`).
- Post-v1, monetization must be **cozy-compatible only**: optional **time-skips** and **cosmetic skins** (moth/town/factory themes). **Never** energy gates, punitive timers, loot boxes, forced ads, or FOMO events — these are explicitly forbidden by the conversation and the `MONETIZATION_PRD.md` "Anti-Patterns" table.
- Note: existing docs are internally inconsistent on pricing model — `BUSINESS_PLAN_PRD.md` says "free-to-play with IAP" while `README`/`PROJECT_DOCUMENTATION.md` call it "premium aesthetic." v1 resolves this as **free, no IAP**; the pricing decision is deferred and out of scope for v1.

### North-star / success signals
v1 is pre-beta, so success is **simulation-observable**, not user-metric-observable:
- **Time-to-first-milestone** falls in a tuned, intentional window (not seconds, not hours).
- **Offline-earnings curve** is sane: rewarding but capped, never runaway.
- **Each upgrade meaningfully changes pace** (a measurable change in production rate / time-to-next-goal).
- Later beta signals (local-only analytics, privacy-respecting): D1/D7 retention, offline-reward claim rate, session length — but these are **not** v1 gates.

---

## 2. MVP Feature List (with acceptance criteria)

> Status legend: **Built** = implemented in repo; **Partial** = partially present; **Not built** = specified here but no code exists yet. Because the repo is docs-only, **every feature below is Not built** and these are the build-to acceptance criteria. They are intentionally scoped to the v1 economy prototype, not the 12-tier doc fantasy.

### F1. Resource & wallet model — Status: **Not built**
One-line: A single soft currency plus the intermediate resources of the one production chain, held in a deterministic wallet.
- Given a fresh game, When initialized, Then the wallet holds exactly the v1 resources (`whispers`, `dreamthread`, and the woven `dream` count) at their defined starting values, with no other currencies present.
- The wallet exposes `amount(of:)`, `add(_:to:)`, and `canAfford(_:)`; all mutations go through these methods (no ad-hoc arithmetic on stored fields).
- All amounts use `Double`; values are clamped to be finite and `>= 0` after every mutation (no `NaN`/`Infinity`, no negative balances).
- Unit tests cover: starting state, add/spend, and affordability at boundary (exact cost).

### F2. Three production stations / one resource chain — Status: **Not built**
One-line: Three stations forming a single chain — Whisper Net (produces whispers) → Dreamthread Spindle (whispers → dreamthread) → Dream Loom (dreamthread → woven dream).
- Each station has: `id`, `count` (owned), `baseRate` (per second at count=1), and an input/output definition; all values come from a central `EconomyConfig` (no scattered literals).
- Given station counts and a `deltaTime`, When the engine ticks, Then each station consumes its required input and produces its output proportional to `count × baseRate × deltaTime`, and a station produces **0** when it lacks sufficient input (no negative balances, no "free" output).
- The chain is genuinely coupled: Spindle output is gated by available whispers; Loom output is gated by available dreamthread (verified by a test that starves an upstream resource).
- Exactly three stations exist in v1; tiers 4–12 are absent from the config.

### F3. Buy / upgrade stations with scaling cost — Status: **Not built**
One-line: Spend the soft currency to add station instances, with exponential cost scaling, plus 3–4 upgrade steps that boost a station's rate.
- Building cost follows `cost(n) = baseCost × growth^count` (e.g. growth 1.15); `cost` is computed, never stored stale.
- Given the player can afford a station, When they buy it, Then the currency is deducted exactly once, `count` increments by 1, and the next cost rises per the formula; When they cannot afford it, Then the purchase is rejected and state is unchanged.
- 3–4 upgrade steps exist within the chain; purchasing an upgrade applies a multiplier to the target station's effective rate and is one-time (idempotent — re-purchase is rejected).
- Unit tests cover: successful buy, rejected buy (insufficient funds), cost progression across several buys, and upgrade multiplier application.

### F4. Real-time production tick — Status: **Not built**
One-line: A deterministic tick that advances the economy by a supplied `deltaTime`, independent of any UI or wall clock.
- The engine exposes a pure `tick(deltaTime:)` (or `advance(by:)`) that is fully deterministic: identical inputs produce identical outputs (verified by a same-input/same-output test).
- Time is injected via a `TimeProvider` abstraction (no direct `Date()` inside the engine), so tests can fast-forward simulated time.
- A 60-minute simulated playthrough produces no `NaN`/`Infinity` and no negative balances (long-run stability test).
- The tick contains **no** SwiftUI, persistence, or I/O calls — economy logic is UI-independent.

### F5. Offline-earnings calculation — Status: **Not built**
One-line: On return, compute what the factory earned while away, honestly capped, and surface it as a single "collect" moment.
- Given a `lastActiveTimestamp` and the current time, When the game resumes, Then offline duration = `min(elapsed, offlineCapSeconds)` (default cap 2h for v1) and earnings are computed from the same production model as the live tick (single source of truth — no divergent offline math).
- An offline **efficiency factor** (e.g. 50%) is applied and configurable in `EconomyConfig`.
- Negative or zero elapsed time (clock moved backward, instant resume) yields **zero** offline earnings and never corrupts state (clock-manipulation guard).
- The result is returned as an `OfflineSummary` (duration applied, cap-hit flag, per-resource earned) that a "Welcome back" beat can render later; for v1 this is asserted in tests, not necessarily shown on screen.
- Unit tests cover: no earnings on first launch, basic earnings after 1h, cap enforcement at 2h, efficiency multiplier, and the backward-clock guard.

### F6. One restoration milestone — Status: **Not built**
One-line: A single visible goal — "restore the first shard of moonlight" — reached by accumulating woven dreams, giving the prototype a finish line.
- A milestone is defined in config with a threshold (e.g. N woven dreams or N moonlight) and a one-time "reached" state.
- Given the player crosses the threshold, When the engine evaluates milestones, Then the milestone flips to reached exactly once and stays reached (idempotent; does not re-fire).
- Progress toward the milestone is queryable (0–1 fraction) so a UI/test can show "next goal."
- v1 has **exactly one** milestone; no moon-phase ladder, no prestige unlock attached to it.

### F7. Local persistence (save / load) — Status: **Not built**
One-line: The full game state survives app relaunch without loss, using a single local store.
- Given any valid game state, When it is saved and reloaded, Then the reconstructed state is byte-equivalent in all economy fields (round-trip test), including `lastActiveTimestamp`.
- A missing or unreadable save yields a clean fresh game (no crash); a corrupt save fails safe to a new game rather than propagating bad state.
- Save is triggered on background/quit and after claiming offline earnings; load is triggered on launch.
- Persistence is local only — no network, no account.

### F8. Headless simulation harness — Status: **Not built**
One-line: A test/CLI harness that fast-forwards simulated time and prints the economy curve, so balance can be inspected before any screen exists.
- The harness can run N simulated minutes/hours at a chosen `deltaTime` and report: currency totals over time, time-to-first-milestone, and per-upgrade pace change.
- It runs with **no simulator and no UI** (pure Swift, executable as tests or a small `main`).
- It is the tool used to validate the §1 north-star signals (time-to-first-milestone window, offline curve sanity, upgrade impact).

---

## 3. Out of Scope (v1 non-goals)

Explicitly **not** in v1, and why:
- **New Moon Reset / prestige (Lucid Shards, Lunar Codex).** Prestige only has meaning once the base loop is satisfying enough that resetting feels like a worthwhile trade. Deferred until the base economy is tuned. (Conversation decision.)
- **Production tiers 4–12** (Memory Looms through Moonheart Engine). Beyond ~3–4 upgrade steps this is content work, not concept validation.
- **Multiple currencies** (Moonlight as a separate currency, Stardust, Lucid Shards). v1 uses **one** soft currency plus the chain's intermediate resources; more currencies just multiply the balancing surface.
- **All monetization** — StoreKit 2, IAP, subscriptions (Moonloom Pass), Stardust bundles, offline-expansion purchase. No revenue in v1; loop must earn trust first.
- **Energy gates, punitive timers, loot boxes/gacha, forced ads, FOMO/seasonal events.** Explicitly forbidden as incompatible with "cozy."
- **Achievements** (the docs' 50–200 set), **daily login rewards**, **sleeping-regions screen**, **collection screen**, **leaderboards**.
- **Cosmetics shop and skins** (moth/town/factory themes). Cozy-compatible later, but not v1.
- **Local notifications** (8h/24h "come back" reminders). Deferred; v1 must not nag.
- **Art, animation, audio, onboarding/tutorial polish, SpriteKit visuals.** v1 proves math, not pixels.
- **SwiftData as a requirement.** v1 uses the simplest local persistence; a SwiftData migration is optional and post-prototype.
- **Cloud save, remote balance config, server-side receipt validation, analytics SDKs.** Offline-first, local-only.

---

## 4. User Flows

> v1 is a headless economy prototype; the flows below describe the *intended* player experience the simulation must support. Screen names are aspirational (no screens exist yet) and are flagged as such.

### 4.1 First run / onboarding
1. App launches into a fresh game; the wallet starts with the v1 starting balance (F1).
2. The player is shown the one open station (Whisper Net) and a single clear goal: restore the first shard of moonlight (F6). *(Screen: Factory — not yet built.)*
3. Whispers begin accumulating immediately (numbers rise within seconds) so the first purchase is affordable quickly.
4. No account, no network, no permission prompts.

### 4.2 Core loop
1. Whisper Nets produce whispers passively (F4).
2. The player buys a Dreamthread Spindle; whispers convert to dreamthread (F2/F3).
3. The player buys a Dream Loom; dreamthread converts to woven dreams (F2).
4. The player buys additional station instances and 1–3 upgrades, each visibly accelerating production (F3).
5. Accumulated woven dreams advance the restoration milestone; progress toward "next goal" is always visible (F6).
6. The player crosses the milestone — the single satisfying "shard restored" beat fires once (F6).

### 4.3 Offline return
1. The player closes the app; `lastActiveTimestamp` is saved (F7).
2. On reopening, the engine computes capped, efficiency-adjusted offline earnings (F5).
3. A single "Welcome back — your couriers were busy" collect moment summarizes earnings; the player taps **Collect** to apply them. *(Modal — not yet built; asserted in tests for v1.)*
4. State is saved immediately after collecting.

### 4.4 Settings / privacy
1. v1 has no settings screen requirement beyond what persistence needs. *(Settings — deferred.)*
2. Privacy posture is trivially clean: no data leaves the device, no tracking, no network. This is recorded for App Store privacy disclosure (§9).

### 4.5 Share / export
- Out of scope for v1 (no share/export feature).

---

## 5. Acceptance Criteria Summary

| ID | Feature | Status | Launch gate (pass/fail) |
|----|---------|--------|--------------------------|
| F1 | Resource & wallet model | Not built | Wallet holds only v1 resources; no negative/NaN balances; tested. |
| F2 | 3 stations / 1 chain | Not built | Three coupled stations produce correctly; starved input yields 0 output; tested. |
| F3 | Buy / upgrade with scaling cost | Not built | Exponential cost correct; buys deduct once; 3–4 upgrades apply multipliers; tested. |
| F4 | Real-time production tick | Not built | Deterministic `tick(deltaTime:)`; injected time; 60-min sim is NaN/Infinity-free; UI-independent. |
| F5 | Offline earnings | Not built | Capped + efficiency-adjusted; shares live math; backward-clock guard; tested. |
| F6 | One restoration milestone | Not built | Single milestone flips once and stays; progress queryable. |
| F7 | Local persistence | Not built | Round-trip equivalent; corrupt/missing save fails safe; local-only. |
| F8 | Headless sim harness | Not built | Fast-forwards time with no UI; reports curve, time-to-milestone, upgrade impact. |

**Overall launch gate for v1 (economy prototype):** all of F1–F8 pass their tests, the harness shows a tuned and stable curve, and the core loop runs end-to-end in simulation. UI/store/content are explicitly *not* gates for the prototype milestone.

---

## 6. Known Limitations

- **No code exists yet.** Everything above is a build-to spec; nothing is implemented or verified at runtime.
- **Docs are heavily over-scoped.** The README, `PROJECT_DOCUMENTATION.md`, PRDs, and `PROJECT_TRACKER.md` describe a 12-tier, 5-currency, prestige+subscription product. v1 deliberately implements a small subset; the docs have been annotated to point at this file as the authoritative scope.
- **Balance numbers are placeholders.** Costs, rates, caps, and the milestone threshold in `EconomyConfig` must be tuned via the harness; the doc-supplied numbers (e.g. tier costs `10 → 30B`) are illustrative of the *deferred* full game, not v1.
- **Persistence approach is intentionally minimal.** v1 uses simple `Codable` local save; SwiftData, migrations, and schema versioning are deferred, which means a future SwiftData migration is unaddressed in v1.
- **No offline "welcome back" UI in the prototype.** Offline earnings are computed and tested but may only be surfaced in logs/tests until the SwiftUI layer lands.
- **Pricing model unresolved.** "Premium aesthetic" vs "free-to-play with IAP" is contradicted across docs; v1 ships free with no IAP and defers the decision.
- **Single device, single locale.** No iCloud sync, no localization; English-only assumptions.
- **Timer/resume edge cases are spec'd but unproven.** Background double-tick and timer drift (see the docs' own RISK-001/002) are designed against (injected time, timestamp-based offline calc) but not yet validated in code.

---

## 7. Bug & Risk Triage

> The repo has no code, so there are no runtime bugs to triage. The "launch-blocking" list is therefore the set of **must-build / must-decide gaps** that block any TestFlight, plus real product/safety/privacy/content risks. The "non-blocking" list is ship-with-and-fix-later items.

### Launch-blocking (must resolve before TestFlight / App Store)

| ID | Description | Where | Why blocking |
|----|-------------|-------|--------------|
| LB-1 | **No buildable app target.** No Xcode project / Swift Package, no `@main` entry, no source. | entire repo (`find` shows 0 source files) | There is nothing to run, test, or submit. The v1 economy package (F1–F8) must be created first. |
| LB-2 | **No economy engine.** The core loop (F2–F5) that defines the product does not exist. | n/a (spec only) | An idle game with no economy is not testable or playable; this is the product. |
| LB-3 | **No tests / no harness.** No XCTest target, no simulation harness (F8). | n/a | v1's entire success gate is simulation-observable balance; without tests the loop cannot be validated. |
| LB-4 | **No persistence implementation.** Save/load (F7) is unwritten. | n/a | Idle games must not lose progress; data loss is an automatic P0 for this genre. |
| LB-5 | **Offline-earnings correctness + clock-manipulation guard unbuilt.** (F5) | n/a | Incorrect offline math or a backward-clock exploit corrupts the economy and player trust; must be correct before any beta. |
| LB-6 | **Scope not reconciled in shipping config.** Docs still imply 12 tiers / 5 currencies / prestige / IAP as the build target. | README, PRDs, `PROJECT_TRACKER.md` | Building to the over-scoped docs instead of v1 wastes the prototype and risks shipping an untuned, monetized game. (Mitigated by this file + doc notes; the *config* must encode only v1.) |
| LB-7 | **No PrivacyInfo / privacy posture asserted for submission.** | n/a (no Info.plist / `.xcprivacy`) | App Store now requires accurate privacy disclosure; even a zero-collection app must declare it. Must exist before submission. |
| LB-8 | **No age rating / content review decision.** | docs | Required App Store metadata; trivial here (no UGC, no ads) but must be set. |

### Non-blocking (ship-with, fix later)

| ID | Description | Rationale for deferral |
|----|-------------|------------------------|
| NB-1 | No SwiftUI screens / art / audio. | v1 is a headless economy milestone; UI is the *next* phase, not a prototype gate. |
| NB-2 | No "Welcome back" modal UI. | Offline math is tested; the visual beat can follow once SwiftUI lands. |
| NB-3 | No SwiftData / schema migration. | Simple `Codable` save is sufficient to prove the loop; migrate later. |
| NB-4 | No local notifications. | Cozy posture prefers no nagging; add carefully post-loop, opt-in. |
| NB-5 | No achievements / daily rewards / regions / collection. | Deferred content; not needed to validate the economy. |
| NB-6 | Balance numbers untuned. | Expected — tuning is the *purpose* of the harness; iterate, don't block. |
| NB-7 | Pricing model undecided. | v1 has no monetization; decide before any paid build, not before the prototype. |
| NB-8 | Doc trackers (`PROJECT_TRACKER.md` 282-SP plan) reflect the old scope. | Historical/aspirational; superseded by §8 here, can be rewritten incrementally. |
| NB-9 | No localization / iCloud sync. | Single-locale, single-device is fine for v1 and early beta. |

---

## 8. Production-Readiness Assessment

### Current estimated readiness: **8%**
Justification: The product is well-specified and the v1 scope is now crisp and decided (strong planning), but **zero implementation exists** — no project, no engine, no tests, no persistence, no UI. For a game whose entire v1 is "make the economy run and prove it in tests," planning without code is roughly 8% of the way to a production-ready prototype. (It is not 0% because the scope cut, feature list, formulas, and acceptance criteria are concrete enough to build against directly.)

### Ordered remaining work to reach 80–90% production-ready
*(80–90% here = the v1 economy prototype runs end-to-end with passing tests and a tuned curve; it does not include shipping polished UI/store, which is a later milestone.)*

1. **Scaffold the project.** Create a Swift Package `MoonloomCore` (pure Swift, no UI) plus an XCTest/Swift-Testing target. Add a thin iOS app target later; the package must build and test from the command line.
2. **Implement `EconomyConfig`** — single source of truth for the 3 stations, costs, growth factor, baseRates, offline cap + efficiency, and the milestone threshold. No literals elsewhere.
3. **Build F1 wallet + F2 stations/chain** with clamping (finite, non-negative) and input-gated production. Write their unit tests.
4. **Build F3 buy/upgrade** (exponential cost, single deduction, 3–4 idempotent upgrades) + tests.
5. **Build F4 deterministic `tick(deltaTime:)`** with an injected `TimeProvider`; add the same-input/same-output and 60-minute NaN/Infinity/negative-balance stability tests.
6. **Build F5 offline calculation** sharing F4's production model; cap + efficiency + backward-clock guard + `OfflineSummary`; add the full offline test set.
7. **Build F6 milestone** (single, idempotent, progress fraction) + test.
8. **Build F7 persistence** (`Codable` round-trip, fail-safe load) + round-trip and corrupt-save tests; wire save on background and after offline collect.
9. **Build F8 harness** and **tune the curve**: iterate `EconomyConfig` until time-to-first-milestone sits in the intended window, the offline curve is rewarding-but-capped, and each upgrade measurably changes pace. This tuning loop is the real point of v1.
10. **Reconcile shipping artifacts to v1:** ensure the config and any new docs encode only the 3-station scope; keep the larger PRDs clearly marked as deferred (done at the doc level; keep the *code* honest).
11. **Privacy + store metadata prep:** add `PrivacyInfo.xcprivacy` declaring zero data collection, set an age rating, and confirm "no network / no tracking" before any TestFlight (closes LB-7/LB-8).
12. *(Next milestone, beyond 90% of the prototype)* Layer SwiftUI: Factory screen, purchase buttons, milestone progress, and the "Welcome back" collect modal — driven entirely by `MoonloomCore`.

### Test-coverage summary
- **Currently tested:** nothing — there are **no tests and no code** in the repo.
- **What v1 must test (target):** wallet math (F1), chain coupling and input-starvation (F2), buy/upgrade economics (F3), tick determinism + long-run stability (F4), offline cap/efficiency/clock-guard (F5), milestone idempotency (F6), persistence round-trip + fail-safe load (F7), and an end-to-end harness run (F8). The TECHNICAL_PRD's aspirational "≥80% Domain coverage" is a reasonable target **for the economy package specifically**, since the package is pure logic and highly testable.

---

## 9. Launch Checklist

App Store / privacy / safety / content items specific to Moonloom:

- [ ] **Buildable target exists** — Swift Package `MoonloomCore` + app target compile and run; `swift test` passes (closes LB-1).
- [ ] **Core economy loop verified end-to-end** in the headless harness (F1–F8) with a tuned, stable curve (closes LB-2/LB-3/LB-5).
- [ ] **No data loss** — persistence round-trip and fail-safe load tests pass; save on background and after offline collect (closes LB-4).
- [ ] **Offline math is exploit-safe** — backward-clock and zero-elapsed cases yield zero earnings, never corruption.
- [ ] **`PrivacyInfo.xcprivacy` present and accurate** — declares **no data collected, no tracking, no network access** (Moonloom is fully offline) (closes LB-7).
- [ ] **App privacy "nutrition label"** in App Store Connect set to **Data Not Collected**.
- [ ] **Age rating set** — expected 4+ (no violence, no UGC, no ads, no gambling/loot-box mechanics) (closes LB-8).
- [ ] **No third-party SDKs / trackers** — confirm Apple-frameworks-only; no analytics that transmit off device.
- [ ] **Monetization disabled for v1** — no StoreKit products configured; if/when added, cosmetics + time-skips only, with restore-purchases and clear pricing (no FOMO copy).
- [ ] **No notifications nag** — if notifications are added later, they are opt-in and non-manipulative; v1 ships without them.
- [ ] **Content sign-off** — narrative/copy is calm and child-safe; no dark-pattern microcopy (verify against `MONETIZATION_PRD.md` anti-pattern table).
- [ ] **Accessibility baseline** (once UI exists) — Dynamic Type, VoiceOver labels on factory/purchase controls, sufficient contrast on the dark moonlit palette.
- [ ] **Performance baseline** (once UI exists) — tick is cheap, no runaway timers, steady-state memory reasonable; no background battery drain (offline is a calculation on resume, not a running background process).
- [ ] **Docs reconciled** — README/PROJECT_DOCUMENTATION/PRDs point to this file as the authoritative v1 scope; over-scoped sections clearly marked deferred.
- [ ] **TestFlight prerequisites** — bundle ID, signing, build upload, and a private tester group prepared once the prototype graduates to a UI build.

---

_Authored 2026-06-30. This `LAUNCH_READINESS.md` is the authoritative v1 build-to spec for Moonloom. The repository is pre-build (docs-only); where this file and the older PRDs disagree, this file governs the v1 launch scope._
