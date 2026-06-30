# Moonloom — Project Documentation

_Updated 2026-06-30 to match the shipped product and launch scope. See LAUNCH_READINESS.md._

GitHub is the source of truth for this project documentation. Notion indexes this file in the Priyansh App Factory Command Center.

> **Implementation status: pre-build / docs-only.** The repo currently contains only documentation — there is no Xcode project, Swift Package, source code, or tests. `LAUNCH_READINESS.md` (repo root) is the authoritative v1 build-to spec and **governs scope where it disagrees with the older PRDs**. The PRDs under `docs/prd/` describe the larger, deferred long-term game (12 tiers, 5 currencies, prestige, subscriptions); v1 is deliberately a much smaller economy prototype.

## 00. Executive Summary
Moonloom is a cozy, offline-first idle/incremental iOS game about rebuilding a dream factory that restores the moon. It is for casual players who enjoy calm progression, cozy visuals, and short check-ins. The **v1** product is intentionally scoped to a small, provable economy: one resource chain, three stations, one soft currency, a real offline-earnings calculation, and a single restoration milestone — built first as a headless, testable Swift simulation before any UI. Prestige, multiple currencies, monetization, achievements, and tiers 4–12 are explicitly deferred (see LAUNCH_READINESS.md §3).

## 01. Product
**v1 (economy prototype) scope:** one resource chain (whispers → dreamthread → woven dream), three stations, 3–4 upgrade steps, one soft currency, deterministic production tick, offline progress with an honest cap, one restoration milestone, and local persistence. Acceptance criteria: progress is reliable and deterministic, upgrades are understandable and visibly change pace, offline earnings are capped and exploit-safe, and save/load never loses state. Onboarding/tutorial, additional stations, and cosmetics are deferred to a later milestone.

## 02. Design
Cozy moonlit aesthetic with dream machinery, soft gradients, helpers, and calming feedback. Screens: factory overview, station detail, upgrade modal, offline rewards, restoration map, collection.

## 03. Frontend Technical
SwiftUI for the eventual UI. For **v1**, the economy ships first as a pure-Swift, UI-independent, deterministic simulation in a Swift Package (`MoonloomCore`), validated by XCTest and a headless harness before any screen is built. Economy logic must be deterministic and testable outside views, with time injected via a `TimeProvider`. Persistence for v1 is simple local `Codable` save; **SwiftData is optional and deferred** until the model is stable. Core models: ResourceWallet, StationState, Upgrade, EconomyConfig, OfflineSummary, RestorationMilestone.

## 04. Backend Technical
No backend for v1. Future services may include cloud save, remote events, remote balance config, and purchase validation.

## 05. Business
**v1 ships free with no monetization** — the loop must earn trust before any IAP is added. Post-v1, monetization is **cozy-compatible only**: optional time-skips and cosmetic skins (moth/town/factory themes). Never energy gates, punitive timers, loot boxes, forced ads, or FOMO events. (Note: older PRDs are inconsistent on "premium" vs "free-to-play"; v1 resolves this as free, no IAP, and defers the pricing decision.)

## 06. Marketing
Positioning: rebuild the dream factory and restore the moon. Channels: cozy game clips, restoration reveals, idle-game communities.

## 07. User Acquisition
Beta with cozy and idle-game players. Metrics: tutorial completion, offline reward claim, upgrade frequency, D1/D7 retention, payer interest.

## 08. Execution
Plan: audit prototype, freeze economy, stabilize stations/upgrades, implement offline progress, add restoration milestones, QA/TestFlight.

## 09. QA
Test save/load, station unlocks, upgrade costs, offline progress, app relaunch, long-session behavior, and economy edge cases.

## 10. Legal / Compliance
Keep v1 local if possible. Disclose data handling and purchase behavior if monetization or analytics are added.

## 11. Operations
Release process: internal economy test, small TestFlight, balance patch, launch decision. Post-launch: more stations, events, cosmetics, daily dreams.
