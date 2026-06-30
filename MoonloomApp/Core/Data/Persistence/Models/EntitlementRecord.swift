import Foundation
import SwiftData

/// SwiftData persistence for a StoreKit entitlement / owned product
/// (MOONLOOM-PROMPT-008). Mirrors `Transaction.currentEntitlements` so the app
/// can drive cosmetic ownership, the offline-cap expansion, and the Moonloom
/// Pass offline-first, then reconcile with StoreKit on launch. Consumables
/// (Stardust) are *not* stored here — they are credited directly to the balance.
@Model
final class EntitlementRecord {
    /// StoreKit product identifier, unique per save.
    @Attribute(.unique) var productID: String
    var purchaseDate: Date
    /// `true` while the entitlement is active (subscriptions can lapse).
    var isActive: Bool

    init(productID: String, purchaseDate: Date, isActive: Bool = true) {
        self.productID = productID
        self.purchaseDate = purchaseDate
        self.isActive = isActive
    }
}
