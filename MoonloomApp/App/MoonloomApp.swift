import SwiftUI
import SwiftData

/// Application entry point. Wires up the SwiftData container, the dependency
/// injection container, and the root navigation, and bridges scene-phase
/// transitions into the container's lifecycle hooks (offline earnings, autosave).
@main
struct MoonloomApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var container: AppContainer

    private let modelContainer: ModelContainer

    init() {
        let modelContainer = AppDatabase.makeContainer()
        self.modelContainer = modelContainer
        _container = StateObject(wrappedValue: AppContainer(modelContainer: modelContainer))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(container.gameState)
                .environmentObject(container.purchaseManager)
                .preferredColorScheme(.dark)
                .task { await container.bootstrap() }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            Task { await handle(scenePhase: newPhase) }
        }
    }

    private func handle(scenePhase phase: ScenePhase) async {
        switch phase {
        case .background:
            await container.handleBackground()
        case .active:
            await container.handleForeground()
        case .inactive:
            break
        @unknown default:
            break
        }
    }
}
