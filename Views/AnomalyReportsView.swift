import SwiftUI

// MARK: - Anomaly Reports Section (For Signal Analysis)

struct AnomalyReportsSection: View {
    @StateObject private var anomalyManager = AnomalyManager()
    @State private var selectedReport: AnomalyReport? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section header
            Text("// ANOMALY REPORTS")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)
                .padding(.horizontal, Spacing.md)

            // Report list
            VStack(spacing: Spacing.sm) {
                ForEach(AnomalyManager.allReports) { report in
                    AnomalyRow(
                        report: report,
                        state: anomalyManager.getReportState(report.id)
                    )
                    .onTapGesture {
                        handleReportTap(report)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .sheet(item: $selectedReport) { report in
            AnomalyDetailView(
                report: report,
                state: anomalyManager.getReportState(report.id)
            )
        }
    }

    private func handleReportTap(_ report: AnomalyReport) {
        let state = anomalyManager.getReportState(report.id)

        switch state {
        case .locked:
            // Can't view locked reports
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .decrypting, .unlocked:
            selectedReport = report
        }
    }
}

// MARK: - Anomaly Row

struct AnomalyRow: View {
    let report: AnomalyReport
    let state: AnomalyManager.ReportState

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Status icon
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 24)

            // Title and progress
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(titleText)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(titleColor)

                if case .decrypting(let progress) = state {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.charcoal)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.warning)
                                .frame(width: geometry.size.width * (CGFloat(progress) / 5.0), height: 4)
                        }
                    }
                    .frame(width: 100, height: 4)

                    Text("DECRYPTING... \(progress * 20)%")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.warning)
                }

                if case .unlocked = state {
                    Text("ACCESS GRANTED")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                }
            }

            Spacer()

            // Chevron
            if case .locked = state {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.mediumGray)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color.mediumGray)
            }
        }
        .padding(Spacing.md)
        .background(Color.charcoal)
        .cornerRadius(Theme.cornerRadiusCompact)
        .opacity(isLocked(state) ? 0.6 : 1.0)
    }

    private var iconName: String {
        switch state {
        case .locked: return "lock.fill"
        case .decrypting: return "timer"
        case .unlocked: return "eye.fill"
        }
    }

    private var iconColor: Color {
        switch state {
        case .locked: return Color.mediumGray
        case .decrypting: return Color.warning
        case .unlocked: return Color.matrixGreen
        }
    }

    private var titleText: String {
        switch state {
        case .locked:
            return "FILE \(report.id): [ ENCRYPTED ]"
        case .decrypting, .unlocked:
            return "FILE \(report.id): \(report.title)"
        }
    }

    private var titleColor: Color {
        switch state {
        case .locked: return Color.mediumGray
        case .decrypting: return Color.warning
        case .unlocked: return Color.white
        }
    }
}

// MARK: - Anomaly Detail View

struct AnomalyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let report: AnomalyReport
    let state: AnomalyManager.ReportState

    @State private var displayedText: String = ""
    @State private var animationProgress: Double = 0
    @State private var animationTimer: Timer?

    private var revealPercentage: Double {
        switch state {
        case .locked: return 0
        case .decrypting(let progress): return Double(progress) / 5.0
        case .unlocked: return 1.0
        }
    }

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                headerView

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Title
                        Text(report.title)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)

                        // Category tag
                        Text(report.category.rawValue)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.lightGray)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.lightGray, lineWidth: 1)
                            )

                        // Body text (scrambled or revealed)
                        Text(displayedText)
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundColor(.white)
                            .lineSpacing(6)
                            .padding(.top, Spacing.md)
                    }
                    .padding(.horizontal, Spacing.md)
                }

                Spacer()
            }
        }
        .onAppear {
            startTextAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            // Classification
            Text("CLASSIFIED // EYES ONLY")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color.danger)

            Spacer()

            // ID
            Text("ID: \(report.id)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.mediumGray)

            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.matrixGreen)
            }
            .padding(.leading, Spacing.md)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.lg)
    }

    // MARK: - Text Animation

    private func startTextAnimation() {
        if case .unlocked = state {
            // Animate text settling
            animateTextSettling()
        } else {
            // Show static scrambled text
            displayedText = AnomalyManager.scrambleText(report.content, revealPercentage: revealPercentage)
        }
    }

    private func animateTextSettling() {
        var iterations = 0
        let maxIterations = 15

        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            iterations += 1
            let progress = Double(iterations) / Double(maxIterations)

            displayedText = AnomalyManager.scrambleText(report.content, revealPercentage: progress)

            if iterations >= maxIterations {
                timer.invalidate()
                animationTimer = nil
                displayedText = report.content
            }
        }
    }
}

// MARK: - Helper for opacity check

extension AnomalyRow {
    private func isLocked(_ state: AnomalyManager.ReportState) -> Bool {
        if case .locked = state { return true }
        return false
    }
}

#Preview {
    ZStack {
        Color.matrixBlack.ignoresSafeArea()
        AnomalyReportsSection()
    }
}

