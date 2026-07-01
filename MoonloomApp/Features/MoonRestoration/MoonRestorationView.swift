import SwiftUI

/// Moon Restoration / Story screen. Shows overall restoration, the list of moon
/// biomes (restored / next / locked) the player restores by spending Moonlight,
/// and the New Moon Reset (prestige) entry point. Restoring a biome reveals a
/// story beat and plays a sparkle celebration.
struct MoonRestorationView: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showPrestigeConfirm = false
    @State private var burstTrigger = 0
    @State private var burstText = ""

    private let formatter = NumberAbbreviator()

    private var threshold: Double {
        container.prestigeCalculator.threshold(resetCount: gameState.resetCount)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        MoonProgressView(progress: gameState.moonRestoration)
                            .padding(.top, 12)

                        moonlightBalance
                        biomeList
                        prestigePanel
                        lunarCodexLink
                    }
                    .padding()
                }
                RewardBurstView(text: burstText, trigger: burstTrigger)
            }
            .navigationTitle("Moon Restoration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .confirmationDialog(
                "Trigger a New Moon Reset?",
                isPresented: $showPrestigeConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset for \(formatter.string(from: container.projectedShards)) Lucid Shards", role: .destructive) {
                    Task { await container.performPrestige() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your factory and soft currencies reset. You keep Stardust, Lucid Shards, and permanent upgrades.")
            }
        }
    }

    private var moonlightBalance: some View {
        HStack(spacing: 6) {
            Image(systemName: ResourceType.moonlight.systemImage).foregroundStyle(Theme.moonGold)
            Text("\(formatter.string(from: gameState.amount(of: .moonlight))) Moonlight")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Capsule().fill(Theme.deepBlue.opacity(0.5)))
    }

    private var biomeList: some View {
        VStack(spacing: 10) {
            ForEach(gameState.restorationNodes) { node in
                biomeRow(node)
            }
        }
    }

    private func biomeRow(_ node: RestorationNode) -> some View {
        let restored = gameState.isNodeRestored(node)
        let isNext = gameState.nextRestorationNode?.id == node.id
        let canRestore = gameState.canRestore(node)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: restored ? "moon.stars.fill" : (isNext ? "moonphase.waxing.crescent" : "lock.fill"))
                    .font(.title3)
                    .foregroundStyle(restored ? Theme.moonGold : (isNext ? Theme.softViolet : Theme.textSecondary))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.deepBlue.opacity(0.6)))
                    .shadow(color: restored ? Theme.moonGold.opacity(0.6) : .clear, radius: restored ? 8 : 0)

                VStack(alignment: .leading, spacing: 2) {
                    Text(node.name)
                        .font(.headline)
                        .foregroundStyle(restored || isNext ? Theme.textPrimary : Theme.textSecondary)
                    if restored {
                        Text(node.story)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    } else if isNext {
                        Text("Restore for \(formatter.string(from: node.cost)) Moonlight")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    } else {
                        Text("Restore the previous biome first.")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer(minLength: 8)
                if isNext {
                    Button { restore(node) } label: {
                        Text("Restore")
                            .font(.subheadline.weight(.bold))
                            .padding(.vertical, 8).padding(.horizontal, 14)
                            .background(RoundedRectangle(cornerRadius: 12)
                                .fill(canRestore ? Theme.moonGold : Theme.deepBlue.opacity(0.5)))
                            .foregroundStyle(canRestore ? Theme.midnight : Theme.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canRestore)
                    .accessibilityLabel("Restore \(node.name) for \(formatter.string(from: node.cost)) Moonlight")
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14)
            .fill(Theme.deepBlue.opacity(restored ? 0.4 : (isNext ? 0.3 : 0.18))))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(canRestore ? Theme.moonGold.opacity(0.6) : .clear, lineWidth: 1.5)
        )
    }

    private var prestigePanel: some View {
        VStack(spacing: 12) {
            Label("New Moon Reset", systemImage: "moonphase.new.moon")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            statRow("Lucid Shards earned so far",
                    value: formatter.string(from: gameState.totalLucidShardsEarned))
            statRow("Resets completed", value: "\(gameState.resetCount)")
            statRow("Restoration needed", value: "\(Int((threshold * 100).rounded()))%")

            if container.canPrestige {
                Text("Reset now to gain \(formatter.string(from: container.projectedShards)) Lucid Shards.")
                    .font(.caption)
                    .foregroundStyle(Theme.moonGold)
                    .multilineTextAlignment(.center)
            } else {
                Text("Restore the moon to \(Int((threshold * 100).rounded()))% to unlock your next reset.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showPrestigeConfirm = true
            } label: {
                Text("New Moon Reset")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(container.canPrestige ? Theme.moonGold : Theme.deepBlue.opacity(0.5))
                    )
                    .foregroundStyle(container.canPrestige ? Theme.midnight : Theme.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!container.canPrestige)
            .accessibilityLabel("New Moon Reset")
            .accessibilityHint(container.canPrestige
                ? "Irreversibly resets your run to gain \(formatter.string(from: container.projectedShards)) Lucid Shards."
                : "Restore the moon further to unlock this reset.")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.deepBlue.opacity(0.35)))
    }

    private var lunarCodexLink: some View {
        NavigationLink {
            LunarCodexView()
        } label: {
            HStack(spacing: Theme.Space.md) {
                Image(systemName: "book.closed.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.moonGold)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Theme.deepBlue.opacity(0.6)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Lunar Codex")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Spend Lucid Shards on permanent blessings.")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: 4)
                HStack(spacing: 3) {
                    Image(systemName: ResourceType.lucidShards.systemImage)
                    Text(formatter.string(from: gameState.amount(of: .lucidShards)))
                }
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(Theme.moonGold)
                Image(systemName: "chevron.right").foregroundStyle(Theme.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .moonloomCard(opacity: 0.35)
        }
        .buttonStyle(.plain)
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .monospacedDigit()
        }
    }

    private func restore(_ node: RestorationNode) {
        guard container.restoreNode(node) else { return }
        burstText = "\(node.name) restored!"
        if reduceMotion {
            // Still bump the trigger; RewardBurstView keeps the animation minimal.
            burstTrigger += 1
        } else {
            withAnimation { burstTrigger += 1 }
        }
    }
}
