import SwiftUI

/// The main idle screen: currency HUD, factory-wide output + global multiplier,
/// a guided next-step banner, the list of unlocked production buildings, and
/// access to Orders and Upgrades.
struct FactoryView: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer

    @State private var showUpgrades = false
    @State private var showOrders = false

    private var viewModel: FactoryViewModel { FactoryViewModel(gameState: gameState) }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 0) {
                    CurrencyHUDView()
                    headline
                    if let objective = viewModel.nextObjective {
                        guidanceBanner(objective)
                    }
                    buildingList
                }
            }
            .navigationTitle("Dream Factory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { ordersButton }
                ToolbarItem(placement: .topBarTrailing) { upgradesButton }
            }
            .sheet(isPresented: $showOrders) { OrdersView() }
            .sheet(isPresented: $showUpgrades) { UpgradesView() }
        }
    }

    private var headline: some View {
        VStack(spacing: 2) {
            Text("Moonlight / second")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            HStack(spacing: 6) {
                Image(systemName: ResourceType.moonlight.systemImage)
                    .foregroundStyle(Theme.moonGold)
                Text(viewModel.moonlightPerSecondText)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            if viewModel.hasGlobalBonus {
                Text("Global production \(viewModel.globalMultiplierText)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.softViolet)
            }
        }
        .padding(.bottom, 6)
        .animation(.easeInOut, value: viewModel.moonlightPerSecondText)
    }

    private func guidanceBanner(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkle.magnifyingglass")
                .foregroundStyle(Theme.moonGold)
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.textPrimary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.deepBlue.opacity(0.45)))
        .padding(.horizontal)
        .padding(.bottom, 6)
        .transition(.opacity)
        .animation(.easeInOut, value: text)
    }

    private var ordersButton: some View {
        Button { showOrders = true } label: {
            Image(systemName: "scroll.fill")
                .overlay(alignment: .topTrailing) {
                    if viewModel.hasOrderReady {
                        Circle().fill(Theme.moonGold).frame(width: 9, height: 9).offset(x: 5, y: -4)
                    }
                }
        }
        .tint(Theme.moonGold)
        .accessibilityLabel(viewModel.hasOrderReady ? "Dream Orders, one ready" : "Dream Orders")
    }

    private var upgradesButton: some View {
        Button { showUpgrades = true } label: {
            Image(systemName: "wand.and.stars")
                .overlay(alignment: .topTrailing) {
                    if viewModel.availableUpgradeCount > 0 {
                        Circle().fill(Theme.moonGold).frame(width: 9, height: 9).offset(x: 5, y: -4)
                    }
                }
        }
        .tint(Theme.moonGold)
        .accessibilityLabel("Upgrades, \(viewModel.availableUpgradeCount) available")
    }

    private var buildingList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(viewModel.visibleTiers) { tier in
                    BuildingRowView(tier: tier)
                        .padding(.horizontal)
                    Divider().overlay(Theme.textSecondary.opacity(0.15))
                }

                if let locked = viewModel.nextLockedTier {
                    lockedTeaser(locked)
                        .padding()
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func lockedTeaser(_ tier: ProductionTier) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.deepBlue.opacity(0.4)))
            VStack(alignment: .leading, spacing: 2) {
                Text(tier.name)
                    .font(.headline)
                    .foregroundStyle(Theme.textSecondary)
                Text(viewModel.unlockHint(for: tier))
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.deepBlue.opacity(0.25)))
    }
}
