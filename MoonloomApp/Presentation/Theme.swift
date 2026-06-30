import SwiftUI

/// A swappable colour palette. Cosmetic "factory themes" bought in the Shop
/// select a different palette, re-skinning the whole app (see `ThemeCatalog`).
struct ThemePalette: Sendable, Equatable {
    let id: String
    let displayName: String
    let midnight: Color
    let deepBlue: Color
    let moonGold: Color
    let softViolet: Color

    static let moonlit = ThemePalette(
        id: "default", displayName: "Moonlit",
        midnight: Color(red: 0.05, green: 0.06, blue: 0.16),
        deepBlue: Color(red: 0.10, green: 0.13, blue: 0.30),
        moonGold: Color(red: 0.98, green: 0.85, blue: 0.55),
        softViolet: Color(red: 0.45, green: 0.40, blue: 0.75)
    )

    /// Sold as "Celestial Theme" (`com.moonloom.dream_pack_celestial`). Cool starlight.
    static let celestial = ThemePalette(
        id: "celestial", displayName: "Celestial",
        midnight: Color(red: 0.03, green: 0.07, blue: 0.16),
        deepBlue: Color(red: 0.06, green: 0.18, blue: 0.34),
        moonGold: Color(red: 0.70, green: 0.92, blue: 1.00),
        softViolet: Color(red: 0.40, green: 0.62, blue: 0.92)
    )

    /// Sold as "Ember Theme" (`com.moonloom.dream_pack_ember`). Warm glow.
    static let ember = ThemePalette(
        id: "ember", displayName: "Ember",
        midnight: Color(red: 0.12, green: 0.05, blue: 0.07),
        deepBlue: Color(red: 0.26, green: 0.10, blue: 0.10),
        moonGold: Color(red: 1.00, green: 0.72, blue: 0.40),
        softViolet: Color(red: 0.86, green: 0.45, blue: 0.45)
    )

    static let all: [ThemePalette] = [.moonlit, .celestial, .ember]

    static func palette(id: String) -> ThemePalette {
        all.first { $0.id == id } ?? .moonlit
    }
}

/// Centralised design system for Moonloom's moon/night/dream aesthetic.
///
/// Colours resolve from `Theme.current`, the active `ThemePalette`. Existing
/// views read `Theme.moonGold` etc. unchanged; swapping `Theme.current` (and
/// rebuilding the tree via `.id(theme)` at the root) re-skins the whole app, so
/// cosmetic factory themes actually change the look. Also exposes spacing,
/// radius, and reusable component styling tokens.
enum Theme {

    /// The active palette. Set at the root from the player's selected theme.
    static var current: ThemePalette = .moonlit

    // MARK: - Semantic colours (resolve from the active palette)
    static var midnight: Color { current.midnight }
    static var deepBlue: Color { current.deepBlue }
    static var moonGold: Color { current.moonGold }
    static var softViolet: Color { current.softViolet }
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)

    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [midnight, deepBlue], startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Spacing & radius tokens
    enum Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 18
    }
}

// MARK: - Reusable component styling

/// A standard "card" surface used across feature screens for visual consistency.
struct CardBackground: ViewModifier {
    var opacity: Double = 0.3
    var cornerRadius: CGFloat = Theme.Radius.md
    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Theme.deepBlue.opacity(opacity)))
    }
}

extension View {
    /// Wrap content in the standard Moonloom card surface.
    func moonloomCard(opacity: Double = 0.3, cornerRadius: CGFloat = Theme.Radius.md) -> some View {
        modifier(CardBackground(opacity: opacity, cornerRadius: cornerRadius))
    }
}

/// The primary call-to-action button style (gold when enabled, dim when not).
struct MoonloomPrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Space.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .fill(isEnabled ? Theme.moonGold : Theme.deepBlue.opacity(0.5))
            )
            .foregroundStyle(isEnabled ? Theme.midnight : Theme.textSecondary)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
