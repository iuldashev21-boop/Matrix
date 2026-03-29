import SwiftUI
import WidgetKit

// MARK: - Accessory Circular (Progress Ring)

struct CircularWidgetView: View {
    let data: WidgetHabitData?

    var body: some View {
        if let data = data, data.totalScheduledToday > 0 {
            Gauge(
                value: Double(data.completedToday),
                in: 0...Double(data.totalScheduledToday)
            ) {
                Text("")
            } currentValueLabel: {
                Text("\(data.completedToday)/\(data.totalScheduledToday)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .gaugeStyle(.accessoryCircularCapacity)
        } else {
            Gauge(value: 0, in: 0...1) {
                Text("")
            } currentValueLabel: {
                Text("--")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .gaugeStyle(.accessoryCircularCapacity)
        }
    }
}

// MARK: - Accessory Rectangular (Terminal Habit List)

struct RectangularWidgetView: View {
    let data: WidgetHabitData?

    var body: some View {
        if let data = data, !data.habits.isEmpty {
            let scheduled = data.habits.filter { !$0.completedToday }
                .sorted { $0.streak > $1.streak }
            let completed = data.habits.filter(\.completedToday)
                .sorted { $0.streak > $1.streak }

            VStack(alignment: .leading, spacing: 2) {
                if scheduled.isEmpty {
                    ForEach(Array(completed.prefix(2).enumerated()), id: \.offset) { _, habit in
                        habitRow(habit, done: true)
                    }
                    Text("ALL CLEAR")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                } else {
                    ForEach(Array(scheduled.prefix(2).enumerated()), id: \.offset) { _, habit in
                        habitRow(habit, done: false)
                    }
                    let remaining = data.totalScheduledToday - data.completedToday
                    Text("\(remaining) REMAINING")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 2) {
                Text("> MATRIX")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                Text("LOAD PROGRAM")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func habitRow(_ habit: HabitSnapshot, done: Bool) -> some View {
        HStack(spacing: 4) {
            Text(done ? "+" : ">")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
            Text(habit.name.uppercased())
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .lineLimit(1)
            Spacer()
            Text("\(habit.streak)d")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
    }
}

// MARK: - Accessory Inline (Single Line)

struct InlineWidgetView: View {
    let data: WidgetHabitData?

    var body: some View {
        if let data = data, data.totalScheduledToday > 0 {
            if data.completedToday >= data.totalScheduledToday {
                Label("ALL SIGNALS ACTIVE", systemImage: "bolt.fill")
            } else {
                Label("\(data.completedToday)/\(data.totalScheduledToday) COMPLETE", systemImage: "bolt.fill")
            }
        } else {
            Label("MATRIX", systemImage: "bolt.fill")
        }
    }
}
