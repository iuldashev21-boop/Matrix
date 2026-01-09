import Foundation

enum SidequestManager {
    private static let defaults = UserDefaults.standard

    // MARK: - Keys

    private enum Keys {
        static let lastOracleDate = "sidequest_lastOracleDate"
        static let oracleUsesToday = "sidequest_oracleUsesToday"
        static let lastCodeBreakerDate = "sidequest_lastCodeBreakerDate"
        static let codeBreakerCompletedToday = "sidequest_codeBreakerCompletedToday"
        static let lastCombatDate = "sidequest_lastCombatDate"
        static let combatUsesToday = "sidequest_combatUsesToday"
        static let lastMaintenanceDate = "sidequest_lastMaintenanceDate"
        static let maintenanceUsesToday = "sidequest_maintenanceUsesToday"
        static let sidequestXPToday = "sidequest_xpToday"
        static let lastXPResetDate = "sidequest_lastXPResetDate"
    }

    // MARK: - Limits

    static let dailyXPCap: Int = 75
    static let oracleDailyLimit: Int = 5
    static let combatDailyLimit: Int = 3
    static let maintenanceDailyLimit: Int = 5

    // MARK: - XP Values

    static let oracleXP: Int = 5
    static let codeBreakerXP: Int = 50
    static let combatXP: Int = 15
    static let maintenanceXP: Int = 10

    // MARK: - Daily Reset Check

    private static func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastReset = defaults.object(forKey: Keys.lastXPResetDate) as? Date ?? .distantPast

        if Calendar.current.startOfDay(for: lastReset) < today {
            defaults.set(0, forKey: Keys.oracleUsesToday)
            defaults.set(false, forKey: Keys.codeBreakerCompletedToday)
            defaults.set(0, forKey: Keys.combatUsesToday)
            defaults.set(0, forKey: Keys.maintenanceUsesToday)
            defaults.set(0, forKey: Keys.sidequestXPToday)
            defaults.set(today, forKey: Keys.lastXPResetDate)
        }
    }

    // MARK: - XP Tracking

    static var sidequestXPToday: Int {
        resetIfNewDay()
        return defaults.integer(forKey: Keys.sidequestXPToday)
    }

    static var canEarnMoreXP: Bool {
        sidequestXPToday < dailyXPCap
    }

    static var remainingXP: Int {
        max(0, dailyXPCap - sidequestXPToday)
    }

    private static func addSidequestXP(_ amount: Int) {
        resetIfNewDay()
        let cappedAmount = min(amount, remainingXP)
        if cappedAmount > 0 {
            defaults.set(sidequestXPToday + cappedAmount, forKey: Keys.sidequestXPToday)
            UserProfile.addXP(cappedAmount)
        }
    }

    // MARK: - Oracle's Insight

    static var oracleUsesToday: Int {
        resetIfNewDay()
        return defaults.integer(forKey: Keys.oracleUsesToday)
    }

    static var canUseOracle: Bool {
        oracleUsesToday < oracleDailyLimit && canEarnMoreXP
    }

    static var oracleRemainingUses: Int {
        max(0, oracleDailyLimit - oracleUsesToday)
    }

    static func useOracle() -> Int {
        guard canUseOracle else { return 0 }
        resetIfNewDay()
        defaults.set(oracleUsesToday + 1, forKey: Keys.oracleUsesToday)
        let xpEarned = min(oracleXP, remainingXP)
        addSidequestXP(xpEarned)
        return xpEarned
    }

    // MARK: - Code Breaker

    static var codeBreakerCompletedToday: Bool {
        resetIfNewDay()
        return defaults.bool(forKey: Keys.codeBreakerCompletedToday)
    }

    static var canPlayCodeBreaker: Bool {
        !codeBreakerCompletedToday && canEarnMoreXP
    }

    static func completeCodeBreaker(won: Bool) -> Int {
        guard canPlayCodeBreaker else { return 0 }
        resetIfNewDay()
        defaults.set(true, forKey: Keys.codeBreakerCompletedToday)

        if won {
            let xpEarned = min(codeBreakerXP, remainingXP)
            addSidequestXP(xpEarned)
            return xpEarned
        }
        return 0
    }

    // MARK: - Combat Training

    static var combatUsesToday: Int {
        resetIfNewDay()
        return defaults.integer(forKey: Keys.combatUsesToday)
    }

    static var canDoCombatTraining: Bool {
        combatUsesToday < combatDailyLimit && canEarnMoreXP
    }

    static var combatRemainingUses: Int {
        max(0, combatDailyLimit - combatUsesToday)
    }

    static func completeCombatTraining() -> Int {
        guard canDoCombatTraining else { return 0 }
        resetIfNewDay()
        defaults.set(combatUsesToday + 1, forKey: Keys.combatUsesToday)
        let xpEarned = min(combatXP, remainingXP)
        addSidequestXP(xpEarned)
        return xpEarned
    }

    // MARK: - System Maintenance

    static var maintenanceUsesToday: Int {
        resetIfNewDay()
        return defaults.integer(forKey: Keys.maintenanceUsesToday)
    }

    static var canDoMaintenance: Bool {
        maintenanceUsesToday < maintenanceDailyLimit && canEarnMoreXP
    }

    static var maintenanceRemainingUses: Int {
        max(0, maintenanceDailyLimit - maintenanceUsesToday)
    }

    static func completeMaintenance() -> Int {
        guard canDoMaintenance else { return 0 }
        resetIfNewDay()
        defaults.set(maintenanceUsesToday + 1, forKey: Keys.maintenanceUsesToday)
        let xpEarned = min(maintenanceXP, remainingXP)
        addSidequestXP(xpEarned)
        return xpEarned
    }

    // MARK: - Full Reset

    static func reset() {
        defaults.removeObject(forKey: Keys.lastOracleDate)
        defaults.removeObject(forKey: Keys.oracleUsesToday)
        defaults.removeObject(forKey: Keys.lastCodeBreakerDate)
        defaults.removeObject(forKey: Keys.codeBreakerCompletedToday)
        defaults.removeObject(forKey: Keys.lastCombatDate)
        defaults.removeObject(forKey: Keys.combatUsesToday)
        defaults.removeObject(forKey: Keys.lastMaintenanceDate)
        defaults.removeObject(forKey: Keys.maintenanceUsesToday)
        defaults.removeObject(forKey: Keys.sidequestXPToday)
        defaults.removeObject(forKey: Keys.lastXPResetDate)
    }
}

