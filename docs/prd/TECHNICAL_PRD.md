# Technical PRD — Moonloom: Idle Dream Factory (moonloom)

**Version:** 1.0.0 | **Date:** 2026-06-27 | **Status:** Draft

---

## 1. Technical Overview

Moonloom: Idle Dream Factory is a fully offline iOS idle/incremental game. It requires zero network connectivity during gameplay. All data is stored locally using SwiftData. Monetization is handled via StoreKit 2.

### Tech Stack
| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9 |
| UI Framework | SwiftUI (iOS 17+) |
| Data Persistence | SwiftData |
| Monetization | StoreKit 2 |
| Architecture | Clean Architecture + MVVM |
| Minimum iOS | 17.0 |
| No Third-Party Dependencies | Apple frameworks only |

---

## 2. Architecture

### Clean Architecture Layers

```
Presentation Layer (SwiftUI Views + ViewModels)
     ↓
Domain Layer (Use Cases + Domain Models)
     ↓
Data Layer (Repositories + SwiftData)
```

### Folder Structure
```
MoonloomApp/
├── App/
│   ├── MoonloomApp.swift           # @main entry point
│   └── AppContainer.swift          # Dependency injection container
├── Core/
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Building.swift      # Production building entity
│   │   │   ├── Currency.swift      # Currency types + amounts
│   │   │   ├── Upgrade.swift       # Upgrade definition
│   │   │   ├── Cosmetic.swift      # Cosmetic item
│   │   │   └── GameState.swift     # Top-level game state
│   │   ├── UseCases/
│   │   │   ├── ProductionUseCase.swift     # Production tick logic
│   │   │   ├── PurchaseUseCase.swift       # Buy buildings/upgrades
│   │   │   ├── PrestigeUseCase.swift       # New Moon Reset
│   │   │   ├── OfflineEarningsUseCase.swift # Calculate offline gains
│   │   │   └── AchievementUseCase.swift    # Check/award achievements
│   │   └── Repositories/
│   │       ├── GameStateRepository.swift
│   │       └── StoreRepository.swift
│   ├── Data/
│   │   ├── Persistence/
│   │   │   ├── AppDatabase.swift           # SwiftData ModelContainer
│   │   │   └── Models/
│   │   │       ├── BuildingRecord.swift    # @Model for buildings
│   │   │       ├── CurrencyRecord.swift    # @Model for currencies
│   │   │       ├── PrestigeRecord.swift    # @Model for prestige state
│   │   │       └── SettingsRecord.swift    # @Model for settings
│   │   └── Repositories/
│   │       ├── GameStateRepositoryImpl.swift
│   │       └── StoreRepositoryImpl.swift
│   └── Presentation/
│       ├── ViewModels/
│       │   ├── FactoryViewModel.swift      # Main factory screen VM
│       │   ├── UpgradeViewModel.swift      # Upgrade panel VM
│       │   ├── ShopViewModel.swift         # IAP shop VM
│       │   ├── PrestigeViewModel.swift     # Prestige/reset VM
│       │   └── SettingsViewModel.swift     # Settings VM
│       └── Views/
│           ├── Components/                 # Reusable UI components
│           └── Screens/                    # Full-screen views
├── Features/
│   ├── Factory/                    # Main factory idle loop
│   ├── Upgrades/                   # Building + global upgrades
│   ├── Shop/                       # IAP cosmetics store
│   ├── Prestige/                   # New Moon Reset flow
│   ├── Achievements/               # Achievement system
│   └── Settings/                   # Audio, notifications, etc.
├── Services/
│   ├── ProductionEngine/
│   │   └── ProductionEngine.swift  # Core idle tick loop
│   ├── StoreKit/
│   │   └── PurchaseManager.swift   # StoreKit 2 IAP manager
│   ├── Offline/
│   │   └── OfflineCalculator.swift # Offline earnings
│   ├── Notifications/
│   │   └── NotificationManager.swift # Local push for offline
│   └── Audio/
│       └── AudioManager.swift      # Background ambient music
└── Resources/
    ├── Assets.xcassets
    └── Sounds/
```

---

## 3. Data Models (SwiftData)

### BuildingRecord @Model
```swift
@Model
final class BuildingRecord {
    var id: String                    // e.g., "whisper_net"
    var tier: Int                     // 1-12
    var count: Int                    // Number owned
    var baseCPS: Double               // Base currency per second
    var multiplier: Double            // Applied upgrades multiplier
    var isUnlocked: Bool
    var totalProduced: Double         // Lifetime production
    var lastTickTimestamp: Date
}
```

### CurrencyRecord @Model
```swift
@Model
final class CurrencyRecord {
    var type: String                  // "whispers", "dreamthread", "moonlight", "stardust", "lucidShards"
    var amount: Double
    var lifetimeEarned: Double
    var lastUpdated: Date
}
```

### PrestigeRecord @Model
```swift
@Model
final class PrestigeRecord {
    var resetCount: Int
    var totalLucidShardsEarned: Double
    var permanentUpgrades: [String]   // Array of purchased Lunar Codex upgrades
    var bestRunMoonlightRestored: Double
    var lastResetDate: Date?
}
```

