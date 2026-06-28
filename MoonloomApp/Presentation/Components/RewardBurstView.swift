import SwiftUI

/// A brief celebratory burst shown when a reward is collected (order fulfilled,
/// milestone reached). Pure SwiftUI animation — no assets. Auto-fades. The
/// parent bumps `trigger` (and updates `text`) to play it; using a counter
/// rather than a Bool lets repeated rewards replay reliably.
struct RewardBurstView: View {
    let text: String
    let trigger: Int

    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(Theme.moonGold)
            Text(text)
                .font(.headline.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 20).fill(Theme.deepBlue.opacity(0.9)))
        .scaleEffect(scale)
        .opacity(opacity)
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in play() }
    }

    private func play() {
        scale = 0.6
        opacity = 0
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
            opacity = 0
        }
    }
}
