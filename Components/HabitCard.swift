import SwiftUI

struct HabitCard: View {
    let title: String
    let icon: String
    let currentDay: Int
    let targetDays: Int
    let isCompletedToday: Bool
    let isPower: Bool // true = Power (green), false = Agent (red)
    var subtitle: String? = nil // Optional short explanation
    var isRestDay: Bool = false // Not scheduled for today
    var isLocked: Bool = false
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var progress: Double {
        guard targetDays > 0 else { return 0 }
        return Double(currentDay) / Double(targetDays)
    }

    private var accentColor: Color {
        isPower ? Color.matrixGreen : Color.agentRed
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon with overlay
            ZStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(accentColor)
                    .opacity(isLocked ? 0.3 : (isCompletedToday || isRestDay ? 0.5 : 1.0))
                    .frame(width: 44, height: 44)

                if isLocked {
                    Image(systemName: "pill.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red.opacity(0.8))
                        .offset(x: 14, y: 14)
                } else if isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(accentColor)
                        .background(Color.matrixBlack)
                        .clipShape(Circle())
                        .offset(x: 14, y: 14)
                } else if isRestDay {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.mediumGray)
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
                        .foregroundColor(isLocked ? Theme.primaryText.opacity(0.4) : (isCompletedToday ? Theme.secondaryText : Theme.primaryText))

                    if isLocked {
                        Text("LOCKED")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(Theme.cornerRadiusSm)
                    } else if isCompletedToday {
                        Text("UPLOADED")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(accentColor.opacity(0.2))
                            .cornerRadius(Theme.cornerRadiusSm)
                    }
                }

                if isLocked {
                    Text("TAKE THE RED PILL TO UNLOCK")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.red.opacity(0.5))
                        .lineLimit(1)
                } else if isCompletedToday {
                    UnlockCountdownView()
                } else {
                    if let subtitle = subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Theme.secondaryText.opacity(0.8))
                            .lineLimit(1)
                    }

                    Text("DAY \(currentDay) OF \(targetDays)")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)

                    ProgressBar(progress: progress, isPower: isPower)
                }
            }

            Spacer()

            // Right side
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.red.opacity(0.5))
            } else if onEdit != nil || onDelete != nil {
                Menu {
                    if let onEdit = onEdit {
                        Button(action: onEdit) {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                    if let onDelete = onDelete {
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.mediumGray)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            } else {
                if isRestDay {
                    Image(systemName: "zzz")
                        .font(.system(size: 14))
                        .foregroundColor(Color.mediumGray)
                } else if !isCompletedToday {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.mediumGray)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.mediumGray)
                }
            }
        }
        .padding(Spacing.md)
        .background(isLocked ? Theme.cardBackground.opacity(0.4) : (isCompletedToday ? Theme.cardBackground.opacity(0.6) : Theme.cardBackground))
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(isLocked ? Color.red.opacity(0.2) : (isCompletedToday ? accentColor.opacity(0.5) : Color.clear), lineWidth: 1)
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

