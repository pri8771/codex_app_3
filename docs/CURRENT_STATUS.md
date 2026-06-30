# Current Status — Moonloom: Idle Dream Factory

**Last updated:** 2026-06-30
**Repository:** `pri8771/moonloom`
**Active development branch:** `codex/production-readiness`
**Open implementation PR:** https://github.com/pri8771/moonloom/pull/1
**Production-readiness PR:** https://github.com/pri8771/moonloom/pull/2
**Notion build hub:** https://app.notion.com/p/38eab1f2276581959e1ecc46b07557de

## Summary

Moonloom is now a feature-complete, end-to-end playable SwiftUI/SwiftData idle
game, estimated **~85% production ready**. Phases 1–4 (foundation, idle loop,
factory polish, economy expansion) plus the previously-queued Phases 5–8
(prestige/Lunar Codex, story/achievements/retention, monetization, polish) are
implemented. What remains is mostly off-repo launch work: real App Store Connect
product configuration + sandbox-device IAP testing, final audio/art assets,
broad device/accessibility QA, performance profiling, and TestFlight.

## Verified Locally (2026-06-30)

- Xcode 26.6, iPhone 17 simulator.
- `xcodebuild build` succeeds with no warnings.
- `xcodebuild test` runs **119 tests, 0 failures** (was 89; +30 new across Lunar
  Codex, achievements, daily rewards, entitlements/cosmetics, and v2 persistence).
- App installs and launches on the simulator; onboarding renders correctly.

## Economy model — DECISION RESOLVED

The previously-open question is now **closed**: the **single-Moonlight production
economy** is canonical. All 12 tiers produce Moonlight with Moonlight-denominated
costs; the canonical README/PRD tier *names* are kept. Stardust comes from orders,
achievements, daily logins, and IAP; Lucid Shards come from prestige. This is the
shipped, balanced model and supersedes the PRD's multi-currency chain (documented
divergence, not a PRD rewrite).

## Implemented

### Core (Phases 1–4)
- SwiftUI app shell, 4-tab navigation (Factory / Moon / Shop / Settings).
- `AppContainer` lifecycle coordinator, `GameState` source of truth.
- `ProductionEngine` actor, 12 production tiers, building purchase/unlock/upgrade.
- Milestone global multiplier, Dream Orders, Moon Restoration biome nodes.
- Offline earnings + welcome-back modal, prestige math, SwiftData persistence.

### New this session (Phases 5–8 + polish)
- **Lunar Codex** — 10 permanent prestige upgrades bought with Lucid Shards
  (all-production, tier-range, offline-cap, offline-efficiency, prestige-scaling,
  and starting-Moonlight effects); persists across resets; `LunarCodexView`.
- **Achievements** — 38-achievement catalog across 5 categories with a pure
  evaluator, one-time Stardust rewards, celebration toasts, and `AchievementsView`.
- **Daily login rewards** — streak-based Stardust (5→20), `DailyRewardView` modal,
  consecutive-day/gap streak logic.
- **Statistics** — `StatisticsView` deriving production/factory/restoration/
  currency stats from game state.
- **Onboarding** — three-page first-launch tutorial, persisted completion.
- **StoreKit 2 monetization** — `PurchaseManager` (load/purchase/restore/
  transaction-listener/entitlement reconciliation), `Moonloom.storekit` config
  wired into the scheme, entitlement persistence, and a Shop wired to real
  purchases with owned/Pass state. Effects applied: Stardust packs, Offline
  Expansion (12h), Moonloom Pass (2× offline + 48h cap), cosmetic themes.
- **Cosmetic themes** — `ThemePalette` (Moonlit / Celestial / Ember) that re-skins
  the whole app; owned-theme picker in Settings.
- **Local notifications** — `NotificationManager` schedules offline-cap/8h/24h
  reminders on background, cancels on foreground, permission-gated.
- **Design system** — token-based `Theme` (spacing/radius/components), a
  programmatically-rendered 1024 app icon (full moon + dreamthread ring), and
  reusable card/button styles.
- **Persistence v2** — new `@Model` records (Achievement, LunarCodex, Entitlement),
  schema v2 with lightweight migration, and a hardened container-recovery policy
  (corrupt store → fresh on-disk store, never an in-memory-only surprise).
- **Accessibility** — VoiceOver labels across new screens; reduced-motion respected.

## Not Yet Done (remaining ~15%)

- Real App Store Connect products + StoreKit **sandbox-device** purchase testing
  (the local `.storekit` config covers in-Xcode testing only).
- Final audio assets — `AudioService` is still an inert, safe stub (no SFX/music
  files). Notification copy and haptics are wired; audio playback is not.
- Richer bespoke art / animation beyond SF Symbols + procedural rendering.
- Full device matrix + a complete VoiceOver/Dynamic Type audit.
- Instruments performance + memory profiling pass.
- TestFlight private beta + App Store submission assets.

## Immediate Next Steps

1. Configure products in App Store Connect; run sandbox IAP on device.
2. Produce/integrate ambient music + SFX behind the existing `AudioService`.
3. Device-matrix + accessibility QA; Instruments profiling.
4. TestFlight build → private beta.
