import SwiftUI

/// The main idle screen: currency HUD, factory-wide output + global multiplier,
/// a guided next-step banner, the list of unlocked production buildings, and
/// access to Orders and Upgrades.
struct FactoryView: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showUpgrades = false
    @State private var showOrders = false
    @State private var toastWorkItem: DispatchWorkItem?
    @State private var badgeBounce = false

    private var viewModel: FactoryViewModel { FactoryViewModel(gameState: gameState) }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Theme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 0) {
                    CurrencyHUDView()
                    headline
                    if let objective = viewModel.nextObjective {
                        guidanceBanner(objective)
                    }
                    buildingList
                }
                if let message = container.celebrationMessage {
                    celebrationToast(message)
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
            .onChange(of: container.celebrationMessage) { _, message in
                scheduleToastDismiss(for: message)
            }
        }
    }

    private func celebrationToast(_ message: String) -> some View {
        Text(message)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Theme.midnight)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Theme.moonGold))
            .shadow(radius: 6)
            .padding(.top, 4)
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1)
    }

    private func scheduleToastDismiss(for message: String?) {
        toastWorkItem?.cancel()
        guard message != nil else { return }
        let work = DispatchWorkItem { [container] in
            withAnimation { container.celebrationMessage = nil }
        }
        toastWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2, execute: work)
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
                        Circle()
                            .fill(Theme.moonGold)
                            .frame(width: 9, height: 9)
                            .offset(x: 5, y: badgeBounce ? -7 : -4)
                            .animation(reduceMotion ? nil
                                       : .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                                       value: badgeBounce)
                            .onAppear { badgeBounce = true }
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
                // All 12 tiers are always visible; locked tiers render greyed
                // with an unlock hint (handled inside BuildingRowView).
                ForEach(gameState.config.tiers) { tier in
                    BuildingRowView(tier: tier)
                        .padding(.horizontal)
                    Divider().overlay(Theme.textSecondary.opacity(0.15))
                }
            }
            .padding(.vertical, 8)
        }
    }
}
