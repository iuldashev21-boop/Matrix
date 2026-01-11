import Foundation

// MARK: - Habit Protocol

/// Protocol that defines common properties for habits (Powers and Agents)
protocol HabitProtocol {
    var name: String { get }
    var icon: String { get }
    var currentStreak: Int { get }
    var targetDays: Int { get }
}

extension Power: HabitProtocol {}
extension Agent: HabitProtocol {}
