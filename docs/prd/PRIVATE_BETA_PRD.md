# Private Beta PRD — Moonloom: Idle Dream Factory (moonloom)

**Version:** 1.0.0 | **Date:** 2026-06-27 | **Status:** Draft

---

## Overview

The Private Beta phase validates core idle loop gameplay, production balance, prestige system, and IAP flows with a controlled group of 500 testers before broader release.

**Duration:** 4 weeks (October 15 – November 15, 2026)
**Platform:** TestFlight (iOS)
**Tester Count:** 500 (invite-only)
**Build:** v0.8.x (feature-complete MVP)

---

## Beta Goals

1. Validate core idle loop is engaging and not frustrating
2. Verify production balance (buildings scale correctly through all 12 tiers)
3. Test New Moon Reset (prestige) — ensure it feels rewarding
4. Confirm offline earnings calculation is correct
5. Verify all StoreKit 2 IAP flows work in sandbox
6. Identify P0/P1 bugs before public launch
7. Get Day-1/7/30 retention signal

---

## Scope: What's Included in Private Beta

### Included ✅
- All 12 production tiers (Whisper Nets through Moonheart Engine)
- Complete currency system (all 5 currencies)
- Upgrade system (building upgrades + global upgrades)
- New Moon Reset (prestige) — full flow
- Offline earnings (2-hour cap, base version)
- IAP sandbox testing (all 9 products)
- Moonloom Pass subscription (sandbox)
- Daily login system
- Achievement system (50 of planned 200)
- Settings (music, SFX, notifications)

### NOT Included ❌
- Seasonal events (post-launch feature)
- Leaderboards (post-launch)
- Cosmetics shop (placeholder art only)
- Full 200 achievements

---

## Tester Profile

| Segment | Count | How Selected |
|---------|-------|-------------|
| Idle game veterans | 200 | Discord recruitment from r/incremental_games |
| Casual mobile gamers | 150 | Social media sign-up form |
| iOS dev community | 50 | Internal connections |
| Friends & family | 100 | Direct invite |
| **Total** | **500** | |

---

## Feedback Collection

### In-App Feedback
- "Feedback" button always visible in settings menu
- Quick NPS survey after Day 3, Day 7
- "What do you think?" prompt after first New Moon Reset

### External Forms
- Weekly check-in survey (Google Form) sent to all testers
- Exit survey for testers who stop playing

### Metrics Tracking
- Custom event tracking (local analytics, no cloud)
- Session length, session frequency
- Building purchase patterns
- Prestige timing (when do players first reset?)
- IAP interaction rate (taps on shop, conversion in sandbox)

---

## Success Criteria

| Metric | Target | Status |
|--------|--------|--------|
| Day-1 Retention | ≥ 45% | 📅 |
| Day-7 Retention | ≥ 22% | 📅 |
| Avg. session length | ≥ 4 minutes | 📅 |
| NPS Score | ≥ 50 | 📅 |
| Crash-free rate | ≥ 99% | 📅 |
| P0 bugs at end | 0 | 📅 |
| P1 bugs at end | 0 | 📅 |
| "Would recommend" | ≥ 70% | 📅 |
| Prestige rate (by Day 14) | ≥ 40% of testers | 📅 |

---

## Build Requirements

Before private beta build is released:
- [ ] All 12 tiers buildable and functional
- [ ] No crashes in Xcode automated tests
- [ ] Memory usage < 100MB (Instruments)
- [ ] All StoreKit 2 sandbox transactions tested
- [ ] TestFlight build uploaded and approved
- [ ] Beta invite emails sent to all 500 testers
- [ ] Feedback collection tools configured
- [ ] Discord beta channel created

---

## Known Beta Limitations

| Limitation | Reason | Fix By |
|------------|--------|--------|
| Placeholder cosmetics | Art not final | Public Beta |
| 50 of 200 achievements | Scope reduction | Public Beta |
| No seasonal events | Post-launch feature | Launch + 1 month |
| Offline cap fixed at 2h | Upgrade system not done | Public Beta |

---

## Beta Exit Criteria

Private Beta ends when:
1. All P0 and P1 bugs are resolved
2. Day-7 retention ≥ 22%
3. NPS ≥ 50
4. 4 weeks have elapsed OR all criteria met early

---

*Last Updated: 2026-06-27*
