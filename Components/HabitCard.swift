import SwiftUI

struct HabitCard: View {
    let title: String
    let icon: String
    let currentDay: Int
    let targetDays: Int
    let isCompletedToday: Bool
    let isPower: Bool // true = Power (green), false = Agent (red)

    var progress: Double {
        Double(currentDay) / Double(targetDays)
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(isPower ? Color.matrixGreen : Color.agentRed)
                .frame(width: 44, height: 44)

            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.title)
                    .foregroundColor(Theme.primaryText)

                Text("DAY \(currentDay) OF \(targetDays)")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)

                ProgressBar(progress: progress, isPower: isPower)
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(isCompletedToday ? Color.matrixGreen : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    ZStack {
        Color.matrixBlack.ignoresSafeArea()
        VStack(spacing: 16) {
            HabitCard(
                title: "Morning Workout",
                icon: "figure.run",
                currentDay: 12,
                targetDays: Theme.habitFormationDays,
                isCompletedToday: true,
                isPower: true
            )
            HabitCard(
                title: "No Doomscrolling",
                icon: "arrow.down.circle",
                currentDay: 5,
                targetDays: Theme.habitFormationDays,
                isCompletedToday: false,
                isPower: false
            )
        }
        .padding()
    }
}
