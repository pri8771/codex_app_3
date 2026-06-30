import SwiftUI

/// Player statistics / history screen (PROJECT_TRACKER T007-12). Derives all
/// values from the observed `GameState` — no separate tracking needed.
struct StatisticsView: View {
    @EnvironmentObject private var gameState: GameState

    private let formatter = NumberAbbreviator()

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Theme.Space.lg) {
                    group("Production", [
                        ("Moonlight / second", formatter.string(from: gameState.outputPerSecond(of: .moonlight))),
                        ("Lifetime Moonlight", formatter.string(from: gameState.lifetimeMoonlight)),
                        ("Global multiplier", String(format: "×%.2f", gameState.globalMultiplier)),
                        ("Milestones reached", "\(gameState.milestonesReached)")
                    ])
                    group("Factory", [
                        ("Buildings owned", "\(gameState.totalBuildingCount)"),
                        ("Tiers unlocked", "\(gameState.unlockedTiers.count) / \(gameState.config.tiers.count)"),
                        ("Total upgrade levels", "\(totalUpgradeLevels)"),
                        ("Orders fulfilled", "\(gameState.ordersFulfilled)")
                    ])
                    group("Restoration & Prestige", [
                        ("Moon restored", "\(Int((gameState.moonRestoration * 100).rounded()))%"),
                        ("Biomes restored", "\(gameState.restoredNodeIDs.count) / \(gameState.config.restorationNodes.count)"),
                        ("New Moon Resets", "\(gameState.resetCount)"),
                        ("Lucid Shards earned", formatter.string(from: gameState.totalLucidShardsEarned)),
                        ("Prestige multiplier", String(format: "×%.2f", gameState.prestigeMultiplier))
                    ])
                    group("Currency", [
                        ("Stardust", formatter.string(from: gameState.amount(of: .stardust))),
                        ("Lifetime Stardust", formatter.string(from: gameState.lifetimeStardust)),
                        ("Lucid Shards", formatter.string(from: gameState.amount(of: .lucidShards)))
                    ])
                }
                .padding()
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var totalUpgradeLevels: Int {
        gameState.config.tiers.reduce(0) { $0 + gameState.upgradeLevel(of: $1.id) }
    }

    private func group(_ title: String, _ rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Space.sm) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    HStack {
                        Text(row.0)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                        Text(row.1)
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .padding(.vertical, 10)
                    if index < rows.count - 1 {
                        Divider().overlay(Theme.textSecondary.opacity(0.15))
                    }
                }
            }
            .padding(.horizontal, Theme.Space.md)
            .moonloomCard(opacity: 0.3)
        }
    }
}
