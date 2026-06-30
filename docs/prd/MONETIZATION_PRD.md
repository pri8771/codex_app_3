# Monetization PRD — Moonloom: Idle Dream Factory (moonloom)

**Version:** 1.0.0 | **Date:** 2026-06-27 | **Status:** Draft

---

## Philosophy

**Our Monetization Principles:**
1. Never charge for core game mechanics
2. Never create artificial friction to force purchases
3. Never put content behind a paywall that progression can't unlock
4. Make purchases feel like gifts to the game, not entry fees

The goal: players who spend money feel good about it, not manipulated.

---

## IAP Product Catalog

### Consumables

| Product ID | Display Name | Price | Contents | Notes |
|------------|-------------|-------|---------|-------|
| com.moonloom.stardust_small | Starfall Bundle | $0.99 | 50 Stardust | Impulse buy |
| com.moonloom.stardust_medium | Moonrise Bundle | $2.99 | 175 Stardust | Best value mid |
| com.moonloom.stardust_large | Eclipse Bundle | $7.99 | 500 Stardust | Power purchase |

### Non-Consumables (Permanent)

| Product ID | Display Name | Price | Contents |
|------------|-------------|-------|---------|
| com.moonloom.dream_pack_celestial | Celestial Dream Pack | $2.99 | Deep space theme: midnight blue + starfields |
| com.moonloom.dream_pack_ember | Ember Dream Pack | $2.99 | Warm fire theme: orange + amber |
| com.moonloom.dream_pack_crystal | Crystal Dream Pack | $2.99 | Ice theme: white + pale blue |
| com.moonloom.moth_skin_golden | Golden Moth Skin | $1.99 | Couriers glow gold instead of white |
| com.moonloom.moth_skin_shadow | Shadow Moth Skin | $1.99 | Dark/ethereal courier design |
| com.moonloom.moth_skin_aurora | Aurora Moth Skin | $2.99 | Color-shifting iridescent design |
| com.moonloom.offline_expansion | Offline Expansion | $3.99 | Offline cap: 2 hours → 12 hours (permanent) |
| com.moonloom.building_skin_runic | Runic Building Set | $3.99 | Ancient rune visual for all buildings |
| com.moonloom.building_skin_floral | Floral Building Set | $3.99 | Nature/flower visual for all buildings |

### Auto-Renewable Subscriptions

| Product ID | Display Name | Price | Duration | Benefits |
|------------|-------------|-------|---------|---------|
| com.moonloom.pass_monthly | Moonloom Pass | $4.99/mo | Monthly | 2x offline earnings + exclusive monthly cosmetic |
| com.moonloom.pass_annual | Moonloom Pass Annual | $39.99/yr | Annual | Same as monthly + 33% savings |

---

## Stardust Economy

### What Stardust Buys
| Item | Cost |
|------|------|
| Dream Pack (any) | 200 Stardust |
| Moth Skin (standard) | 120 Stardust |
| Moth Skin (premium) | 180 Stardust |
| Building Skin Set | 250 Stardust |
| Seasonal Event Item | 150 Stardust |

### Free Stardust Sources
| Source | Amount | Frequency |
|--------|--------|-----------|
| Daily Login (Day 1) | 5 Stardust | Daily |
| Daily Login (Day 7 streak) | 20 Stardust | Weekly |
| New Moon Reset completion | 10 Stardust | Per prestige |
| Achievement unlock | 2-5 Stardust | Per achievement |
| Event participation | 15-50 Stardust | Seasonal |

**Intent:** Free Stardust accumulates slowly (~500 in 6 months of play), enough to unlock 1-2 cosmetics. Players who love the game can buy more.

---

## Monetization Flow Design

### First IAP Trigger (Week 1-2)
- Player has been playing 5+ days
- Player has completed their first New Moon Reset
- Show "Moonloom Pass — Double your offline earnings" notification
- Trigger in a high-satisfaction moment (post-reset)

### Cosmetic Discovery
- Showcase premium factory themes in the "Dream Showcase" section
- Allow free 24-hour preview of any cosmetic
- Show owned cosmetics on World Map to create display value

### Subscription Pitch
- Show subscription value when player closes app (offline earnings reminder)
- Message: "Your factory will earn 2x while you sleep with Moonloom Pass"

---

## Revenue Projections

### Monthly Revenue Model (Month 12)
| Stream | Monthly Revenue |
|--------|----------------|
| Cosmetics (non-consumable) | $12,000 |
| Stardust bundles | $8,000 |
| Moonloom Pass (subscribers) | $22,000 |
| Offline Expansion | $4,000 |
| **Total** | **$46,000** |

### Annual Revenue Year 1: $276,000
(Ramps: $5K Month 1 → $46K Month 12)

---

## Anti-Patterns We Explicitly Avoid

| Dark Pattern | Our Stance |
|-------------|-----------|
| Energy/timer systems | ❌ Never |
| Pay-to-skip mandatory waits | ❌ Never |
| Loot boxes / gacha | ❌ Never |
| Selling gameplay advantages | ❌ Never |
| Forced ads | ❌ Never |
| Misleading pricing | ❌ Never |
| Subscription cancel tricks | ❌ Never |

---

## StoreKit 2 Implementation Notes

- All transactions processed via StoreKit 2 async/await API
- Entitlements verified on every app launch
- Offline purchase verification via StoreKit 2 receipt validation (no server needed)
- Subscriptions: use `Product.SubscriptionInfo` for status checking
- All product IDs stored as constants in `ProductID.swift`
- Test all flows in StoreKit sandbox before submission

---

*Last Updated: 2026-06-27*
