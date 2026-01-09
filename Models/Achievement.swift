import Foundation
import SwiftData

@Model
final class Achievement {
    @Attribute(.unique) var id: String
    var unlockedAt: Date

    init(id: String, unlockedAt: Date = Date()) {
        self.id = id
        self.unlockedAt = unlockedAt
    }
}

// MARK: - Achievement Definitions

enum AchievementRarity: String {
    case common = "COMMON"
    case rare = "RARE"
    case epic = "EPIC"
    case legendary = "LEGENDARY"

    var xpReward: Int {
        switch self {
        case .common: return 10
        case .rare: return 25
        case .epic: return 50
        case .legendary: return 100
        }
    }
}

struct AchievementDefinition: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let rarity: AchievementRarity
    let category: AchievementCategory

    enum AchievementCategory: String {
        case streak = "STREAK"
        case consistency = "CONSISTENCY"
        case special = "SPECIAL"
        case milestone = "MILESTONE"
    }
}

// MARK: - All Achievements

struct AchievementLibrary {

    // MARK: - Streak Achievements (per habit type)
    static let streakAchievements: [AchievementDefinition] = [
        // Day 1
        AchievementDefinition(
            id: "streak_1",
            name: "Hello World",
            description: "Complete your first day of any habit.",
            icon: "terminal",
            rarity: .common,
            category: .streak
        ),
        // Day 3
        AchievementDefinition(
            id: "streak_3",
            name: "Glitch in the Matrix",
            description: "Maintain a 3-day streak on any habit.",
            icon: "waveform.path",
            rarity: .common,
            category: .streak
        ),
        // Day 7
        AchievementDefinition(
            id: "streak_7",
            name: "The Red Pill",
            description: "Maintain a 7-day streak. You're seeing the truth now.",
            icon: "pills.fill",
            rarity: .rare,
            category: .streak
        ),
        // Day 14
        AchievementDefinition(
            id: "streak_14",
            name: "Training Program",
            description: "Maintain a 14-day streak. Your training is complete.",
            icon: "figure.martial.arts",
            rarity: .rare,
            category: .streak
        ),
        // Day 21
        AchievementDefinition(
            id: "streak_21",
            name: "I Know Kung Fu",
            description: "Maintain a 21-day streak. The habit is forming.",
            icon: "brain.head.profile",
            rarity: .epic,
            category: .streak
        ),
        // Day 30
        AchievementDefinition(
            id: "streak_30",
            name: "There Is No Spoon",
            description: "Maintain a 30-day streak. Reality bends to your will.",
            icon: "wand.and.stars",
            rarity: .epic,
            category: .streak
        ),
        // Day 66
        AchievementDefinition(
            id: "streak_66",
            name: "The Source",
            description: "Reach 66 days. You've rewritten your code.",
            icon: "cpu",
            rarity: .legendary,
            category: .streak
        ),
    ]

    // MARK: - Consistency Achievements
    static let consistencyAchievements: [AchievementDefinition] = [
        AchievementDefinition(
            id: "log_first",
            name: "First Signal",
            description: "Log your first habit check-in.",
            icon: "antenna.radiowaves.left.and.right",
            rarity: .common,
            category: .consistency
        ),
        AchievementDefinition(
            id: "log_3_day",
            name: "Trinity's Help",
            description: "Log 3 habits in a single day.",
            icon: "person.3.fill",
            rarity: .common,
            category: .consistency
        ),
        AchievementDefinition(
            id: "log_all_day",
            name: "System Override",
            description: "Complete ALL your habits in a single day.",
            icon: "checkmark.shield.fill",
            rarity: .rare,
            category: .consistency
        ),
        AchievementDefinition(
            id: "perfect_week",
            name: "Bullet Time",
            description: "Perfect week - all habits, all 7 days.",
            icon: "clock.badge.checkmark",
            rarity: .epic,
            category: .consistency
        ),
        AchievementDefinition(
            id: "early_bird",
            name: "Morning Simulation",
            description: "Check in before 8 AM.",
            icon: "sunrise.fill",
            rarity: .common,
            category: .consistency
        ),
        AchievementDefinition(
            id: "night_owl",
            name: "Night Crew",
            description: "Check in after 10 PM.",
            icon: "moon.stars.fill",
            rarity: .common,
            category: .consistency
        ),
        AchievementDefinition(
            id: "weekend_warrior",
            name: "No Days Off",
            description: "Log habits on both Saturday and Sunday.",
            icon: "calendar.badge.clock",
            rarity: .rare,
            category: .consistency
        ),
    ]

    // MARK: - Special Achievements
    static let specialAchievements: [AchievementDefinition] = [
        AchievementDefinition(
            id: "comeback",
            name: "Resurrection",
            description: "Return after missing days and start a new streak.",
            icon: "arrow.counterclockwise",
            rarity: .epic,
            category: .special
        ),
        AchievementDefinition(
            id: "agent_resisted_5",
            name: "Agent Smith Defeated",
            description: "Resist an Agent (bad habit) for 5 consecutive days.",
            icon: "xmark.shield.fill",
            rarity: .rare,
            category: .special
        ),
        AchievementDefinition(
            id: "first_hack",
            name: "First Upload",
            description: "Add your first custom Hack.",
            icon: "arrow.up.doc.fill",
            rarity: .common,
            category: .special
        ),
        AchievementDefinition(
            id: "first_agent",
            name: "Know Your Enemy",
            description: "Add your first custom Agent to track.",
            icon: "exclamationmark.triangle.fill",
            rarity: .common,
            category: .special
        ),
        AchievementDefinition(
            id: "delete_habit",
            name: "Garbage Collection",
            description: "Delete a habit from your loadout.",
            icon: "trash.fill",
            rarity: .common,
            category: .special
        ),
        AchievementDefinition(
            id: "white_rabbit",
            name: "Follow the White Rabbit",
            description: "Catch the White Rabbit.",
            icon: "hare.fill",
            rarity: .rare,
            category: .special
        ),
        AchievementDefinition(
            id: "total_checkins_50",
            name: "Operator Status",
            description: "Reach 50 total check-ins.",
            icon: "star.fill",
            rarity: .rare,
            category: .milestone
        ),
        AchievementDefinition(
            id: "total_checkins_100",
            name: "Zion Resident",
            description: "Reach 100 total check-ins.",
            icon: "building.2.fill",
            rarity: .epic,
            category: .milestone
        ),
        AchievementDefinition(
            id: "total_checkins_365",
            name: "The One",
            description: "Reach 365 total check-ins. You are The One.",
            icon: "figure.stand",
            rarity: .legendary,
            category: .milestone
        ),
    ]

    // MARK: - All Achievements
    static var all: [AchievementDefinition] {
        streakAchievements + consistencyAchievements + specialAchievements
    }

    static func definition(for id: String) -> AchievementDefinition? {
        all.first { $0.id == id }
    }
}

