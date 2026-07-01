import SwiftUI

/// Upgrade panel: per building, shows the current level + multiplier, the cost
/// to the next level, and explicit before → after production-rate feedback.
/// Wires upgrades through `AppContainer`.
struct UpgradesView: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss

    @State private var burstTrigger = 0
    @State private var burstText = ""

    private var viewModel: UpgradesViewModel { UpgradesViewModel(gameState: gameState) }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 10) {
                        if viewModel.hasRows {
                            ForEach(viewModel.rows) { row in
                                rowView(row)
                            }
                        } else {
                            emptyState
                        }
                    }
                    .padding()
                }
                RewardBurstView(text: burstText, trigger: burstTrigger)
            }
            .navigationTitle("Upgrades")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.tint(Theme.moonGold)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "wand.and.stars")
                .font(.largeTitle)
                .foregroundStyle(Theme.softViolet)
            Text("Unlock a building to start upgrading it.")
                .font(.callout)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    private func rowView(_ row: UpgradesViewModel.Row) -> some View {
        HStack(spacing: 12) {
            Image(systemName: row.tier.systemImage)
                .font(.title2)
                .foregroundStyle(Theme.moonGold)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.deepBlue.opacity(0.7)))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(row.tier.name)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Lv \(row.level)/\(row.maxLevel)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.softViolet)
                        .monospacedDigit()
                }
                Text(String(format: "Current ×%.2f production", row.currentMultiplier))
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                beforeAfter(row)
            }

            Spacer(minLength: 8)
            trailing(row)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.deepBlue.opacity(0.25)))
    }

    private func beforeAfter(_ row: UpgradesViewModel.Row) -> some View {
        HStack(spacing: 4) {
            Text("\(viewModel.format(row.beforeRatePerSecond))/s")
                .foregroundStyle(Theme.textSecondary)
            if !row.isMaxed {
                Image(systemName: "arrow.right").font(.caption2).foregroundStyle(Theme.softViolet)
                Text("\(viewModel.format(row.afterRatePerSecond))/s")
                    .foregroundStyle(Theme.moonGold)
            }
        }
        .font(.caption.weight(.semibold).monospacedDigit())
    }

    @ViewBuilder
    private func trailing(_ row: UpgradesViewModel.Row) -> some View {
        if row.isMaxed {
            VStack(spacing: 2) {
                Image(systemName: "crown.fill").font(.caption)
                Text("MAX").font(.caption2.weight(.bold))
            }
            .foregroundStyle(Theme.moonGold)
            .frame(minWidth: 84)
        } else {
            Button {
                upgrade(row)
            } label: {
                VStack(spacing: 2) {
                    Text("Upgrade").font(.subheadline.weight(.bold))
                    HStack(spacing: 3) {
                        Image(systemName: row.tier.costCurrency.systemImage).font(.caption2)
                        Text(viewModel.format(row.nextCost))
                            .font(.caption.weight(.semibold)).monospacedDigit()
                    }
                }
                .frame(minWidth: 84)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(row.canAfford ? Theme.moonGold : Theme.deepBlue.opacity(0.5)))
                .foregroundStyle(row.canAfford ? Theme.midnight : Theme.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!row.canAfford)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Upgrade \(row.tier.name) for \(viewModel.format(row.nextCost)) \(row.tier.costCurrency.displayName)")
        }
    }

    private func upgrade(_ row: UpgradesViewModel.Row) {
        guard container.upgradeBuilding(row.tier) else { return }
        burstText = "\(row.tier.name) Lv \(gameState.upgradeLevel(of: row.tier.id))!"
        burstTrigger += 1
    }
}
