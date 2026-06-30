import Foundation

/// Canonical StoreKit product identifiers and the in-game effect each one has
/// (MOONLOOM-PROMPT-008 / `MONETIZATION_PRD.md`). Monetization is strictly
/// cosmetic + convenience — no pay-to-win, no ads, no FOMO — consistent with the
/// cozy, non-extractive design posture.
enum ProductCatalog {

    // Cosmetic factory themes (non-consumable → owns a `ThemePalette`).
    static let celestialTheme = "com.moonloom.dream_pack_celestial"
    static let emberTheme = "com.moonloom.dream_pack_ember"
    // Cosmetic moth skins (non-consumable).
    static let goldenMoth = "com.moonloom.moth_skin_golden"
    static let shadowMoth = "com.moonloom.moth_skin_shadow"
    // Stardust packs (consumable → credits Stardust).
    static let stardustSmall = "com.moonloom.stardust_small"
    static let stardustMedium = "com.moonloom.stardust_medium"
    static let stardustLarge = "com.moonloom.stardust_large"
    // Convenience (non-consumable + subscription).
    static let offlineExpansion = "com.moonloom.offline_expansion"
    static let passMonthly = "com.moonloom.pass_monthly"

    /// All identifiers StoreKit should load.
    static let allProductIDs: [String] = [
        celestialTheme, emberTheme, goldenMoth, shadowMoth,
        stardustSmall, stardustMedium, stardustLarge,
        offlineExpansion, passMonthly
    ]

    /// Consumable Stardust granted by a product, if it is a Stardust pack.
    static func stardustAmount(for productID: String) -> Double? {
        switch productID {
        case stardustSmall: return 50
        case stardustMedium: return 175
        case stardustLarge: return 500
        default: return nil
        }
    }

    /// `true` for consumable products (finished immediately, not stored as an entitlement).
    static func isConsumable(_ productID: String) -> Bool {
        stardustAmount(for: productID) != nil
    }

    /// Theme palette id unlocked by owning a product, if it is a factory theme.
    static func themeID(for productID: String) -> String? {
        switch productID {
        case celestialTheme: return "celestial"
        case emberTheme: return "ember"
        default: return nil
        }
    }

    /// Moth-skin id unlocked by owning a product, if it is a moth skin.
    static func mothSkinID(for productID: String) -> String? {
        switch productID {
        case goldenMoth: return "golden"
        case shadowMoth: return "shadow"
        default: return nil
        }
    }

    /// Base offline cap (hours) granted by owning a convenience product.
    static func offlineCapHours(for productID: String) -> Int? {
        switch productID {
        case offlineExpansion: return 12
        case passMonthly: return 48
        default: return nil
        }
    }

    /// Offline-earnings multiplier granted by a product (Moonloom Pass → 2×).
    static func offlineMultiplier(for productID: String) -> Double {
        productID == passMonthly ? 2.0 : 1.0
    }

    static let passProductID = passMonthly
}
