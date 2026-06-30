# Moonloom: Idle Dream Factory

> *"While the world sleeps, your factory dreams."*

## Overview

**Moonloom: Idle Dream Factory** is a premium iOS idle/incremental game where you build and manage an ever-growing factory that harvests whispers from sleeping towns, spins them into dreamthread, weaves dreams, and ships them to the moon via moth couriers — gradually restoring the moon's faded light.

**Genre:** Idle / Incremental
**Platform:** iOS 17.0+
**Engine:** SwiftUI + SwiftData + StoreKit 2
**Status:** 🟢 Feature-complete — ~85% production ready (full idle loop, prestige + Lunar Codex, achievements, daily rewards, StoreKit 2, cosmetic themes, notifications). See `docs/CURRENT_STATUS.md`.

---

## 🌙 The Story

The moon has gone dark. Sleeping towns have lost their dreams. As the keeper of the last Moonloom, you must rebuild the Dream Factory — harvesting whispers, spinning dreamthread, and weaving the dreams that power moonlight itself.

---

## 🏭 Core Loop

```
Sleeping Towns → Whispers → Dreamthread → Dreams → Moth Couriers → Moonlight → Upgrades → Moon Restoration → New Moon Reset (Prestige)
```

---

## 🏗️ Production Tiers (12+)

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

## 💎 Currencies

| Currency | Type | Source |
|----------|------|--------|
| Whispers | Soft (primary) | Whisper Nets, town sleeping cycles |
| Dreamthread | Soft (secondary) | Dreamthread Spindles |
| Moonlight | Soft (progression) | Moth Couriers delivering dreams |
| Stardust | Premium soft | Daily login, achievements, events |
| Lucid Shards | Prestige | Earned on New Moon Reset |

---

## 🌑 Prestige: New Moon Reset

When you restore enough of the moon, you can trigger a **New Moon Reset**:
- Factory resets to beginning
- Earn Lucid Shards based on restoration progress
- Lucid Shards → permanent upgrades (Lunar Codex)
- Each reset is faster and deeper than the last

---

## 📱 Tech Stack

- **Language:** Swift 5.9
- **UI Framework:** SwiftUI (iOS 17+)
- **Data:** SwiftData
- **Monetization:** StoreKit 2 (IAP)
- **Architecture:** Clean Architecture + MVVM
- **No Third-Party Dependencies** — 100% Apple frameworks
- **Offline-First:** Full gameplay without network connection

---

## 💰 Monetization

All monetization is cosmetic or convenience. No pay-to-win.

- **Dream Packs** — cosmetic factory themes
- **Moth Skins** — visual courier variants
- **Moonloom Pass** — monthly subscription (2x offline earnings)
- **Stardust Bundles** — premium currency for cosmetics
- **Lucid Accelerator** — skip reset wait (one-time event)

---

## 📍 Current Repository Status

The app is **feature-complete and ~85% production ready** on
`codex/production-readiness`. Implemented end-to-end: the SwiftUI app shell,
SwiftData persistence (schema v2 + lightweight migration), the core idle loop,
12 production tiers, building unlocks/upgrades, Dream Orders, Moon Restoration,
offline earnings, prestige, the **Lunar Codex** (10 permanent prestige upgrades),
**38 achievements**, **daily login rewards**, **onboarding**, a **statistics**
screen, **StoreKit 2** purchasing (cosmetic + convenience only), **cosmetic
themes** that re-skin the app, **local notifications**, a programmatic app icon,
and a token-based design system — with **119 passing XCTest tests**.

Implementation history lives in PR #1 (Phases 1–4) and PR #2
(stabilization + this production build-out):

- https://github.com/pri8771/moonloom/pull/1
- https://github.com/pri8771/moonloom/pull/2

**Economy decision (resolved):** Moonloom uses a single-Moonlight production
economy (all 12 tiers produce Moonlight); Stardust comes from orders,
achievements, daily logins, and IAP; Lucid Shards come from prestige. The
canonical tier *names* are kept. This is the shipped model.

**Remaining for launch:** real App Store Connect product setup + sandbox-device
IAP testing, final audio/art assets, device-matrix + accessibility QA,
Instruments profiling, and TestFlight.

Notion build hub:
https://app.notion.com/p/38eab1f2276581959e1ecc46b07557de

See `docs/CURRENT_STATUS.md` for the latest engineering status.

---

## 📂 Repository Structure

```
moonloom/
├── MoonloomApp.xcodeproj
├── MoonloomApp/
│   ├── App/
│   ├── Core/
│   ├── Features/
│   ├── Presentation/
│   ├── Resources/
│   └── Services/
├── MoonloomTests/
├── README.md
├── project.yml
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
    ├── CURRENT_STATUS.md
    └── PROMPT_LOG.md
```

---

## 🗓️ Timeline

| Milestone | Target Date |
|-----------|-------------|
| Documentation Complete | Q2 2026 |
| MVP Development | Q3 2026 |
| Private Beta | Q4 2026 |
| Public Beta | Q1 2027 |
| App Store Launch | Q1 2027 |

---

*Built with 🌙 by the Moonloom team*
