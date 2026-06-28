import Foundation
import SwiftData

/// Owns the app's SwiftData `ModelContainer` and the shared schema.
enum AppDatabase {

    /// All persisted `@Model` types.
    static let schema = Schema([
        CurrencyRecord.self,
        BuildingRecord.self,
        UpgradeRecord.self,
        PrestigeRecord.self,
        SettingsRecord.self
    ])

    /// Build a container. Falls back to an in-memory store if the on-disk store
    /// cannot be opened, so the app never hard-crashes on launch (a corrupt or
    /// migration-incompatible store degrades to a fresh session instead).
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let primary = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        if let container = try? ModelContainer(for: schema, configurations: [primary]) {
            return container
        }
        // The on-disk store failed to open (corruption or incompatible
        // migration). Degrade to a fresh in-memory store so launch survives;
        // the player starts a new session rather than seeing a crash.
        let memory = ModelConfiguration(isStoredInMemoryOnly: true)
        if let container = try? ModelContainer(for: schema, configurations: [memory]) {
            return container
        }
        // Effectively unreachable: an in-memory container for a valid schema
        // cannot realistically fail. Surface the invariant violation clearly.
        fatalError("Unable to initialise SwiftData ModelContainer for Moonloom.")
    }
}
