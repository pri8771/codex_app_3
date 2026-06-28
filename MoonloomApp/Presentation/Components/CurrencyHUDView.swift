import SwiftUI

/// Top-of-screen heads-up display of the player's currencies. Only shows a
/// currency once the player has earned some of it (keeps early game uncluttered).
struct CurrencyHUDView: View {
    @EnvironmentObject private var gameState: GameState

    private let formatter = NumberAbbreviator()

    private var visibleCurrencies: [ResourceType] {
        ResourceType.allCases.filter { type in
            gameState.amount(of: type) > 0 || (gameState.currencyLifetimeEarned[type] ?? 0) > 0
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(visibleCurrencies) { type in
                    chip(for: type)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Currencies")
    }

    private func chip(for type: ResourceType) -> some View {
        let value = gameState.amount(of: type)
        return HStack(spacing: 6) {
            Image(systemName: type.systemImage)
                .foregroundStyle(Theme.moonGold)
            Text(formatter.string(from: value))
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.2), value: formatter.string(from: value))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Theme.deepBlue.opacity(0.6))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(type.displayName): \(formatter.string(from: gameState.amount(of: type)))")
    }
}
