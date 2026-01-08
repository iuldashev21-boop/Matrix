import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var unlockedAchievements: [Achievement]

    private var unlockedIds: Set<String> {
        Set(unlockedAchievements.map { $0.id })
    }

    private var unlockedCount: Int {
        unlockedAchievements.count
    }

    private var totalCount: Int {
        AchievementLibrary.all.count
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.matrixBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Progress Header
                        progressHeader

                        // Categories
                        achievementSection(
                            title: "// STREAK DECRYPTIONS",
                            achievements: AchievementLibrary.streakAchievements
                        )

                        achievementSection(
                            title: "// CONSISTENCY PROTOCOLS",
                            achievements: AchievementLibrary.consistencyAchievements
                        )

                        achievementSection(
                            title: "// SPECIAL OPS",
                            achievements: AchievementLibrary.specialAchievements
                        )

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
                    .trim(from: 0, to: CGFloat(unlockedCount) / CGFloat(totalCount))
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
        .padding(.vertical, Spacing.lg)
    }

    private var totalXPEarned: Int {
        unlockedAchievements.compactMap { achievement in
            AchievementLibrary.definition(for: achievement.id)?.rarity.xpReward
        }.reduce(0, +)
    }

    // MARK: - Achievement Section

    private func achievementSection(title: String, achievements: [AchievementDefinition]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)
                .padding(.horizontal, Spacing.lg)

            ForEach(achievements) { achievement in
                AchievementRow(
                    achievement: achievement,
                    isUnlocked: unlockedIds.contains(achievement.id),
                    unlockedAt: unlockedAchievements.first { $0.id == achievement.id }?.unlockedAt
                )
                .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

// MARK: - Achievement Row

struct AchievementRow: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool
    let unlockedAt: Date?

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? rarityColor.opacity(0.2) : Color.charcoal)
                    .frame(width: 50, height: 50)

                Image(systemName: achievement.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isUnlocked ? rarityColor : Color.mediumGray)
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.name)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(isUnlocked ? .white : Color.mediumGray)

                    Spacer()

                    Text(achievement.rarity.rawValue)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(rarityColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(rarityColor.opacity(0.2))
                        .cornerRadius(4)
                }

                Text(isUnlocked ? achievement.description : "???")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .lineLimit(2)

                if let date = unlockedAt {
                    Text("Unlocked \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
            }
        }
        .padding(Spacing.md)
        .background(isUnlocked ? Color.charcoal : Color.charcoal.opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isUnlocked ? rarityColor.opacity(0.5) : Color.mediumGray.opacity(0.3), lineWidth: 1)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
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
