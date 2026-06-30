import SwiftUI

/// Settings: personalization (theme), progress (stats/achievements), audio,
/// notifications, offline info, purchases, data, and about.
struct SettingsView: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer

    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                personalizationSection
                progressSection
                audioSection
                notificationsSection
                offlineSection
                purchasesSection
                dataSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .confirmationDialog(
                "Reset all progress?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Erase everything", role: .destructive) {
                    Task { await container.resetProgress() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your save, including Lucid Shards and resets. Purchased cosmetics are kept. This cannot be undone.")
            }
        }
    }

    private var personalizationSection: some View {
        Section("Personalization") {
            Picker("Factory Theme", selection: themeBinding) {
                ForEach(ThemePalette.all, id: \.id) { palette in
                    if gameState.ownedThemeIDs.contains(palette.id) {
                        Text(palette.displayName).tag(palette.id)
                    }
                }
            }
            if gameState.ownedThemeIDs.count == 1 {
                Text("Unlock more themes in the Shop.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var progressSection: some View {
        Section("Progress") {
            NavigationLink {
                StatisticsView()
            } label: {
                Label("Statistics", systemImage: "chart.bar.fill")
            }
            NavigationLink {
                AchievementsView()
            } label: {
                Label("Achievements", systemImage: "trophy.fill")
            }
        }
    }

    private var audioSection: some View {
        Section("Sound & Haptics") {
            Toggle("Music", isOn: musicBinding)
            Toggle("Sound Effects & Haptics", isOn: sfxBinding)
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Offline reminders", isOn: notificationsBinding)
            Text("Get a gentle reminder when your moth couriers have gathered enough dreams.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var offlineSection: some View {
        Section("Offline Production") {
            HStack {
                Text("Offline cap")
                Spacer()
                Text("\(gameState.effectiveOfflineCapHours)h")
                    .foregroundStyle(.secondary)
            }
            if gameState.hasMoonloomPass {
                Label("Moonloom Pass: 2× offline earnings", systemImage: "crown.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("Your factory keeps working while away, up to the cap. Expand it in the Shop and the Lunar Codex.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var purchasesSection: some View {
        Section("Purchases") {
            Button {
                Task { await container.restorePurchases() }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Reset all progress", systemImage: "trash")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(appVersion).foregroundStyle(.secondary)
            }
            HStack {
                Text("Resets completed")
                Spacer()
                Text("\(gameState.resetCount)").foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Bindings (persist on change)

    private var themeBinding: Binding<String> {
        Binding(
            get: { gameState.theme },
            set: { container.selectTheme($0) }
        )
    }

    private var musicBinding: Binding<Bool> {
        Binding(
            get: { gameState.isMusicEnabled },
            set: { newValue in
                gameState.isMusicEnabled = newValue
                Task { await container.persistSettings() }
            }
        )
    }

    private var sfxBinding: Binding<Bool> {
        Binding(
            get: { gameState.isSFXEnabled },
            set: { newValue in
                gameState.isSFXEnabled = newValue
                Task { await container.persistSettings() }
            }
        )
    }

    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { gameState.isNotificationsEnabled },
            set: { newValue in
                Task { await container.updateNotifications(enabled: newValue) }
            }
        )
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
