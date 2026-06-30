import SwiftUI

/// Cosmetics & convenience shop, wired to StoreKit 2 (MOONLOOM-PROMPT-008).
///
/// All purchases are cosmetic or convenience — no pay-to-win, no ads, no FOMO —
/// in keeping with the cozy, non-extractive design posture. Owned items show an
/// "Owned" badge; consumables (Stardust) can be bought repeatedly. When StoreKit
/// has no configured products (e.g. a plain simulator run), buying surfaces a
/// friendly "store unavailable" message rather than a silent no-op.
struct ShopView: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var purchaseManager: PurchaseManager

    private let items = ShopCatalog.items
    private let formatter = NumberAbbreviator()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: Theme.Space.md) {
                        stardustBalance
                        if gameState.hasMoonloomPass { passBanner }
                        cozyNote
                        ForEach(items) { item in
                            row(for: item)
                        }
                        restoreButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Store", isPresented: errorAlertPresented) {
                Button("OK") { purchaseManager.lastErrorMessage = nil }
            } message: {
                Text(purchaseManager.lastErrorMessage ?? "")
            }
        }
    }

    private var stardustBalance: some View {
        HStack(spacing: 6) {
            Image(systemName: ResourceType.stardust.systemImage).foregroundStyle(Theme.moonGold)
            Text("\(formatter.string(from: gameState.amount(of: .stardust))) Stardust")
                .font(.headline.monospacedDigit())
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, Theme.Space.lg)
        .padding(.vertical, Theme.Space.sm)
        .background(Capsule().fill(Theme.deepBlue.opacity(0.5)))
    }

    private var passBanner: some View {
        Label("Moonloom Pass active — 2× offline earnings + 48h cap.", systemImage: "crown.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Theme.moonGold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .moonloomCard(opacity: 0.4)
    }

    private var cozyNote: some View {
        Label("Everything here is cosmetic or convenience. No ads, no pay-to-win — just support for the dream.",
              systemImage: "heart.fill")
            .font(.caption)
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .moonloomCard(opacity: 0.2)
    }

    private func row(for item: ShopItem) -> some View {
        let owned = isOwned(item)
        let price = purchaseManager.displayPrice(for: item.id, fallback: item.displayPrice)
        let isBusy = purchaseManager.purchasingProductID == item.id

        return HStack(spacing: Theme.Space.md) {
            Image(systemName: item.systemImage)
                .font(.title2)
                .foregroundStyle(Theme.moonGold)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.deepBlue.opacity(0.7)))
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                Text(item.kind.rawValue)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.softViolet)
            }
            Spacer(minLength: Theme.Space.sm)
            buyControl(item: item, owned: owned, price: price, isBusy: isBusy)
        }
        .padding()
        .moonloomCard(opacity: 0.25)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(owned ? "owned" : price)")
    }

    @ViewBuilder
    private func buyControl(item: ShopItem, owned: Bool, price: String, isBusy: Bool) -> some View {
        if owned {
            Label("Owned", systemImage: "checkmark.seal.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.moonGold)
        } else {
            Button {
                Task { await container.buy(item) }
            } label: {
                Group {
                    if isBusy {
                        ProgressView().tint(Theme.midnight)
                    } else {
                        Text(price)
                    }
                }
                .font(.subheadline.weight(.bold))
                .padding(.vertical, 8).padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: Theme.Radius.md).fill(Theme.moonGold))
                .foregroundStyle(Theme.midnight)
            }
            .buttonStyle(.plain)
            .disabled(isBusy)
        }
    }

    private var restoreButton: some View {
        Button {
            Task { await container.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.softViolet)
        }
        .padding(.top, Theme.Space.sm)
    }

    /// Non-consumables (themes, skins, expansion, pass) can be "owned".
    private func isOwned(_ item: ShopItem) -> Bool {
        guard !ProductCatalog.isConsumable(item.id) else { return false }
        return gameState.ownsEntitlement(item.id)
    }

    private var errorAlertPresented: Binding<Bool> {
        Binding(
            get: { purchaseManager.lastErrorMessage != nil },
            set: { if !$0 { purchaseManager.lastErrorMessage = nil } }
        )
    }
}
