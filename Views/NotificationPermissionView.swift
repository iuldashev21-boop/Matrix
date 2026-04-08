import SwiftUI

struct NotificationPermissionView: View {
    @Binding var isPresented: Bool

    @State private var selectedTime: Date = NotificationManager.shared.timeAsDate()
    @State private var showContent = false
    @State private var isRequesting = false

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                if showContent {
                    // Icon
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 56))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()
                        .padding(.bottom, Spacing.sm)

                    // Title
                    Text("> ACTIVATE DAILY SIGNAL")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()

                    // Subtitle
                    Text("Set a daily reminder to check in\nwith your protocol.")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    // Time Picker
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorMultiply(Color.matrixGreen)
                        .frame(height: 150)
                        .padding(.horizontal, Spacing.xl)

                    Spacer()

                    // Enable Button
                    PrimaryButton(title: "ENABLE DAILY SIGNAL_") {
                        guard !isRequesting else { return }
                        isRequesting = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        Task {
                            let granted = await NotificationManager.shared.requestAuthorization()
                            await MainActor.run {
                                if granted {
                                    NotificationManager.shared.setTime(from: selectedTime)
                                    NotificationManager.shared.notificationsEnabled = true
                                }
                                markSeenAndDismiss()
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)

                    // Skip Button
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        markSeenAndDismiss()
                    } label: {
                        Text("MAYBE LATER")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                    .padding(.bottom, Spacing.xxl)
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showContent = true
                }
            }
        }
    }

    private func markSeenAndDismiss() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenNotificationPrompt)
        isPresented = false
    }
}
