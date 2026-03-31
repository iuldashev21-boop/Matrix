import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Shared Types (duplicated from main app to avoid framework dependency)

private let appGroupID = "group.com.construct.MatrixHabit"
private let widgetDataKey = "com.matrixhabit.widget.data"

struct HabitSnapshot: Codable {
    let id: String
    let name: String
    let icon: String
    let streak: Int
    let completedToday: Bool
    let isPower: Bool
}

struct WidgetHabitData: Codable {
    let habits: [HabitSnapshot]
    let totalStreak: Int
    let completedToday: Int
    let totalScheduledToday: Int
    let lastUpdated: Date
}

// MARK: - Timeline Entry

struct MatrixHabitEntry: TimelineEntry {
    let date: Date
    let data: WidgetHabitData?
}

// MARK: - Timeline Provider

struct MatrixHabitTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MatrixHabitEntry {
        MatrixHabitEntry(date: Date(), data: sampleData)
    }

    func getSnapshot(in context: Context, completion: @escaping (MatrixHabitEntry) -> Void) {
        let entry = MatrixHabitEntry(date: Date(), data: readData() ?? sampleData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MatrixHabitEntry>) -> Void) {
        let entry = MatrixHabitEntry(date: Date(), data: readData())
        // Refresh at midnight (main app also triggers reloads on check-in)
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
            ?? Date().addingTimeInterval(86400)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func readData() -> WidgetHabitData? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: widgetDataKey),
              let decoded = try? JSONDecoder().decode(WidgetHabitData.self, from: data) else {
            return nil
        }
        return decoded
    }

    private var sampleData: WidgetHabitData {
        WidgetHabitData(
            habits: [
                HabitSnapshot(id: "1", name: "Meditate", icon: "brain.head.profile", streak: 12, completedToday: true, isPower: true),
                HabitSnapshot(id: "2", name: "Exercise", icon: "figure.run", streak: 7, completedToday: false, isPower: true),
                HabitSnapshot(id: "3", name: "No Sugar", icon: "xmark.shield", streak: 21, completedToday: true, isPower: false)
            ],
            totalStreak: 40,
            completedToday: 2,
            totalScheduledToday: 3,
            lastUpdated: Date()
        )
    }
}

// MARK: - Colors

private let matrixGreen = Color(red: 0, green: 1, blue: 65.0/255.0)
private let matrixBlack = Color(red: 13.0/255.0, green: 13.0/255.0, blue: 13.0/255.0)
private let charcoal = Color(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0)
private let mediumGray = Color(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0)

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let data: WidgetHabitData?

    var body: some View {
        if let data = data, !data.habits.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                // Header
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                        .foregroundColor(matrixGreen)
                    Text("MATRIX")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(matrixGreen)
                    Spacer()
                }

                // Progress
                Text("\(data.completedToday)/\(data.totalScheduledToday)")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(.white)

                Text("COMPLETE")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(mediumGray)

                Spacer()

                // Most urgent: first incomplete habit, or top streak if all done
                if let nextHabit = data.habits.first(where: { !$0.completedToday })
                    ?? data.habits.sorted(by: { $0.streak > $1.streak }).first {
                    HStack(spacing: 4) {
                        Image(systemName: nextHabit.icon)
                            .font(.system(size: 10))
                            .foregroundColor(nextHabit.completedToday ? matrixGreen : mediumGray)
                        Text(nextHabit.completedToday ? "\(nextHabit.streak)d" : nextHabit.name.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
            }
            .padding(12)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 24))
                    .foregroundColor(matrixGreen)
                Text("LOAD\nPROGRAM")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(mediumGray)
                    .multilineTextAlignment(.center)
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let data: WidgetHabitData?

    var body: some View {
        if let data = data, !data.habits.isEmpty {
            HStack(spacing: 12) {
                // Left side: summary
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                            .foregroundColor(matrixGreen)
                        Text("MATRIX")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(matrixGreen)
                    }

                    Text("\(data.completedToday)/\(data.totalScheduledToday)")
                        .font(.system(size: 36, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    Text("SIGNALS TODAY")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(mediumGray)

                    Spacer()

                    // Total streak
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        Text("\(data.totalStreak)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Text("TOTAL")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(mediumGray)
                    }
                }

                // Divider
                Rectangle()
                    .fill(charcoal)
                    .frame(width: 1)

                // Right side: habit list (top 4)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(data.habits.sorted(by: { $0.streak > $1.streak }).prefix(4).enumerated()), id: \.element.id) { _, habit in
                        HStack(spacing: 6) {
                            if habit.completedToday {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(matrixGreen)
                            } else {
                                Button(intent: CheckInHabitIntent(habitId: habit.id, habitName: habit.name, isPower: habit.isPower)) {
                                    Image(systemName: "circle")
                                        .font(.system(size: 11))
                                        .foregroundColor(mediumGray)
                                }
                                .buttonStyle(.plain)
                            }

                            Text(habit.name.uppercased())
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(habit.completedToday ? .white : mediumGray)
                                .lineLimit(1)

                            Spacer()

                            Text("\(habit.streak)d")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(matrixGreen)
                        }
                    }
                    Spacer()
                }
            }
            .padding(12)
        } else {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 28))
                    .foregroundColor(matrixGreen)
                VStack(alignment: .leading, spacing: 4) {
                    Text("MATRIXHABIT")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("Open app to load programs")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(mediumGray)
                }
                Spacer()
            }
            .padding(12)
        }
    }
}

