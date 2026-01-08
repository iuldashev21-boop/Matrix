import SwiftUI

struct WhiteRabbitOverlay: View {
    @Binding var isVisible: Bool
    @State private var rabbitPosition: RabbitCorner = .topLeading
    @State private var opacity: Double = 0
    @State private var showRewardModal: Bool = false
    @State private var rewardType: RewardType = .cheatKey
    @State private var twitchOffset: CGSize = .zero
    @State private var hasBeenTapped: Bool = false
    @State private var idleTimer: Timer?

    let onRewardClaimed: (RewardType) -> Void

    enum RabbitCorner: CaseIterable {
        case topLeading, topTrailing, bottomLeading, bottomTrailing
    }

    enum RewardType {
        case cheatKey
        case cosmeticHack

        var title: String {
            switch self {
            case .cheatKey: return "CHEAT KEY"
            case .cosmeticHack: return "COSMETIC HACK"
            }
        }

        var description: String {
            switch self {
            case .cheatKey: return "Restores 1 lost signal packet."
            case .cosmeticHack: return "New visual enhancement unlocked."
            }
        }

        var icon: String {
            switch self {
            case .cheatKey: return "key.fill"
            case .cosmeticHack: return "paintbrush.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            // Rabbit Icon
            if !hasBeenTapped {
                rabbitIcon
            }

            // Reward Modal
            if showRewardModal {
                rewardModalView
            }
        }
        .onAppear {
            setupRabbit()
        }
        .onDisappear {
            idleTimer?.invalidate()
            idleTimer = nil
        }
    }

    // MARK: - Rabbit Icon

    private var rabbitIcon: some View {
        Button(action: rabbitTapped) {
            Image(systemName: "hare.fill")
                .font(.system(size: 28))
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.8), radius: 4)
                .blur(radius: 0.5)
        }
        .frame(width: 44, height: 44)
        .offset(twitchOffset)
        .opacity(opacity)
        .position(positionForCorner(rabbitPosition))
        .onAppear {
            startIdleAnimation()
            startDisappearTimer()
        }
    }

    // MARK: - Reward Modal

    private var rewardModalView: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }

            // Modal card
            VStack(spacing: Spacing.lg) {
                // Header
                Text("OBJECT_FOUND")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                Text("// UNIDENTIFIED CODE FRAGMENT")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.mediumGray)

                // Icon
                Image(systemName: rewardType.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Color.matrixGreen)
                    .padding(.vertical, Spacing.md)

                // Item name
                Text(rewardType.title)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                // Description
                Text(rewardType.description)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .multilineTextAlignment(.center)

                // Button
                Button(action: claimReward) {
                    Text("INTEGRATE CODE")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.deepBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.matrixGreen)
                        .cornerRadius(Theme.cornerRadius)
                }
                .padding(.top, Spacing.md)
            }
            .padding(Spacing.xl)
            .frame(width: 300)
            .background(Color.deepBlack)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.matrixGreen, lineWidth: 2)
            )
            .scaleEffect(showRewardModal ? 1.0 : 0.1)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showRewardModal)
        }
    }

    // MARK: - Positioning

    private func positionForCorner(_ corner: RabbitCorner) -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let inset: CGFloat = 60 // Safe area + spacing

        switch corner {
        case .topLeading:
            return CGPoint(x: inset, y: inset + 80)
        case .topTrailing:
            return CGPoint(x: screenWidth - inset, y: inset + 80)
        case .bottomLeading:
            return CGPoint(x: inset, y: screenHeight - inset - 100)
        case .bottomTrailing:
            return CGPoint(x: screenWidth - inset, y: screenHeight - inset - 100)
        }
    }

    // MARK: - Setup & Animations

    private func setupRabbit() {
        // Random corner
        rabbitPosition = RabbitCorner.allCases.randomElement() ?? .topLeading

        // Random reward type
        rewardType = Bool.random() ? .cheatKey : .cosmeticHack

        // Fade in with glitch effect
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 0.9
        }
    }

    private func startIdleAnimation() {
        // Twitch animation loop
        idleTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [self] _ in
            guard !hasBeenTapped else {
                idleTimer?.invalidate()
                return
            }

            withAnimation(.easeInOut(duration: 0.1)) {
                twitchOffset = CGSize(
                    width: CGFloat.random(in: -2...2),
                    height: CGFloat.random(in: -2...2)
                )
                opacity = 0.8
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    twitchOffset = .zero
                    opacity = 0.9
                }
            }
        }
    }

    private func startDisappearTimer() {
        // Disappear after 5 seconds if not tapped
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            guard !hasBeenTapped else { return }

            withAnimation(.easeOut(duration: 1.0)) {
                opacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isVisible = false
            }
        }
    }

    // MARK: - Actions

    private func rabbitTapped() {
        hasBeenTapped = true

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        // Hide rabbit, show modal
        withAnimation(.easeOut(duration: 0.2)) {
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showRewardModal = true
            }
        }
    }

    private func claimReward() {
        // Haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Callback
        onRewardClaimed(rewardType)

        // Dismiss
        dismissModal()
    }

    private func dismissModal() {
        withAnimation {
            showRewardModal = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isVisible = false
        }
    }
}

// MARK: - White Rabbit Manager

class WhiteRabbitManager: ObservableObject {
    @Published var shouldShowRabbit: Bool = false

    private let appearanceChance: Double = 0.05 // 5% chance per session

    func checkForRabbit() {
        let roll = Double.random(in: 0...1)
        if roll < appearanceChance {
            shouldShowRabbit = true
        }
    }

    func rabbitDismissed() {
        shouldShowRabbit = false
    }

    // Reward storage
    static func addCheatKey() {
        let current = UserDefaults.standard.integer(forKey: "cheatKeys")
        UserDefaults.standard.set(current + 1, forKey: "cheatKeys")
    }

    static func getCheatKeys() -> Int {
        return UserDefaults.standard.integer(forKey: "cheatKeys")
    }

    static func useCheatKey() -> Bool {
        let current = getCheatKeys()
        if current > 0 {
            UserDefaults.standard.set(current - 1, forKey: "cheatKeys")
            return true
        }
        return false
    }
}

#Preview {
    ZStack {
        Color.matrixBlack.ignoresSafeArea()
        WhiteRabbitOverlay(isVisible: .constant(true)) { reward in
            print("Claimed: \(reward)")
        }
    }
}
