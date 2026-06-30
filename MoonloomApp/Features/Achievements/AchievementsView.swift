import SwiftUI

/// Achievements gallery (MOONLOOM-PROMPT-007). Grouped by category, each row
/// shows whether it's unlocked and its Stardust reward. Reached from Settings.
struct AchievementsView: View {
    @EnvironmentObject private var gameState: GameState

    private let formatter = NumberAbbreviator()
    private let all = AchievementCatalog.all

    private var unlockedCount: Int {
        all.filter { gameState.isAchievementUnlocked($0.id) }.count
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Theme.Space.lg) {
                    header
                    ForEach(Achievement.Category.allCases, id: \.self) { category in
                        section(for: category)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("\(unlockedCount) / \(all.count)")
                .font(.system(.largeTitle, design: .rounded).weight(.bold).monospacedDigit())
                .foregroundStyle(Theme.moonGold)
            Text("achievements unlocked")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            ProgressView(value: Double(unlockedCount), total: Double(all.count))
                .tint(Theme.moonGold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .moonloomCard(opacity: 0.3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(unlockedCount) of \(all.count) achievements unlocked")
    }

    private func section(for category: Achievement.Category) -> some View {
        let items = all.filter { $0.category == category }
        return VStack(alignment: .leading, spacing: Theme.Space.sm) {
            Text(category.rawValue)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            ForEach(items) { achievement in
                row(for: achievement)
            }
        }
    }

    private func row(for achievement: Achievement) -> some View {
        let unlocked = gameState.isAchievementUnlocked(achievement.id)
        return HStack(spacing: Theme.Space.md) {
            Image(systemName: unlocked ? achievement.systemImage : "lock.fill")
                .font(.title3)
                .foregroundStyle(unlocked ? Theme.moonGold : Theme.textSecondary.opacity(0.6))
                .frame(width: 38, height: 38)
                .background(Circle().fill(Theme.deepBlue.opacity(unlocked ? 0.7 : 0.4)))
                .shadow(color: unlocked ? Theme.moonGold.opacity(0.5) : .clear, radius: 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(unlocked ? Theme.textPrimary : Theme.textSecondary)
                Text(achievement.detail)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 4)
            if achievement.stardustReward > 0 {
                HStack(spacing: 3) {
                    Image(systemName: ResourceType.stardust.systemImage)
                    Text(formatter.string(from: achievement.stardustReward))
                }
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(unlocked ? Theme.moonGold : Theme.textSecondary)
            }
        }
        .padding(Theme.Space.md)
        .moonloomCard(opacity: unlocked ? 0.4 : 0.2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.name), \(unlocked ? "unlocked" : "locked"). \(achievement.detail)")
    }
}
