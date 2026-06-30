import SwiftUI

/// "Daily dreams" reward modal (MOONLOOM-PROMPT-007). Shows the current streak
/// and the Stardust about to be granted, with a single satisfying claim beat.
struct DailyRewardView: View {
    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let claim: DailyRewardCalculator.Claim
    private let formatter = NumberAbbreviator()
    @State private var glow = false

    private var schedule: [Double] { container.config.dailyRewardSchedule }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: Theme.Space.xl) {
                Spacer(minLength: 0)

                Image(systemName: "gift.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.moonGold)
                    .shadow(color: Theme.moonGold.opacity(0.7), radius: glow ? 24 : 8)
                    .scaleEffect(glow ? 1.05 : 1)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: glow)

                VStack(spacing: Theme.Space.sm) {
                    Text("Daily Dreams")
                        .font(.title.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Day \(claim.newStreak) streak")
                        .font(.headline)
                        .foregroundStyle(Theme.softViolet)
                }

                streakStrip

                HStack(spacing: 6) {
                    Image(systemName: ResourceType.stardust.systemImage)
                        .foregroundStyle(Theme.moonGold)
                    Text("+\(formatter.string(from: claim.reward)) Stardust")
                        .font(.title2.weight(.bold).monospacedDigit())
                        .foregroundStyle(Theme.textPrimary)
                }

                Spacer(minLength: 0)

                Button {
                    Task {
                        await container.claimDailyReward()
                        dismiss()
                    }
                } label: {
                    Text("Collect")
                }
                .buttonStyle(MoonloomPrimaryButtonStyle(isEnabled: true))
                .padding(.horizontal, Theme.Space.xl)
                .accessibilityLabel("Collect \(formatter.string(from: claim.reward)) Stardust")
            }
            .padding()
        }
        .onAppear { glow = true }
    }

    /// A 7-day strip with the current streak day highlighted.
    private var streakStrip: some View {
        HStack(spacing: 6) {
            ForEach(0..<schedule.count, id: \.self) { index in
                let day = index + 1
                let reached = day <= claim.newStreak
                VStack(spacing: 4) {
                    Text("\(day)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                    Image(systemName: ResourceType.stardust.systemImage)
                        .font(.caption)
                        .foregroundStyle(reached ? Theme.moonGold : Theme.textSecondary.opacity(0.4))
                    Text(formatter.string(from: schedule[index]))
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(reached ? Theme.textPrimary : Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: Theme.Radius.sm)
                    .fill(Theme.deepBlue.opacity(day == claim.newStreak ? 0.7 : 0.3)))
                .overlay(RoundedRectangle(cornerRadius: Theme.Radius.sm)
                    .strokeBorder(day == claim.newStreak ? Theme.moonGold.opacity(0.7) : .clear, lineWidth: 1.5))
            }
        }
    }
}
