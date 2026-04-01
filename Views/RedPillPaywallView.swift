import SwiftUI
import SwiftData

struct RedPillPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var powers: [Power]
    @Query private var agents: [Agent]
    private let storeManager = StoreManager.shared

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    Spacer().frame(height: Spacing.xxl)

                    // Header icon
                    Image(systemName: "pill.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.6), radius: 20)

                    // Title
                    VStack(spacing: Spacing.sm) {
                        Text("TAKE THE RED PILL")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(.white)

                        Text("YOUR AWAKENING IS INCOMPLETE")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.red.opacity(0.8))
                    }

                    // Features list
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        featureRow(icon: "lock.open.fill", text: "UNLOCK ALL YOUR HABITS")
                        featureRow(icon: "plus.circle.fill", text: "CREATE CUSTOM PROGRAMS")
                        featureRow(icon: "widget.small", text: "HOME SCREEN WIDGETS")
                        featureRow(icon: "chart.xyaxis.line", text: "ADVANCED SIGNAL ANALYSIS")
                        featureRow(icon: "shield.checkered", text: "STREAK SHIELD PROTOCOL")
                    }
                    .padding(.horizontal, Spacing.lg)

                    // Separator
                    Rectangle()
                        .fill(Color.charcoal)
                        .frame(height: 1)
                        .padding(.horizontal, Spacing.xl)

                    // Privacy & value block
                    VStack(spacing: Spacing.sm) {
                        Text("ONE-TIME PURCHASE. NO SUBSCRIPTION.\nYOURS FOREVER.")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)

                        Text("YOUR DATA NEVER LEAVES YOUR DEVICE.\nNO ACCOUNTS. NO TRACKING. 100% PRIVATE.")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                            .multilineTextAlignment(.center)
                    }

                    // Purchase area
                    VStack(spacing: Spacing.md) {
                        if let product = storeManager.redPillProduct {
                            PrimaryButton(
                                title: storeManager.purchaseInProgress
                                    ? "PROCESSING..."
                                    : "UNLOCK — \(product.displayPrice)",
                                color: .red
                            ) {
                                Task { await storeManager.purchase() }
                            }
                            .disabled(storeManager.purchaseInProgress)
                            .opacity(storeManager.purchaseInProgress ? 0.6 : 1.0)
                        } else {
                            ProgressView()
                                .tint(Color.matrixGreen)
                                .task { await storeManager.loadProduct() }
                        }

                        Text("Pay once. Own it for life.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color.mediumGray)

                        Button("RESTORE PURCHASE") {
                            Task { await storeManager.restorePurchases() }
                        }
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.lightGray)
                        .disabled(storeManager.purchaseInProgress)

                        if let error = storeManager.errorMessage {
                            Text(error)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.agentRed)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)

                    Spacer().frame(height: Spacing.xl)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("NOT NOW")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.charcoal.opacity(0.6))
                            .cornerRadius(12)
                    }
                    .padding(Spacing.md)
                }
                Spacer()
            }
        }
        .onChange(of: storeManager.isRedPillOwned) { _, owned in
            if owned {
                storeManager.unlockAllHabits(powers: powers, agents: agents, context: modelContext)
                dismiss()
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.matrixGreen)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.matrixGreen)
        }
        .padding(.vertical, Spacing.xs)
    }
}
