# Moonloom — Project Documentation

GitHub is the source of truth for this project documentation. Notion indexes this file in the Priyansh App Factory Command Center.

## 00. Executive Summary
Moonloom is an offline-first idle/incremental iOS game about rebuilding a dream factory that restores the moon. It is for casual players who enjoy calm progression, cozy visuals, and short check-ins. The end product should include resource generation, station upgrades, offline progress, restoration milestones, local persistence, and optional cosmetics.

## 01. Product
MVP scope: dream resource generation, 3-5 factory stations, upgrade loop, offline progress, local persistence, restoration milestones, onboarding. Acceptance criteria: progress is reliable, upgrades are understandable, and save/load does not lose state.

## 02. Design
Cozy moonlit aesthetic with dream machinery, soft gradients, helpers, and calming feedback. Screens: factory overview, station detail, upgrade modal, offline rewards, restoration map, collection.

## 03. Frontend Technical
SwiftUI plus SwiftData. Economy logic should be deterministic and testable outside views. Core models: PlayerState, ResourceWallet, StationState, Upgrade, RestorationNode.

## 04. Backend Technical
No backend for v1. Future services may include cloud save, remote events, remote balance config, and purchase validation.

## 05. Business
Business model: optional cosmetics, helper skins, starter bundle, seasonal packs. Avoid forced ads in v1.

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
