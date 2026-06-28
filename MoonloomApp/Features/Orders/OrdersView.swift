import SwiftUI

/// Dream Orders board: the player delivers resources to fulfil the active order
/// for a Stardust reward, with upcoming orders previewed. Fulfilment is wired
/// through `AppContainer`; a reward burst plays on success.
struct OrdersView: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss

    @State private var burstTrigger = 0
    @State private var burstText = ""

    private let formatter = NumberAbbreviator()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        intro
                        ForEach(Array(gameState.activeOrders.enumerated()), id: \.element.id) { offset, order in
                            orderCard(order, isActive: offset == 0)
                        }
                    }
                    .padding()
                }
                RewardBurstView(text: burstText, trigger: burstTrigger)
            }
            .navigationTitle("Dream Orders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.tint(Theme.moonGold)
                }
            }
        }
    }

    private var intro: some View {
        Text("Deliver resources to fulfil dream orders and earn Stardust.")
            .font(.caption)
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func orderCard(_ order: DreamOrder, isActive: Bool) -> some View {
        let held = gameState.amount(of: order.requestResource)
        let progress = min(1.0, order.requestAmount > 0 ? held / order.requestAmount : 0)
        let canFulfill = isActive && gameState.canFulfill(order)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(order.title)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                if !isActive {
                    Label("Upcoming", systemImage: "hourglass")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Text(order.flavor)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 6) {
                Image(systemName: order.requestResource.systemImage).foregroundStyle(Theme.softViolet)
                Text("Deliver \(formatter.string(from: order.requestAmount)) \(order.requestResource.displayName)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            ProgressView(value: progress)
                .tint(Theme.moonGold)
            Text("\(formatter.string(from: held)) / \(formatter.string(from: order.requestAmount))")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(Theme.textSecondary)

            HStack {
                Label("\(formatter.string(from: order.rewardAmount)) Stardust",
                      systemImage: ResourceType.stardust.systemImage)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.moonGold)
                Spacer()
                if isActive {
                    Button {
                        fulfill(order)
                    } label: {
                        Text("Fulfill")
                            .font(.subheadline.weight(.bold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 18)
                            .background(RoundedRectangle(cornerRadius: 12)
                                .fill(canFulfill ? Theme.moonGold : Theme.deepBlue.opacity(0.5)))
                            .foregroundStyle(canFulfill ? Theme.midnight : Theme.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canFulfill)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16)
            .fill(Theme.deepBlue.opacity(isActive ? 0.4 : 0.2)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(canFulfill ? Theme.moonGold.opacity(0.6) : .clear, lineWidth: 1.5)
        )
    }

    private func fulfill(_ order: DreamOrder) {
        guard container.fulfillOrder(order) else { return }
        burstText = "+\(formatter.string(from: order.rewardAmount)) Stardust"
        burstTrigger += 1
    }
}
