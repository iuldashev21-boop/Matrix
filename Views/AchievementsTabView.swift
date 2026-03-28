import SwiftUI
import SwiftData

struct AchievementsTabView: View {
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
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("> DECRYPTIONS")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)

                HStack {
                    Text("ACHIEVEMENTS")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Spacer()

                    // Progress badge
                    Text("\(unlockedCount)/\(totalCount)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGold)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.darkGray)
                        .cornerRadius(Theme.cornerRadiusCompact)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                                .stroke(Color.matrixGold.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.sm)

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Progress Ring
                    progressHeader

                    // Categories - Icon Grid
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

                    Spacer(minLength: 100)
                }
                .padding(.top, Spacing.md)
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
