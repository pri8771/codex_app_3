import Foundation
import SwiftData

/// Owns the app's SwiftData `ModelContainer` and the shared schema.
enum AppDatabase {

    /// All persisted `@Model` types.
    static let schema = Schema([
        CurrencyRecord.self,
        BuildingRecord.self,
        UpgradeRecord.self,
        MilestoneRecord.self,
        PrestigeRecord.self,
        SettingsRecord.self,
        AchievementRecord.self,
        LunarCodexRecord.self,
        EntitlementRecord.self
    ])

    /// Build the app's persistent container with a layered recovery policy so
    /// launch can never hard-crash on a bad store:
    ///
    /// 1. Open the on-disk store (SwiftData lightweight migration handles the
    ///    additive v1→v2 changes — new entities and defaulted attributes).
    /// 2. If that fails (corruption or an incompatible migration), delete the
    ///    on-disk store files and create a fresh *on-disk* store, so the player
    ///    keeps a durable save going forward (just starts over).
    /// 3. As a last resort, fall back to an in-memory store so the app still runs.
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let primary = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        if let container = try? ModelContainer(for: schema, configurations: [primary]) {
            return container
        }
        if !inMemory {
            // The on-disk store failed to open. Remove it and retry fresh so the
            // player keeps a persistent (if reset) save rather than a volatile one.
            destroyOnDiskStore(for: primary)
            if let container = try? ModelContainer(for: schema, configurations: [primary]) {
                return container
            }
        }
        // Last resort: volatile in-memory store keeps launch alive.
        let memory = ModelConfiguration(isStoredInMemoryOnly: true)
        if let container = try? ModelContainer(for: schema, configurations: [memory]) {
            return container
        }
        // Effectively unreachable: an in-memory container for a valid schema
        // cannot realistically fail. Surface the invariant violation clearly.
        fatalError("Unable to initialise SwiftData ModelContainer for Moonloom.")
    }

    /// Delete the SwiftData store files backing the given configuration (the
    /// `.store`, `.store-wal`, and `.store-shm` sidecars), ignoring errors.
    private static func destroyOnDiskStore(for configuration: ModelConfiguration) {
        let url = configuration.url
        let fm = FileManager.default
        for suffix in ["", "-wal", "-shm"] {
            let path = URL(fileURLWithPath: url.path + suffix)
            try? fm.removeItem(at: path)
        }
    }
}
