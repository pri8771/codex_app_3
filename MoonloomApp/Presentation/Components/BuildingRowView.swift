import SwiftUI

/// A single production-building row: glyph, name, owned count, current output,
/// and a buy button showing the next cost. Buying is wired through the
/// `AppContainer` so haptics/analytics/persistence stay consistent.
struct BuildingRowView: View {
    let tier: ProductionTier

    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer

    private let formatter = NumberAbbreviator()

    private var count: Int { gameState.count(of: tier.id) }
    private var nextCost: Double { gameState.nextCost(for: tier) }
    private var canAfford: Bool { gameState.canAfford(tier) }
    private var outputPerSecond: Double { gameState.outputPerSecond(forTier: tier) }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tier.systemImage)
                .font(.title2)
                .foregroundStyle(Theme.moonGold)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.deepBlue.opacity(0.7)))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(tier.name)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("×\(count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.snappy, value: count)
                }
                Text(tier.summary)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
                if count > 0 {
                    Text("+\(formatter.string(from: outputPerSecond)) \(tier.produces.displayName)/s")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Theme.softViolet)
                }
            }

            Spacer(minLength: 8)

            Button {
                container.purchase(tier)
            } label: {
                VStack(spacing: 2) {
                    Text("Buy")
                        .font(.subheadline.weight(.bold))
                    HStack(spacing: 3) {
                        Image(systemName: tier.costCurrency.systemImage)
                            .font(.caption2)
                        Text(formatter.string(from: nextCost))
                            .font(.caption.weight(.semibold))
                            .monospacedDigit()
                    }
                }
                .frame(minWidth: 76)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(canAfford ? Theme.moonGold : Theme.deepBlue.opacity(0.5))
                )
                .foregroundStyle(canAfford ? Theme.midnight : Theme.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!canAfford)
            .accessibilityLabel("Buy \(tier.name) for \(formatter.string(from: nextCost)) \(tier.costCurrency.displayName)")
        }
        .padding(.vertical, 6)
    }
}
