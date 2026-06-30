import SwiftUI

/// The Lunar Codex — permanent prestige upgrades bought with Lucid Shards
/// (MOONLOOM-PROMPT-005). Reached from the Moon Restoration screen. Upgrades
/// persist across every New Moon Reset.
struct LunarCodexView: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer

    private let formatter = NumberAbbreviator()
    private let upgrades = LunarCodex.upgrades

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Theme.Space.md) {
                    shardBalance
                    introCard
                    ForEach(upgrades) { upgrade in
                        row(for: upgrade)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Lunar Codex")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var shardBalance: some View {
        HStack(spacing: 6) {
            Image(systemName: ResourceType.lucidShards.systemImage).foregroundStyle(Theme.moonGold)
            Text("\(formatter.string(from: gameState.amount(of: .lucidShards))) Lucid Shards")
                .font(.headline.monospacedDigit())
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, Theme.Space.lg)
        .padding(.vertical, Theme.Space.sm)
        .background(Capsule().fill(Theme.deepBlue.opacity(0.5)))
        .accessibilityLabel("\(formatter.string(from: gameState.amount(of: .lucidShards))) Lucid Shards")
    }

    private var introCard: some View {
        Text("Spend Lucid Shards on permanent blessings. They endure through every New Moon Reset, making each run faster than the last.")
            .font(.caption)
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .moonloomCard(opacity: 0.25)
    }

    private func row(for upgrade: LunarCodexUpgrade) -> some View {
        let level = gameState.codexLevel(of: upgrade.id)
        let maxed = gameState.isCodexMaxed(upgrade)
        let cost = gameState.codexCost(for: upgrade)
        let canBuy = gameState.canPurchaseCodex(upgrade)

        return VStack(alignment: .leading, spacing: Theme.Space.sm) {
            HStack(spacing: Theme.Space.md) {
                Image(systemName: upgrade.systemImage)
                    .font(.title3)
                    .foregroundStyle(level > 0 ? Theme.moonGold : Theme.textSecondary)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Theme.deepBlue.opacity(0.6)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(upgrade.name)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text(upgrade.detail)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: 4)
                Text("Lv \(level)/\(upgrade.maxLevel)")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(level > 0 ? Theme.moonGold : Theme.textSecondary)
            }

            ProgressView(value: Double(level), total: Double(upgrade.maxLevel))
                .tint(Theme.moonGold)

            if maxed {
                Text("Fully mastered")
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundStyle(Theme.moonGold)
            } else {
                Button { container.purchaseCodexUpgrade(upgrade) } label: {
                    HStack(spacing: 6) {
                        Image(systemName: ResourceType.lucidShards.systemImage)
                        Text("Upgrade · \(formatter.string(from: cost))")
                    }
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .fill(canBuy ? Theme.moonGold : Theme.deepBlue.opacity(0.5)))
                    .foregroundStyle(canBuy ? Theme.midnight : Theme.textSecondary)
                }
                .buttonStyle(.plain)
                .disabled(!canBuy)
                .accessibilityLabel("Upgrade \(upgrade.name) for \(formatter.string(from: cost)) Lucid Shards")
            }
        }
        .padding()
        .moonloomCard(opacity: level > 0 ? 0.4 : 0.25)
    }
}