### AchievementRecord @Model
```swift
@Model
final class AchievementRecord {
    var id: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var progress: Double              // For incremental achievements
}
```

### SettingsRecord @Model
```swift
@Model
final class SettingsRecord {
    var isMusicEnabled: Bool
    var isSFXEnabled: Bool
    var isNotificationsEnabled: Bool
    var offlineEarningCapHours: Int   // Default 2, upgradeable to 48
    var theme: String                 // Active cosmetic theme
    var lastActiveTimestamp: Date
}
```

---

## 4. Production Engine

### Core Tick Loop
The Production Engine runs on a 0.1 second timer using Swift Concurrency:

```swift
actor ProductionEngine {
    private var timer: Task<Void, Never>?
    
    func start() {
        timer = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                await tick()
            }
        }
    }
    
    private func tick() async {
        let deltaTime: Double = 0.1
        // For each building: amount += count * baseCPS * multiplier * deltaTime
        // Apply global multipliers
        // Update UI via @Published properties
    }
}
```

### Production Formula
```
production_per_second = building_count × base_cps × upgrade_multiplier × global_multiplier × prestige_multiplier
```

### Number Display System
- Use scientific notation above 1 quadrillion (1e15)
- Display as: 1.23 K, 1.23 M, 1.23 B, 1.23 T, 1.23 Qa, 1.23 Qi...
- Implement `NumberFormatter` extension for consistent display

---

## 5. Offline Earnings System

### Algorithm
```
1. On app launch: calculate time since lastActiveTimestamp
2. Cap elapsed time at offlineEarningCapHours (default 2h, max 48h)
3. Apply 50% efficiency penalty for offline vs active
4. offline_earned = Σ(building_cps × capped_time × 0.5)
5. Add to current currency
6. Show "Welcome back!" modal with earnings summary
```

### Offline Notification
- Schedule local notification when app backgrounds
- "Your moth couriers have been busy! Come back to collect your dreams."
- Fires at: 2h, 8h, 24h intervals

---

## 6. Prestige System (New Moon Reset)

### Prestige Trigger Conditions
- Player must restore ≥ 25% of moon (first reset)
- Each subsequent reset: previous threshold × 1.5 (up to 100%)

### Prestige Calculation
```
lucid_shards_earned = floor(moon_restoration_percent × prestige_multiplier × reset_count_bonus)
```

### On Reset
1. All buildings → reset to 0
2. All soft currencies (Whispers, Dreamthread, Moonlight) → 0
3. Stardust → kept
4. Lucid Shards → cumulative (added to total)
5. Permanent upgrades → kept
6. Moon restoration → reset to 0

---

## 7. Monetization Implementation (StoreKit 2)

### Product IDs
```
com.moonloom.dream_pack_celestial     Non-consumable  $2.99
com.moonloom.dream_pack_ember         Non-consumable  $2.99
com.moonloom.moth_skin_golden         Non-consumable  $1.99
com.moonloom.moth_skin_shadow         Non-consumable  $1.99
com.moonloom.stardust_small           Consumable      $0.99   (50 Stardust)
com.moonloom.stardust_medium          Consumable      $2.99   (175 Stardust)
com.moonloom.stardust_large           Consumable      $7.99   (500 Stardust)
com.moonloom.pass_monthly             Auto-renewable  $4.99/mo
com.moonloom.offline_expansion        Non-consumable  $3.99   (Offline cap: 2h → 12h)
```

### PurchaseManager (StoreKit 2)
```swift
@MainActor
final class PurchaseManager: ObservableObject {
    @Published var availableProducts: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    func loadProducts() async { ... }
    func purchase(_ product: Product) async throws -> Transaction { ... }
    func restorePurchases() async { ... }
    func checkEntitlement(for id: String) async -> Bool { ... }
}
```

---

## 8. Performance Requirements

| Metric | Target |
|--------|--------|
| App launch time | < 1.5s cold start |
| Memory usage | < 80MB in steady state |
| Production tick | < 1ms compute time |
| UI frame rate | 60fps sustained |
| SwiftData write | < 50ms per save cycle |
| Offline calculation | < 200ms for 48h period |
| Battery impact | < 2% per hour background |

---

## 9. Code Standards

- No force unwraps (`!`) in production code
- All `@Model` types use explicit `@Attribute` annotations
- `async/await` over Combine/callbacks
- `@MainActor` on all `ObservableObject` ViewModels
- `Result<T, Error>` for all fallible repository operations
- `Sendable` conformance for all types crossing concurrency boundaries
- SwiftLint enforced: max line length 120, no trailing whitespace
- 80%+ unit test coverage on Domain + Use Cases
- All public APIs documented with `///` Swift DocC comments

---

## 10. Testing Strategy

| Test Type | Coverage Target | Tools |
|-----------|----------------|-------|
| Unit Tests | ≥ 80% (Domain layer) | XCTest |
| Integration Tests | ≥ 60% (Data layer) | XCTest + in-memory SwiftData |
| UI Tests | Critical flows | XCUITest |
| Performance Tests | Production tick | XCTest Metrics |
| StoreKit Tests | All IAP flows | StoreKit Testing |

---

*Last Updated: 2026-06-27*
