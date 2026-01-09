import Foundation

enum UserDefaultsKeys {
    // MARK: - Settings
    static let hapticsEnabled = "hapticsEnabled"
    static let soundEnabled = "soundEnabled"

    // MARK: - User Profile
    static let operatorName = "operatorName"
    static let operatorAge = "operatorAge"
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let totalXP = "totalXP"
    static let joinDate = "joinDate"

    // MARK: - Easter Eggs
    static let cheatKeys = "cheatKeys"
    static let whiteRabbitCaught = "whiteRabbitCaught"

    // MARK: - Sidequests
    static let oracleUsesToday = "sidequest_oracle_uses"
    static let codeBreakerUsesToday = "sidequest_codebreaker_uses"
    static let combatUsesToday = "sidequest_combat_uses"
    static let maintenanceUsesToday = "sidequest_maintenance_uses"
    static let sidequestXPToday = "sidequest_xp_today"
    static let sidequestLastResetDate = "sidequest_last_reset"

    // MARK: - Anomaly Reports
    static let anomalyProgress = "anomalyProgress_"
}
