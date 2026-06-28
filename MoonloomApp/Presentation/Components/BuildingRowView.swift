import SwiftUI

/// A single production-building row. Renders three visual states for unlocked
/// buildings — idle (dim), producing (pulsing glow), and maxed (steady golden
/// glow) — and a greyed, locked state with an unlock hint for tiers the player
/// hasn't reached yet. Buying is wired through `AppContainer`.
struct BuildingRowView: View {
    let tier: ProductionTier

    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var glow = false

    private let formatter = NumberAbbreviator()

    private var count: Int { gameState.count(of: tier.id) }
    private var isUnlocked: Bool { gameState.isUnlocked(tier) }
    private var nextCost: Double { gameState.nextCost(for: tier) }
    private var canAfford: Bool { gameState.canAfford(tier) }
    private var outputPerSecond: Double { gameState.outputPerSecond(forTier: tier) }

    /// "Maxed" = every upgrade for this building has been purchased.
    private var isMaxed: Bool {
        let upgrades = gameState.config.upgrades(forBuilding: tier.id)
        return !upgrades.isEmpty && upgrades.allSatisfy { gameState.isUpgradePurchased($0) }
    }

    private var isProducing: Bool { isUnlocked && count > 0 }

    var body: some View {
        if isUnlocked {
            unlockedRow
        } else {
            lockedRow
        }
    }

    // MARK: Unlocked

    private var unlockedRow: some View {
        HStack(spacing: 12) {
            icon
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
                    if isMaxed {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(Theme.moonGold)
                    }
                }
                Text(tier.summary)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
                if count > 0 {
                    Text("+\(formatter.string(from: outputPerSecond)) \(tier.produces.displayName)/s")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Theme.softViolet)
                        .contentTransition(.numericText())
                }
            }
            Spacer(minLength: 8)
            buyButton
        }
        .padding(.vertical, 6)
        .onAppear { startGlowIfNeeded() }
        .onChange(of: isProducing) { _, _ in startGlowIfNeeded() }
    }

    private var icon: some View {
        Image(systemName: tier.systemImage)
            .font(.title2)
            .foregroundStyle(isProducing ? Theme.moonGold : Theme.textSecondary)
            .frame(width: 40, height: 40)
            .background(Circle().fill(Theme.deepBlue.opacity(isProducing ? 0.85 : 0.5)))
            .shadow(color: glowColor.opacity(glow ? 0.85 : 0.25),
                    radius: isProducing ? (glow ? 10 : 4) : 0)
            .scaleEffect(isProducing && glow && !reduceMotion ? 1.06 : 1.0)
            .animation(reduceMotion ? nil : .easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                       value: glow)
    }

    private var glowColor: Color { isMaxed ? Theme.moonGold : Theme.softViolet }

    private func startGlowIfNeeded() {
        glow = isProducing && !reduceMotion
    }

    private var buyButton: some View {
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

    // MARK: Locked

    private var lockedRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.title3)
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.deepBlue.opacity(0.3)))
            VStack(alignment: .leading, spacing: 2) {
                Text(tier.name)
                    .font(.headline)
                    .foregroundStyle(Theme.textSecondary.opacity(0.8))
                Text(unlockHint)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .opacity(0.75)
        .accessibilityLabel("\(tier.name), locked. \(unlockHint)")
    }

    private var unlockHint: String {
        guard let previous = gameState.config.tiers.first(where: { $0.tier == tier.tier - 1 }) else {
            return "Locked"
        }
        let have = gameState.count(of: previous.id)
        return "Next unlock at \(tier.unlockRequirement) × \(previous.name) (\(have)/\(tier.unlockRequirement))"
    }
}
