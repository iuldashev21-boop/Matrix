import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var unlockedAchievements: [Achievement]

    @State private var selectedAchievement: AchievementDefinition? = nil

    private var unlockedIds: Set<String> {
        Set(unlockedAchievements.map { $0.id })
    }

    private var unlockedCount: Int {
        unlockedAchievements.count
    }

    private var totalCount: Int {
        AchievementLibrary.all.count
    }

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        NavigationView {
            ZStack {
                Color.matrixBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Progress Header
                        progressHeader

                        // Achievement Grid Sections
                        achievementGridSection(
                            title: "STREAK DECRYPTIONS",
                            achievements: AchievementLibrary.streakAchievements
                        )

                        achievementGridSection(
                            title: "CONSISTENCY PROTOCOLS",
                            achievements: AchievementLibrary.consistencyAchievements
                        )

                        achievementGridSection(
                            title: "SPECIAL OPS",
                            achievements: AchievementLibrary.specialAchievements
                        )

                        // Anomaly Reports
                        AnomalyReportsSection()

                        Spacer(minLength: 50)
                    }
                    .padding(.top, Spacing.md)
                }
            }
            .navigationTitle("DECRYPTIONS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CLOSE") { dismiss() }
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                }
            }
            .sheet(item: $selectedAchievement) { achievement in
                AchievementDetailSheet(
                    achievement: achievement,
                    isUnlocked: unlockedIds.contains(achievement.id),
                    unlockedAt: unlockedAchievements.first { $0.id == achievement.id }?.unlockedAt
                )
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .stroke(Color.charcoal, lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: totalCount > 0 ? CGFloat(unlockedCount) / CGFloat(totalCount) : 0)
                    .stroke(Color.matrixGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(unlockedCount)")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                    Text("/ \(totalCount)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
            }

            Text("DECRYPTION PROGRESS")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)

            Text("+\(totalXPEarned) XP EARNED")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
        }
        .padding(.vertical, Spacing.md)
    }

    private var totalXPEarned: Int {
        unlockedAchievements.compactMap { achievement in
            AchievementLibrary.definition(for: achievement.id)?.rarity.xpReward
        }.reduce(0, +)
    }

    // MARK: - Achievement Grid Section

    private func achievementGridSection(title: String, achievements: [AchievementDefinition]) -> some View {
        let unlockedInSection = achievements.filter { unlockedIds.contains($0.id) }.count

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section Header
            HStack {
                Text("// \(title)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.lightGray)

                Spacer()

                Text("\(unlockedInSection)/\(achievements.count)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(unlockedInSection == achievements.count ? Color.matrixGreen : Color.mediumGray)
            }
            .padding(.horizontal, Spacing.lg)

            // Icon Grid
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(achievements) { achievement in
                    AchievementBadge(
                        achievement: achievement,
                        isUnlocked: unlockedIds.contains(achievement.id)
                    )
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        selectedAchievement = achievement
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(Color.darkGray.opacity(0.5))
            .cornerRadius(12)
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Achievement Badge (Grid Icon)

struct AchievementBadge: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    @State private var glowPulse: Bool = false

    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return Color.lightGray
        case .rare: return Color.matrixGreen
        case .epic: return Color.matrixGold
        case .legendary: return Color.purple
        }
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(isUnlocked ? rarityColor.opacity(0.2) : Color.charcoal)
                .frame(width: 56, height: 56)

            // Glow ring for unlocked
            if isUnlocked {
                Circle()
                    .stroke(rarityColor, lineWidth: 2)
                    .frame(width: 56, height: 56)
                    .shadow(color: rarityColor.opacity(glowPulse ? 0.8 : 0.4), radius: glowPulse ? 8 : 4)
            }

            // Icon
            if isUnlocked {
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(rarityColor)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.mediumGray.opacity(0.5))
            }
        }
        .onAppear {
            if isUnlocked {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }
}

// MARK: - Achievement Detail Sheet

struct AchievementDetailSheet: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool
    let unlockedAt: Date?

    @Environment(\.dismiss) private var dismiss

    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return Color.lightGray
        case .rare: return Color.matrixGreen
        case .epic: return Color.matrixGold
        case .legendary: return Color.purple
        }
    }

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isUnlocked ? rarityColor.opacity(0.2) : Color.charcoal)
                        .frame(width: 80, height: 80)

                    if isUnlocked {
                        Circle()
                            .stroke(rarityColor, lineWidth: 3)
                            .frame(width: 80, height: 80)
                            .shadow(color: rarityColor.opacity(0.6), radius: 10)
                    }

                    Image(systemName: isUnlocked ? achievement.icon : "lock.fill")
                        .font(.system(size: 32))
                        .foregroundColor(isUnlocked ? rarityColor : Color.mediumGray)
                }

                // Name
                Text(achievement.name)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(isUnlocked ? .white : Color.mediumGray)

                // Rarity Badge
                Text(achievement.rarity.rawValue)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(rarityColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(rarityColor.opacity(0.2))
                    .cornerRadius(6)

                // Description
                Text(isUnlocked ? achievement.description : "??? ENCRYPTED ???")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)

                // XP Reward
                Text("+\(achievement.rarity.xpReward) XP")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                // Unlock Date
                if let date = unlockedAt {
                    Text("Decrypted \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }

                Spacer()
            }
            .padding(.top, Spacing.lg)
        }
    }
}

// MARK: - Achievement Unlock Toast

struct AchievementUnlockToast: View {
    let achievement: AchievementDefinition
    @Binding var isVisible: Bool

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(rarityColor.opacity(0.3))
                    .frame(width: 70, height: 70)

                Circle()
                    .stroke(rarityColor, lineWidth: 2)
                    .frame(width: 70, height: 70)

                Image(systemName: achievement.icon)
                    .font(.system(size: 30))
                    .foregroundColor(rarityColor)
            }
            .shadow(color: rarityColor.opacity(0.6), radius: 15)

            Text("DECRYPTION COMPLETE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.mediumGray)

            Text(achievement.name)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text("+\(achievement.rarity.xpReward) XP")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)

            Text(achievement.rarity.rawValue)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(rarityColor)
        }
        .padding(Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.charcoal)
                .shadow(color: rarityColor.opacity(0.4), radius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(rarityColor, lineWidth: 2)
        )
        .onTapGesture {
            withAnimation { isVisible = false }
        }
    }

    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return Color.lightGray
        case .rare: return Color.matrixGreen
        case .epic: return Color.matrixGold
        case .legendary: return Color.purple
        }
    }
}

#Preview {
    AchievementsView()
        .modelContainer(for: [Achievement.self], inMemory: true)
}