// MARK: - Widget Definition

struct MatrixHabitWidget: Widget {
    let kind: String = "MatrixHabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatrixHabitTimelineProvider()) { entry in
            Group {
                if #available(iOSApplicationExtension 17.0, *) {
                    WidgetEntryView(entry: entry)
                        .containerBackground(matrixBlack, for: .widget)
                } else {
                    WidgetEntryView(entry: entry)
                        .background(matrixBlack)
                }
            }
        }
        .configurationDisplayName("MatrixHabit")
        .description("Track your habit streaks from the home screen.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MatrixHabitEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.data)
        case .systemMedium:
            MediumWidgetView(data: entry.data)
        case .accessoryCircular:
            CircularWidgetView(data: entry.data)
        case .accessoryRectangular:
            RectangularWidgetView(data: entry.data)
        case .accessoryInline:
            InlineWidgetView(data: entry.data)
        default:
            SmallWidgetView(data: entry.data)
        }
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    MatrixHabitWidget()
} timeline: {
    MatrixHabitEntry(date: Date(), data: WidgetHabitData(
        habits: [
            HabitSnapshot(id: "1", name: "Meditate", icon: "brain.head.profile", streak: 12, completedToday: true, isPower: true),
            HabitSnapshot(id: "2", name: "Exercise", icon: "figure.run", streak: 7, completedToday: false, isPower: true)
        ],
        totalStreak: 19,
        completedToday: 1,
        totalScheduledToday: 2,
        lastUpdated: Date()
    ))
}

#Preview(as: .systemMedium) {
    MatrixHabitWidget()
} timeline: {
    MatrixHabitEntry(date: Date(), data: WidgetHabitData(
        habits: [
            HabitSnapshot(id: "4", name: "Lock In", icon: "brain", streak: 32, completedToday: true, isPower: true),
            HabitSnapshot(id: "5", name: "Combat Prep", icon: "dumbbell.fill", streak: 21, completedToday: false, isPower: true),
            HabitSnapshot(id: "6", name: "Doomscrolling", icon: "iphone.slash", streak: 14, completedToday: false, isPower: false),
            HabitSnapshot(id: "7", name: "Deep Sleep", icon: "moon.zzz.fill", streak: 7, completedToday: true, isPower: true)
        ],
        totalStreak: 74,
        completedToday: 2,
        totalScheduledToday: 4,
        lastUpdated: Date()
    ))
}

#Preview(as: .accessoryCircular) {
    MatrixHabitWidget()
} timeline: {
    MatrixHabitEntry(date: Date(), data: WidgetHabitData(
        habits: [
            HabitSnapshot(id: "4", name: "Lock In", icon: "brain", streak: 32, completedToday: true, isPower: true),
            HabitSnapshot(id: "5", name: "Combat Prep", icon: "dumbbell.fill", streak: 21, completedToday: false, isPower: true)
        ],
        totalStreak: 53,
        completedToday: 1,
        totalScheduledToday: 3,
        lastUpdated: Date()
    ))
}

#Preview(as: .accessoryRectangular) {
    MatrixHabitWidget()
} timeline: {
    MatrixHabitEntry(date: Date(), data: WidgetHabitData(
        habits: [
            HabitSnapshot(id: "4", name: "Lock In", icon: "brain", streak: 32, completedToday: false, isPower: true),
            HabitSnapshot(id: "5", name: "Combat Prep", icon: "dumbbell.fill", streak: 21, completedToday: false, isPower: true),
            HabitSnapshot(id: "6", name: "Doomscrolling", icon: "iphone.slash", streak: 14, completedToday: true, isPower: false)
        ],
        totalStreak: 67,
        completedToday: 1,
        totalScheduledToday: 3,
        lastUpdated: Date()
    ))
}
