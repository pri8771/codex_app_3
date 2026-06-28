import SwiftUI

/// "Welcome back!" modal summarising offline earnings (TECHNICAL_PRD §5).
struct OfflineWelcomeView: View {
    let result: OfflineEarningsCalculator.Result
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    private let formatter = NumberAbbreviator()

    private var earnedResources: [ResourceType] {
        ResourceType.allCases.filter { (result.earnings[$0] ?? 0) > 0 }
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.moonGold)
                    .scaleEffect(revealed || reduceMotion ? 1 : 0.5)
                    .opacity(revealed || reduceMotion ? 1 : 0)
                Text("Welcome back!")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Your moth couriers were busy for \(elapsedText) while you were away.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)

                VStack(spacing: 10) {
                    ForEach(Array(earnedResources.enumerated()), id: \.element) { index, type in
                        HStack {
                            Label(type.displayName, systemImage: type.systemImage)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Text("+\(formatter.string(from: result.earnings[type] ?? 0))")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Theme.moonGold)
                                .monospacedDigit()
                        }
                        .opacity(revealed || reduceMotion ? 1 : 0)
                        .offset(y: revealed || reduceMotion ? 0 : 12)
                        .animation(reduceMotion ? nil
                                   : .spring(response: 0.4, dampingFraction: 0.8).delay(0.15 * Double(index) + 0.2),
                                   value: revealed)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.deepBlue.opacity(0.5)))

                Button(action: onDismiss) {
                    Text("Collect")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.moonGold))
                        .foregroundStyle(Theme.midnight)
                }
                .buttonStyle(.plain)
            }
            .padding(28)
        }
        .onAppear {
            if reduceMotion {
                revealed = true
            } else {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { revealed = true }
            }
        }
    }

    private var elapsedText: String {
        OfflineDurationFormatter.string(from: result.creditedSeconds)
    }
}

/// Formats an elapsed offline duration like "2h 5m" or "45m".
enum OfflineDurationFormatter {
    static func string(from seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded())
        let hours = total / 3_600
        let minutes = (total % 3_600) / 60
        if hours > 0 && minutes > 0 { return "\(hours)h \(minutes)m" }
        if hours > 0 { return "\(hours)h" }
        if minutes > 0 { return "\(minutes)m" }
        return "\(total)s"
    }
}
