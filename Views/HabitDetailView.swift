import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let power: Power?
    let agent: Agent?

    @State private var showDeleteAlert: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var showDialIn: Bool = false
    @State private var showSaveError: Bool = false
    @StateObject private var achievementManager = AchievementManager()

    private var isPower: Bool { power != nil }
    private var name: String { power?.name ?? agent?.name ?? "Unknown" }
    private var icon: String { power?.icon ?? agent?.icon ?? "questionmark" }
    private var currentStreak: Int { power?.currentStreak ?? agent?.currentStreak ?? 0 }
    private var longestStreak: Int { power?.longestStreak ?? agent?.longestStreak ?? 0 }
    private var targetDays: Int { power?.targetDays ?? agent?.targetDays ?? Theme.habitFormationDays }
    private var createdAt: Date { power?.createdAt ?? agent?.createdAt ?? Date() }
    private var totalCheckIns: Int { power?.checkIns.count ?? agent?.checkIns.count ?? 0 }
    private var habitCheckIns: [CheckIn] { power?.checkIns ?? agent?.checkIns ?? [] }
    private var isCompletedToday: Bool {
        power?.completedToday ?? agent?.resistedToday ?? false
    }

    private var accentColor: Color {
        isPower ? Color.matrixGreen : Color.agentRed
    }

    private var progressPercent: Double {
        Double(currentStreak) / Double(targetDays)
    }

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            // Subtle code rain
            CodeRainBackground(opacity: 0.1, speed: 0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Main Stats Card
                        statsCard

                        // Progress Section
                        progressSection

                        // History Heatmap
                        historySection

                        // Actions
                        actionsSection

                        // Danger Zone
                        dangerZone

                        Spacer(minLength: 50)
                    }
                    .padding(.top, Spacing.lg)
                }
            }
        }
        .alert("PURGE PROGRAM?", isPresented: $showDeleteAlert) {
            Button("CANCEL", role: .cancel) { }
            Button("PURGE", role: .destructive) {
                deleteHabit()
            }
        } message: {
            Text("This will permanently remove \(name) and all associated data. This cannot be undone.")
        }
        .alert("DELETE FAILED", isPresented: $showSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to delete habit. Please try again.")
        }
        .sheet(isPresented: $showEditSheet) {
            EditHabitSheet(power: power, agent: agent)
        }
        .fullScreenCover(isPresented: $showDialIn) {
            if let p = power {
                DialInView(power: p)
            } else if let a = agent {
                DialInView(agent: a)
            }
        }
        .onAppear {
            achievementManager.setContext(modelContext)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("BACK")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                }
                .foregroundColor(accentColor)
            }

            Spacer()

            Button(action: { showEditSheet = true }) {
                Text("EDIT")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(accentColor)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(spacing: Spacing.lg) {
            // Icon and Name
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(accentColor)
            }

            Text(name.uppercased())
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text(isPower ? "// HACK LOADED" : "// AGENT DETECTED")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color.mediumGray)

            // Status Badge
            if isCompletedToday {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                    Text(isPower ? "COMPLETED TODAY" : "RESISTED TODAY")
                }
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(accentColor)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(accentColor.opacity(0.2))
                .cornerRadius(Theme.cornerRadiusCompact)
            }
        }
        .padding(.vertical, Spacing.lg)
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: Spacing.md) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.charcoal, lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: min(progressPercent, 1.0))
                    .stroke(accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("DAY")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                    Text("\(currentStreak)")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(accentColor)
                    Text("OF \(targetDays)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
            }

            // Stats Grid
            HStack(spacing: Spacing.lg) {
                StatBox(title: "LONGEST", value: "\(longestStreak)", accent: accentColor)
                StatBox(title: "TOTAL LOGS", value: "\(totalCheckIns)", accent: accentColor)
                StatBox(title: "CREATED", value: formatDate(createdAt), accent: accentColor)
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(Spacing.lg)
        .background(Color.charcoal.opacity(0.5))
        .cornerRadius(Theme.cornerRadius)
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("// ACTIVITY LOG")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color.mediumGray)
                .padding(.horizontal, Spacing.md)

            HabitHeatmapView(checkIns: habitCheckIns, accentColor: accentColor)
                .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: Spacing.md) {
            // Dial In Button
            Button(action: { showDialIn = true }) {
                HStack {
                    Image(systemName: "power")
                        .font(.system(size: 18))
                    Text(isPower ? "DIAL IN" : "RESIST AGENT")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(Color.deepBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(accentColor)
                .cornerRadius(Theme.cornerRadius)
            }
            .disabled(isCompletedToday)
            .opacity(isCompletedToday ? 0.5 : 1.0)
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("// DANGER ZONE")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color.danger)
                .padding(.horizontal, Spacing.md)

            Button(action: { showDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                    Text(isPower ? "UNLOAD PROGRAM" : "PURGE AGENT")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                    Spacer()
                }
                .foregroundColor(Color.danger)
                .padding(Spacing.md)
                .background(Color.charcoal)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.danger.opacity(0.5), lineWidth: 1)
                )
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.top, Spacing.lg)
    }

    // MARK: - Helpers

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    private func deleteHabit() {
        if let p = power {
            modelContext.delete(p)
        } else if let a = agent {
            modelContext.delete(a)
        }

        do {
            try modelContext.save()
            // Trigger achievement
            achievementManager.checkDeleteHabitAchievement()
            dismiss()
        } catch {
            showSaveError = true
        }
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(Color.mediumGray)
        }
        .frame(maxWidth: .infinity)
    }
}


// MARK: - Habit Heatmap View

struct HabitHeatmapView: View {
    let checkIns: [CheckIn]
    let accentColor: Color

    private let columns = 7 // days per row (Mon-Sun)
    private let weeks = 5 // show 5 weeks of history

    private var checkInDates: Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return Set(checkIns.filter { $0.isSuccess }.map { formatter.string(from: $0.date) })
    }

    private var days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let totalDays = weeks * columns
        return (0..<totalDays).compactMap { offset in
            calendar.date(byAdding: .day, value: -(totalDays - 1 - offset), to: today)
        }
    }

    private func isCheckedIn(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return checkInDates.contains(formatter.string(from: date))
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // Day labels
            HStack(spacing: 3) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .frame(maxWidth: .infinity)
                }
            }

            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: columns), spacing: 3) {
                ForEach(days, id: \.self) { date in
                    let checked = isCheckedIn(date)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(checked ? accentColor : Color.charcoal)
                        .opacity(checked ? 1.0 : 0.5)
                        .frame(height: 14)
                        .overlay(
                            isToday(date) ?
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(accentColor, lineWidth: 1) : nil
                        )
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.charcoal.opacity(0.3))
        .cornerRadius(Theme.cornerRadius)
    }
}

#Preview {
    HabitDetailView(power: nil, agent: nil)
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}

