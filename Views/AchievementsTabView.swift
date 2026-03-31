import SwiftUI
import SwiftData

struct AchievementsTabView: View {
    @Query private var unlockedAchievements: [Achievement]

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
                    Text("\(unlockedAchievements.count)/\(AchievementLibrary.all.count)")
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
                AchievementGridContent()
                    .padding(.top, Spacing.md)

                Spacer(minLength: 100)
            }
        }
    }
}
