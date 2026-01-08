import Foundation

enum UserProfile {
    private static let defaults = UserDefaults.standard

    // MARK: - Keys

    private enum Keys {
        static let operativeName = "operativeName"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let firstLaunchDate = "firstLaunchDate"
        static let totalXP = "totalXP"
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
    }

    static func addXP(_ amount: Int) {
        totalXP += amount
    }
}
