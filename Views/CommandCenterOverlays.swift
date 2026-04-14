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
                        .cornerRadius(Theme.cornerRadiusCompact)
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
                .onTapGesture { onDismiss() }

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

// MARK: - Momentum Nudge Overlay (Day 3+ conversion prompt)

struct MomentumNudgeOverlay: View {
    let daysActive: Int
    let streak: Int
    let operativeName: String
    let onUpgrade: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {

                // Warning badge
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.agentRed)
                    Text("// THRESHOLD EXCEEDED")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.agentRed)
                }

                // Personalized headline
                VStack(spacing: Spacing.sm) {
                    Text("OPERATIVE \(operativeName.uppercased()),")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen.opacity(0.7))
                    Text("YOU'RE READY\nTO GO DEEPER.")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: Color.matrixGreen.opacity(0.25), radius: 10)
                }

                // Stats row
                HStack(spacing: Spacing.xl) {
                    VStack(spacing: 4) {
                        Text("\(daysActive)")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                        Text("DAYS IN")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                    Rectangle()
                        .fill(Color.agentRed.opacity(0.4))
                        .frame(width: 1, height: 40)
                    VStack(spacing: 4) {
                        Text("\(streak)")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(streak == 0 ? Color.agentRed : Color.matrixGreen)
                        Text("STREAK")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                }
                .padding(Spacing.md)
                .background(Color.charcoal)
                .cornerRadius(Theme.cornerRadiusCompact)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                        .stroke(Color.agentRed.opacity(0.3), lineWidth: 1)
                )

                // Body copy
                Text("\(daysActive) days of real momentum.\nYou've proven you can do this.\n\nNow stack more hacks, more resistance\nprotocols — and build a version of\nyourself the matrix can't touch.")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)

                // CTA
                VStack(spacing: Spacing.sm) {
                    Button(action: onUpgrade) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 14))
                            Text("LEVEL UP — UNLOCK ALL")
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.matrixGreen)
                        .cornerRadius(Theme.cornerRadius)
                        .shadow(color: Color.matrixGreen.opacity(0.5), radius: 10)
                    }

                    Button(action: onDismiss) {
                        Text("NOT YET")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                    .padding(.top, Spacing.xs)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.xl)
        }
    }
}

// MARK: - Share Signal Overlay (Day 7+ post-completion referral prompt)

struct ShareSignalOverlay: View {
    let onDismiss: () -> Void
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        ZStack {
            Color.black.opacity(0.88)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: Spacing.lg) {

                Text("// YOUR MISSION ISN'T OVER")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                VStack(spacing: 6) {
                    Text("YOU ESCAPED.")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Text("NOW GO BACK\nFOR THE OTHERS.")
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundColor(Color.agentRed)
                        .shadow(color: Color.agentRed.opacity(0.5), radius: 6)
                        .multilineTextAlignment(.center)
                }

                Text("Once you see the truth, you can't\nleave others behind.\n\nSomeone you know is still running on\nautopilot — trapped in patterns they\ncan't even name.\n\nOne share. One review.\nThat's how they find the exit.")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                VStack(spacing: Spacing.sm) {
                    ShareLink(
                        item: URL(string: "https://apps.apple.com/app/matrixhabit/id6757750786")!,
                        message: Text("This app helped me finally build real habits. Check it out.")
                    ) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                            Text("SEND THE SIGNAL")
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.matrixGreen)
                        .cornerRadius(Theme.cornerRadius)
                        .shadow(color: Color.matrixGreen.opacity(0.4), radius: 8)
                    }

                    Button {
                        requestReview()
                        onDismiss()
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                            Text("LEAVE A REVIEW")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(Color.matrixGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.charcoal)
                        .cornerRadius(Theme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .stroke(Color.matrixGreen.opacity(0.4), lineWidth: 1)
                        )
                    }

                    Button(action: onDismiss) {
                        Text("LATER")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                    .padding(.top, Spacing.xs)
                }
            }
            .padding(Spacing.xl)
            .background(Color.charcoal)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.matrixGreen.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal, Spacing.xl)
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
