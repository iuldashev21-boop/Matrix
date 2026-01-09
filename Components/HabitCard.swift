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

    private var accentColor: Color {
        isPower ? Color.matrixGreen : Color.agentRed
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon with checkmark overlay when completed
            ZStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(accentColor)
                    .opacity(isCompletedToday ? 0.5 : 1.0)
                    .frame(width: 44, height: 44)

                if isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(accentColor)
                        .background(Color.matrixBlack)
                        .clipShape(Circle())
                        .offset(x: 14, y: 14)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(title)
                        .font(.title)
                        .foregroundColor(isCompletedToday ? Theme.secondaryText : Theme.primaryText)

                    if isCompletedToday {
                        Text("UPLOADED")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(accentColor.opacity(0.2))
                            .cornerRadius(4)
                    }
                }

                if isCompletedToday {
                    // Show countdown timer
                    UnlockCountdownView()
                } else {
                    Text("DAY \(currentDay) OF \(targetDays)")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)

                    ProgressBar(progress: progress, isPower: isPower)
                }
            }

            Spacer()

            // Chevron only when not completed (tappable hint)
            if !isCompletedToday {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.mediumGray)
            } else {
                // Lock icon when completed
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.mediumGray)
            }
        }
        .padding(Spacing.md)
        .background(isCompletedToday ? Theme.cardBackground.opacity(0.6) : Theme.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(isCompletedToday ? accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Unlock Countdown View

struct UnlockCountdownView: View {
    @State private var timeRemaining: String = ""
    @State private var timer: Timer?

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "clock")
                .font(.system(size: 10))
                .foregroundColor(Color.mediumGray)
            Text("UNLOCKS IN \(timeRemaining)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.mediumGray)
        }
        .onAppear {
            updateTimeRemaining()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
    }

    private func updateTimeRemaining() {
        let calendar = Calendar.current
        let now = Date()

        // Get midnight (start of next day)
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
              let midnight = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: tomorrow)) else {
            timeRemaining = "0:00:00"
            return
        }

        let difference = calendar.dateComponents([.hour, .minute, .second], from: now, to: midnight)

        let hours = difference.hour ?? 0
        let minutes = difference.minute ?? 0
        let seconds = difference.second ?? 0

        timeRemaining = String(format: "%d:%02d:%02d", hours, minutes, seconds)
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

