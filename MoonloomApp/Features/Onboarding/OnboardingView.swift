import SwiftUI

/// First-launch onboarding (PROJECT_TRACKER T007-09). A short, cozy three-page
/// introduction to the dream, the loop, and the goal. Shown once; completion is
/// persisted via `GameState.hasCompletedOnboarding`.
struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0

    private struct Page: Identifiable {
        let id = UUID()
        let systemImage: String
        let title: String
        let body: String
    }

    private let pages: [Page] = [
        Page(systemImage: "moon.zzz.fill",
             title: "The moon has gone dark",
             body: "As keeper of the last Moonloom, you'll rebuild the Dream Factory and bring the moonlight back."),
        Page(systemImage: "hand.tap.fill",
             title: "Tap Buy to build",
             body: "Whisper Nets and other buildings earn Moonlight automatically, even while you're away. Tap \"Buy\" on a building to add another one — the more you own, the faster Moonlight grows."),
        Page(systemImage: "square.grid.2x2.fill",
             title: "Four screens, one loop",
             body: "Factory: buy and unlock buildings. Moon: spend Moonlight to restore the moon and prestige. Shop: cosmetics. Settings: options. Watch the gold tip banner at the top — it always tells you what to do next."),
    ]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            VStack {
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        pageView(item).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                Button {
                    if page < pages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(page < pages.count - 1 ? "Next" : "Begin weaving")
                }
                .buttonStyle(MoonloomPrimaryButtonStyle(isEnabled: true))
                .padding(.horizontal, Theme.Space.xl)
                .padding(.bottom, Theme.Space.lg)
            }
        }
    }

    private func pageView(_ item: Page) -> some View {
        VStack(spacing: Theme.Space.xl) {
            Spacer()
            Image(systemName: item.systemImage)
                .font(.system(size: 80))
                .foregroundStyle(Theme.moonGold)
                .shadow(color: Theme.moonGold.opacity(0.5), radius: 18)
                .accessibilityHidden(true)
            VStack(spacing: Theme.Space.md) {
                Text(item.title)
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textPrimary)
                Text(item.body)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, Theme.Space.xl)
            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}
