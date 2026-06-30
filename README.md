# Moonloom: Idle Dream Factory

> *"While the world sleeps, your factory dreams."*

_Updated 2026-06-30 to match the shipped product and launch scope. See [LAUNCH_READINESS.md](LAUNCH_READINESS.md)._

## Overview

**Moonloom: Idle Dream Factory** is a cozy, offline-first iOS idle/incremental game where a small dream factory harvests whispers from sleeping towns, spins them into dreamthread, weaves dreams, and restores the moon's faded light — and keeps producing while the app is closed.

> **Status: pre-build (docs-only).** This repository currently contains only documentation — there is no Xcode project, Swift Package, source code, or tests yet. [`LAUNCH_READINESS.md`](LAUNCH_READINESS.md) is the authoritative v1 build-to spec.
>
> **v1 is deliberately scoped down** to a provable economy prototype — **3 stations, 1 resource chain (whispers → dreamthread → 1 woven dream), 1 soft currency, a real offline-earnings calculation, and 1 restoration milestone** — built first as a headless, testable Swift simulation before any SwiftUI. The 12-tier / 5-currency / prestige / subscription product described below is the **deferred long-term vision**, not the v1 build target. See LAUNCH_READINESS.md §3 for the full out-of-scope list.

**Genre:** Idle / Incremental (cozy)
**Platform:** iOS 17.0+
**v1 tech:** Swift + SwiftUI; economy ships first as a pure-Swift `MoonloomCore` package with XCTest. SwiftData and StoreKit 2 are **deferred** (not in v1).
**Status:** 🔴 Pre-Build — Documentation Phase (no code yet)

---

## 🌙 The Story

The moon has gone dark. Sleeping towns have lost their dreams. As the keeper of the last Moonloom, you must rebuild the Dream Factory — harvesting whispers, spinning dreamthread, and weaving the dreams that power moonlight itself.

---

## 🏭 Core Loop

```
Sleeping Towns → Whispers → Dreamthread → Dreams → Moth Couriers → Moonlight → Upgrades → Moon Restoration → New Moon Reset (Prestige)
```

---

## 🏗️ Production Tiers — Long-Term Vision (DEFERRED, not v1)

> **v1 implements only the first three stations as one coupled chain:** Whisper Nets (whispers) → Dreamthread Spindles (whispers → dreamthread) → a Dream Loom (dreamthread → woven dream). The full 12-tier ladder below is the deferred long-term design; tiers 4–12 are **out of scope for v1** (see LAUNCH_READINESS.md §3).

| Tier | Building | Produces |
|------|----------|---------|
| 1 | Whisper Nets | Whispers |
| 2 | Lullaby Wells | Amplified Whispers |
| 3 | Dreamthread Spindles | Dreamthread |
| 4 | Memory Looms | Dream Fabric |
| 5 | Nightmare Filters | Purified Dreams |
| 6 | Star Dye Vats | Starlit Dreams |
| 7 | Moth Courier Nests | Dream Deliveries |
| 8 | Cloud Packaging Line | Packaged Shipments |
| 9 | Dream Atlas | Delivery Routes |
| 10 | Comet Shipping Dock | Express Deliveries |
| 11 | Lucid Observatory | Moonlight Amplification |
| 12 | Moonheart Engine | Moon Restoration |

---

## 💎 Currencies — Long-Term Vision (DEFERRED, not v1)

> **v1 uses ONE soft currency** plus the chain's intermediate resources (whispers, dreamthread, woven dreams). Moonlight-as-currency, Stardust, and Lucid Shards are **deferred**.

| Currency | Type | Source |
|----------|------|--------|
| Whispers | Soft (primary) | Whisper Nets, town sleeping cycles |
| Dreamthread | Soft (secondary) | Dreamthread Spindles |
| Moonlight | Soft (progression) | Moth Couriers delivering dreams |
| Stardust | Premium soft | Daily login, achievements, events |
| Lucid Shards | Prestige | Earned on New Moon Reset |

---

## 🌑 Prestige: New Moon Reset — Long-Term Vision (DEFERRED, not v1)

> **Prestige is explicitly deferred.** It only earns its place once the base loop is satisfying enough that resetting feels like a worthwhile trade. v1 ships a single restoration milestone and no reset.

When you restore enough of the moon, you can trigger a **New Moon Reset**:
- Factory resets to beginning
- Earn Lucid Shards based on restoration progress
- Lucid Shards → permanent upgrades (Lunar Codex)
- Each reset is faster and deeper than the last

---

## 📱 Tech Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI (iOS 17+) — added after the v1 economy is tuned
- **v1 economy:** pure-Swift `MoonloomCore` package (deterministic, UI-independent) + XCTest
- **Data (v1):** local `Codable` save; **SwiftData deferred** until the model is stable
- **Monetization (v1):** none; **StoreKit 2 deferred**
- **Architecture:** keep simulation logic out of views; inject time for testable offline calc
- **No Third-Party Dependencies** — 100% Apple frameworks
- **Offline-First:** full gameplay without any network connection

---

## 💰 Monetization — DEFERRED (not in v1)

> **v1 ships free with no IAP** — the loop must earn trust before any monetization is added. When monetization arrives it will be **cozy-compatible only**: time-skips and cosmetic skins. Never energy gates, punitive timers, loot boxes, forced ads, or FOMO events. The catalog below is the deferred long-term plan.

- **Dream Packs** — cosmetic factory themes
- **Moth Skins** — visual courier variants
- **Moonloom Pass** — monthly subscription (2x offline earnings)
- **Stardust Bundles** — premium currency for cosmetics
- **Lucid Accelerator** — skip reset wait (one-time event)

---

## 📂 Repository Structure

```
moonloom/
├── README.md
├── LAUNCH_READINESS.md          # Authoritative v1 build-to spec (start here)
└── docs/
    ├── prd/
    │   ├── TECHNICAL_PRD.md
    │   ├── NON_TECHNICAL_PRD.md
    │   ├── BUSINESS_PLAN_PRD.md
    │   ├── MONETIZATION_PRD.md
    │   ├── PRIVATE_BETA_PRD.md
    │   ├── PUBLIC_BETA_PRD.md
    │   ├── GO_TO_MARKET_PRD.md
    │   ├── MARKETING_PLAN_PRD.md
    │   └── INVESTOR_DECK_PRD.md
    ├── PROJECT_TRACKER.md
    ├── BUG_TRACKER.md
    └── PROMPT_LOG.md
```

---

## 🗓️ Timeline

> The dates below are the original aspirational plan tied to the full 12-tier product. The **near-term v1 path** is the economy-prototype build order in LAUNCH_READINESS.md §8: scaffold `MoonloomCore`, build and test F1–F8, and tune the curve in the headless harness before any UI. Beta/launch dates re-baseline after the prototype validates the loop.

| Milestone | Target Date |
|-----------|-------------|
| Documentation Complete | Q2 2026 |
| v1 economy prototype (headless, tested) | TBD — next milestone |
| MVP UI on top of validated economy | TBD |
| Private Beta | TBD |
| App Store Launch | TBD |

---

*Built with 🌙 by the Moonloom team*
