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
             body: "Sleeping towns have lost their dreams. As keeper of the last Moonloom, you'll rebuild the Dream Factory and bring the moonlight back."),
        Page(systemImage: "building.2.fill",
             title: "Weave dreams while you sleep",
             body: "Catch whispers, spin dreamthread, and let moth couriers carry finished dreams to the moon. Your factory keeps working even while you're away."),
        Page(systemImage: "moon.stars.fill",
             title: "Restore the moon, biome by biome",
             body: "Spend Moonlight to relight the moon. When you've restored enough, a New Moon Reset begins a faster, brighter cycle.")
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
    }
}
