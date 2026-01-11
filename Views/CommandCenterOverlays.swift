import SwiftUI

// MARK: - Habit Tip Overlay

struct HabitTipOverlay: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: Spacing.md) {
                Image(systemName: "hand.tap")
                    .font(.system(size: 40))
                    .foregroundColor(Color.matrixGreen)

                Text("// SYSTEM TIP")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                Text("TAP ANY PROGRAM TO ACCESS\nMODIFICATION PROTOCOLS")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Edit, view stats, or delete programs")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.mediumGray)

                Button(action: onDismiss) {
                    Text("GOT IT")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.deepBlack)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.matrixGreen)
                        .cornerRadius(8)
                }
                .padding(.top, Spacing.sm)
            }
            .padding(Spacing.xl)
            .background(Color.charcoal)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.matrixGreen, lineWidth: 1)
            )
            .padding(.horizontal, Spacing.xl)
        }
    }
}

// MARK: - Ghost Tutorial Overlay

struct GhostTutorialOverlay: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header
                Text("// OPERATOR BRIEFING")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                Text("HOW TO SYNC")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                VStack(spacing: Spacing.lg) {
                    // Hack instruction
                    TutorialRow(
                        iconName: "hand.tap.fill",
                        iconColor: Color.matrixGreen,
                        title: "HACKS (Green)",
                        subtitle: "Tap → Hold to upload",
                        detail: nil
                    )

                    // Agent instruction
                    TutorialRow(
                        iconName: "hand.tap.fill",
                        iconColor: Color.agentRed,
                        title: "AGENTS (Red)",
                        subtitle: "Tap → Hold to resist",
                        detail: "Or report breach if you relapsed"
                    )

                    // Daily goal
                    TutorialRow(
                        iconName: "calendar",
                        iconColor: .white,
                        title: "DAILY PROTOCOL",
                        subtitle: "Check in every day to build streaks",
                        detail: nil
                    )
                }
                .padding(Spacing.lg)
                .background(Color.charcoal)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.matrixGreen.opacity(0.5), lineWidth: 1)
                )

                Button(action: onDismiss) {
                    Text("BEGIN PROTOCOL")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.deepBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.matrixGreen)
                        .cornerRadius(Theme.cornerRadius)
                }
            }
            .padding(.horizontal, Spacing.xl)
        }
    }
}

// MARK: - Tutorial Row Helper

private struct TutorialRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let detail: String?

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(iconColor)
                Text(subtitle)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                if let detail = detail {
                    Text(detail)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Daily Affirmation Overlay

struct DailyAffirmationOverlay: View {
    let affirmation: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: Spacing.lg) {
                // Terminal-style header
                Text("> DAILY TRANSMISSION")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                // Affirmation text
                Text(affirmation)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                // Dismiss hint
                Text("TAP TO CONTINUE")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
                    .padding(.top, Spacing.lg)
            }
            .padding(Spacing.xl)
        }
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? Color.matrixGreen : Color.mediumGray)
        }
    }
}
