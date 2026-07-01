import Foundation
import StoreKit
import OSLog

/// StoreKit 2 purchasing for Moonloom (MOONLOOM-PROMPT-008).
///
/// Loads the product catalog, runs the async purchase flow, listens for
/// transaction updates, and reconciles entitlements from
/// `Transaction.currentEntitlements`. Non-consumables and the subscription are
/// reported through `onEntitlementsChanged`; consumables (Stardust) are reported
/// through `onConsumablePurchased` and finished immediately.
///
/// Monetization is cosmetic + convenience only — no ads, no pay-to-win.
@MainActor
final class PurchaseManager: ObservableObject {

    @Published private(set) var products: [Product] = []
    @Published private(set) var activeEntitlements: Set<String> = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var purchasingProductID: String?
    @Published var lastErrorMessage: String?

    /// Active non-consumable / subscription entitlements changed.
    var onEntitlementsChanged: ((Set<String>) -> Void)?
    /// A consumable (Stardust pack) was purchased; credit it.
    var onConsumablePurchased: ((_ productID: String) -> Void)?

    private let logger = Logger(subsystem: "com.moonloom.app", category: "Purchases")
    private var updatesTask: Task<Void, Never>?

    // Persisted ledger of consumable transaction IDs already credited, so a
    // transaction redelivered via `Transaction.updates` (e.g. the app was
    // killed between crediting Stardust and calling `transaction.finish()`)
    // can't credit the same purchase twice.
    private static let processedConsumablesKey = "com.moonloom.app.processedConsumableTransactionIDs"
    private var processedConsumableTransactionIDs: Set<UInt64>

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: Self.processedConsumablesKey) ?? []
        processedConsumableTransactionIDs = Set(stored.compactMap(UInt64.init))

        // Listen for transactions that arrive outside an explicit purchase
        // (Ask to Buy approvals, renewals, restores on another device).
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(verification: update, creditConsumables: true)
            }
        }
    }

    deinit { updatesTask?.cancel() }

    /// Whether StoreKit returned any products (false in environments with no
    /// configured products, e.g. a plain simulator run without a .storekit file).
    var hasProducts: Bool { !products.isEmpty }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    /// Display price for a product id, falling back to the catalog's planned price.
    func displayPrice(for id: String, fallback: String) -> String {
        product(for: id)?.displayPrice ?? fallback
    }

    /// Load the product catalog and reconcile current entitlements.
    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let loaded = try await Product.products(for: ProductCatalog.allProductIDs)
            products = loaded.sorted { $0.price < $1.price }
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription, privacy: .public)")
        }
        await refreshEntitlements()
    }

    /// Purchase a product. Returns whether it completed successfully.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        purchasingProductID = product.id
        defer { purchasingProductID = nil }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                return await handle(verification: verification, creditConsumables: true)
            case .userCancelled:
                return false
            case .pending:
                lastErrorMessage = "Your purchase is pending approval."
                return false
            @unknown default:
                return false
            }
        } catch {
            lastErrorMessage = error.localizedDescription
            logger.error("Purchase failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    /// Restore purchases by syncing with the App Store, then reconcile.
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            lastErrorMessage = error.localizedDescription
            logger.error("AppStore.sync failed: \(error.localizedDescription, privacy: .public)")
        }
        await refreshEntitlements()
    }

    /// Rebuild the active entitlement set from StoreKit's current entitlements.
    func refreshEntitlements() async {
        var active: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                active.insert(transaction.productID)
            }
        }
        activeEntitlements = active
        onEntitlementsChanged?(active)
    }

    /// Subscription renewal state for the Moonloom Pass, if available.
    func passIsActive() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == ProductCatalog.passProductID,
               transaction.revocationDate == nil {
                return true
            }
        }
        return false
    }

    // MARK: - Transaction handling

    @discardableResult
    private func handle(verification: VerificationResult<Transaction>, creditConsumables: Bool) async -> Bool {
        guard case .verified(let transaction) = verification else {
            if case .unverified(_, let error) = verification {
                logger.error("Transaction failed verification: \(error.localizedDescription, privacy: .public)")
            }
            lastErrorMessage = "Could not verify the purchase."
            return false
        }
        if ProductCatalog.isConsumable(transaction.productID) {
            if creditConsumables && markConsumableProcessed(transaction.id) {
                onConsumablePurchased?(transaction.productID)
            }
        } else {
            await refreshEntitlements()
        }
        await transaction.finish()
        return true
    }

    /// Records a consumable transaction ID as credited. Returns `false` (and
    /// does not record) if it was already processed, so a redelivered but
    /// unfinished transaction can't credit Stardust twice.
    private func markConsumableProcessed(_ transactionID: UInt64) -> Bool {
        guard !processedConsumableTransactionIDs.contains(transactionID) else { return false }
        processedConsumableTransactionIDs.insert(transactionID)
        UserDefaults.standard.set(
            processedConsumableTransactionIDs.map(String.init),
            forKey: Self.processedConsumablesKey)
        return true
    }
}
