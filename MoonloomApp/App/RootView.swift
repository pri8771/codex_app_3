import SwiftUI

/// Root tab navigation. Five primary destinations: Factory, Moon Restoration,
/// Shop, and Settings, with first-launch onboarding, the offline "Welcome back"
/// modal, and the daily-reward modal presented over the top.
///
/// `.id(gameState.theme)` rebuilds the tree when a cosmetic theme is selected, so
/// the swapped `Theme.current` palette re-skins every screen.
struct RootView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var gameState: GameState

    var body: some View {
        TabView {
            FactoryView()
                .tabItem { Label("Factory", systemImage: "building.2.fill") }

            MoonRestorationView()
                .tabItem { Label("Moon", systemImage: "moon.stars.fill") }

            ShopView()
                .tabItem { Label("Shop", systemImage: "bag.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .id(gameState.theme)
        .tint(Theme.moonGold)
        .fullScreenCover(isPresented: onboardingPresented) {
            OnboardingView { container.completeOnboarding() }
        }
        .sheet(isPresented: offlineModalPresented) {
            if let result = container.pendingOfflineEarnings {
                OfflineWelcomeView(result: result) {
                    container.pendingOfflineEarnings = nil
                }
            }
        }
        .sheet(isPresented: dailyRewardPresented) {
            if let claim = container.availableDailyClaim {
                DailyRewardView(claim: claim)
            }
        }
        .alert("Data notice", isPresented: persistenceAlertPresented) {
            Button("OK") { container.clearPersistenceWarning() }
        } message: {
            Text(container.persistenceWarning ?? "")
        }
    }

    /// Onboarding shows once, after bootstrap, before anything else.
    private var onboardingPresented: Binding<Bool> {
        Binding(
            get: { container.isBootstrapped && !gameState.hasCompletedOnboarding },
            set: { _ in }
        )
    }

    /// Drives the offline modal from the optional pending-earnings value.
    private var offlineModalPresented: Binding<Bool> {
        Binding(
            get: { container.pendingOfflineEarnings != nil && gameState.hasCompletedOnboarding },
            set: { isPresented in
                if !isPresented { container.pendingOfflineEarnings = nil }
            }
        )
    }

    /// Daily reward presents after onboarding and once the offline modal is gone.
    private var dailyRewardPresented: Binding<Bool> {
        Binding(
            get: {
                container.availableDailyClaim != nil
                    && container.pendingOfflineEarnings == nil
                    && gameState.hasCompletedOnboarding
            },
            set: { isPresented in
                if !isPresented { container.availableDailyClaim = nil }
            }
        )
    }

    private var persistenceAlertPresented: Binding<Bool> {
        Binding(
            get: { container.persistenceWarning != nil },
            set: { isPresented in
                if !isPresented { container.clearPersistenceWarning() }
            }
        )
    }
}
