import Foundation

struct PresetHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let category: String
}

enum PresetHabits {
    // MARK: - Powers (Good Habits to Build)

    static let powers: [PresetHabit] = [
        PresetHabit(name: "Morning Workout", icon: "figure.run", category: "Fitness"),
        PresetHabit(name: "Read 30 Minutes", icon: "book", category: "Learning"),
        PresetHabit(name: "Meditate", icon: "brain.head.profile", category: "Mindfulness"),
        PresetHabit(name: "Cold Shower", icon: "drop", category: "Discipline"),
        PresetHabit(name: "No Phone First Hour", icon: "iphone.slash", category: "Focus"),
        PresetHabit(name: "Journal", icon: "pencil.and.scribble", category: "Reflection"),
        PresetHabit(name: "8 Hours Sleep", icon: "bed.double", category: "Recovery"),
        PresetHabit(name: "Drink Water", icon: "drop.fill", category: "Health"),
        PresetHabit(name: "Walk 10K Steps", icon: "figure.walk", category: "Fitness"),
        PresetHabit(name: "Learn Something New", icon: "lightbulb", category: "Growth")
    ]

    // MARK: - Agents (Bad Habits to Defeat)

    static let agents: [PresetHabit] = [
        PresetHabit(name: "No Porn", icon: "eye.slash", category: "Discipline"),
        PresetHabit(name: "No Vaping", icon: "smoke", category: "Health"),
        PresetHabit(name: "No Smoking", icon: "smoke.fill", category: "Health"),
        PresetHabit(name: "No Junk Food", icon: "fork.knife", category: "Health"),
        PresetHabit(name: "No Doomscrolling", icon: "arrow.down.circle", category: "Focus"),
        PresetHabit(name: "No Alcohol", icon: "wineglass", category: "Health"),
        PresetHabit(name: "No Gaming", icon: "gamecontroller", category: "Focus"),
        PresetHabit(name: "No Energy Drinks", icon: "cup.and.saucer", category: "Health"),
        PresetHabit(name: "No Late Night Snacks", icon: "moon.zzz", category: "Health"),
        PresetHabit(name: "No Complaining", icon: "bubble.left.and.exclamationmark.bubble.right", category: "Mindset")
    ]

    // MARK: - Categories

    static var powerCategories: [String] {
        Array(Set(powers.map { $0.category })).sorted()
    }

    static var agentCategories: [String] {
        Array(Set(agents.map { $0.category })).sorted()
    }
}

