import Foundation

enum UserProfile {
    private static let defaults = UserDefaults.standard

    // MARK: - Keys

    private enum Keys {
        static let operativeName = "operativeName"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let firstLaunchDate = "firstLaunchDate"
        static let totalXP = "totalXP"
        static let empTokens = "empTokens"
    }

    // MARK: - Properties

    static var operativeName: String? {
        get { defaults.string(forKey: Keys.operativeName) }
        set { defaults.set(newValue, forKey: Keys.operativeName) }
    }

    static var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    static var firstLaunchDate: Date? {
        get { defaults.object(forKey: Keys.firstLaunchDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.firstLaunchDate) }
    }

    static var totalXP: Int {
        get { defaults.integer(forKey: Keys.totalXP) }
        set { defaults.set(newValue, forKey: Keys.totalXP) }
    }

    static var empTokens: Int {
        get { defaults.integer(forKey: Keys.empTokens) }
        set { defaults.set(newValue, forKey: Keys.empTokens) }
    }

    // MARK: - Computed Properties

    static var currentLevel: Int {
        RankSystem.levelFromXP(totalXP)
    }

    static var currentRank: Rank {
        RankSystem.rankFromXP(totalXP)
    }

    static var daysSinceJoined: Int {
        guard let firstLaunch = firstLaunchDate else { return 0 }
        return DateHelpers.daysBetween(firstLaunch, Date())
    }

    static var displayName: String {
        operativeName ?? "Operative"
    }

    // MARK: - Methods

    static func recordFirstLaunchIfNeeded() {
        if firstLaunchDate == nil {
            firstLaunchDate = Date()
        }
    }

    static func completeOnboarding() {
        hasCompletedOnboarding = true
        recordFirstLaunchIfNeeded()
    }

    static func reset() {
        operativeName = nil
        hasCompletedOnboarding = false
        firstLaunchDate = nil
        totalXP = 0
        empTokens = 0
    }

    static func addXP(_ amount: Int) {
        totalXP += amount
    }

    // MARK: - EMP Token Methods

    /// Award EMP tokens (earned at streak milestones)
    static func awardEMPTokens(_ amount: Int) {
        empTokens += amount
    }

    /// Spend EMP tokens for streak recovery
    /// Returns true if successful, false if insufficient tokens
    static func spendEMPToken() -> Bool {
        guard empTokens > 0 else { return false }
        empTokens -= 1
        return true
    }

    /// Check if user has at least one EMP token
    static var hasEMPTokens: Bool {
        empTokens > 0
    }

    /// EMP tokens earned at different milestones
    static func empTokensForMilestone(_ milestone: Int) -> Int {
        switch milestone {
        case 7: return 1    // First week
        case 21: return 2   // Habit forming
        case 66: return 5   // Protocol complete
        default: return 0
        }
    }
}

