import SwiftUI

/// Upgrade panel: lists building upgrades with explicit before → after
/// production-rate feedback and wires purchases through `AppContainer`.
struct UpgradesView: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss

    private var viewModel: UpgradesViewModel { UpgradesViewModel(gameState: gameState) }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 10) {
                        header
                        if viewModel.rows.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.rows) { row in
                                rowView(row)
                            }
                        }
                    }
                    .padding()
                }
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

    private var header: some View {
        Text("\(viewModel.ownedCount) upgrades owned")
            .font(.caption)
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "wand.and.stars")
                .font(.largeTitle)
                .foregroundStyle(Theme.softViolet)
            Text("Buy more buildings to unlock upgrades.")
                .font(.callout)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    private func rowView(_ row: UpgradesViewModel.Row) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.title2)
                .foregroundStyle(Theme.moonGold)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.deepBlue.opacity(0.7)))

            VStack(alignment: .leading, spacing: 3) {
                Text(row.upgrade.name)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(row.upgrade.detail)
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
            Image(systemName: "arrow.right")
                .font(.caption2)
                .foregroundStyle(Theme.softViolet)
            Text("\(viewModel.format(row.afterRatePerSecond))/s")
                .foregroundStyle(Theme.moonGold)
        }
        .font(.caption.weight(.semibold).monospacedDigit())
    }

    @ViewBuilder
    private func trailing(_ row: UpgradesViewModel.Row) -> some View {
        switch row.availability {
        case .locked(let remaining):
            VStack(spacing: 2) {
                Image(systemName: "lock.fill").font(.caption)
                Text("Need \(remaining)").font(.caption2)
            }
            .foregroundStyle(Theme.textSecondary)
            .frame(minWidth: 76)
        case .available, .unaffordable:
            let affordable = row.availability == .available
            Button {
                _ = container.purchaseUpgrade(row.upgrade)
            } label: {
                VStack(spacing: 2) {
                    Text("Upgrade").font(.subheadline.weight(.bold))
                    HStack(spacing: 3) {
                        Image(systemName: row.upgrade.costCurrency.systemImage).font(.caption2)
                        Text(viewModel.format(row.upgrade.cost))
                            .font(.caption.weight(.semibold)).monospacedDigit()
                    }
                }
                .frame(minWidth: 84)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(affordable ? Theme.moonGold : Theme.deepBlue.opacity(0.5)))
                .foregroundStyle(affordable ? Theme.midnight : Theme.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!affordable)
        }
    }
}
