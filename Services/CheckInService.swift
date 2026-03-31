import Foundation
import SwiftData
import SwiftUI
import WidgetKit

/// Centralized service for creating and managing check-ins
/// Consolidates check-in logic, XP rewards, and error handling
enum CheckInService {

    // MARK: - Check-In Creation

    /// Records a successful check-in for a Power
    /// - Returns: XP earned (includes milestone bonuses)
    @discardableResult
    static func recordPowerCheckIn(
        power: Power,
        date: Date = Date(),
        note: String? = nil,
        context: ModelContext
    ) -> Result<Int, CheckInError> {
        // Prevent duplicate check-ins
        let checkDate = Calendar.current.startOfDay(for: date)
        let alreadyExists = power.checkIns.contains {
            Calendar.current.startOfDay(for: $0.date) == checkDate
        }
        guard !alreadyExists else {
            return .failure(.duplicateCheckIn)
        }

        let checkIn = CheckIn(date: date, isSuccess: true, note: note)
        checkIn.power = power
        power.checkIns.append(checkIn)
        context.insert(checkIn)

        // Calculate XP before save (streak will update)
        let newStreak = power.currentStreak
        let xpEarned = calculateXP(streak: newStreak)

        do {
            try context.save()
            let wasUnlocked = power.checkForUnlock()

            // Award XP
            UserProfile.addXP(xpEarned)

            // Award EMP tokens at milestones
            let empTokens = UserProfile.empTokensForMilestone(newStreak)
            if empTokens > 0 {
                UserProfile.awardEMPTokens(empTokens)
            }

            // Play appropriate sound
            DispatchQueue.main.async {
                if wasUnlocked {
                    SoundManager.shared.playProtocolComplete()
                } else if [7, 21, 66].contains(newStreak) {
                    SoundManager.shared.playMilestone()
                    if empTokens > 0 {
                        // Slight delay for EMP sound after milestone
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            SoundManager.shared.playEMPToken()
                        }
                    }
                } else {
                    SoundManager.shared.playCheckIn()
                }
            }

            WidgetCenter.shared.reloadAllTimelines()
            return .success(xpEarned)
        } catch {
            // Roll back in-memory state to match store
            power.checkIns.removeAll { $0 === checkIn }
            context.delete(checkIn)
            ErrorLogger.logSaveFailure(error, context: "CheckInService.recordPowerCheckIn")
            return .failure(.saveFailed(error))
        }
    }

    /// Records a successful resistance for an Agent
    /// - Returns: XP earned (includes milestone bonuses)
    @discardableResult
    static func recordAgentResistance(
        agent: Agent,
        date: Date = Date(),
        note: String? = nil,
        context: ModelContext
    ) -> Result<Int, CheckInError> {
        // Prevent duplicate check-ins
        let checkDate = Calendar.current.startOfDay(for: date)
        let alreadyExists = agent.checkIns.contains {
            Calendar.current.startOfDay(for: $0.date) == checkDate
        }
        guard !alreadyExists else {
            return .failure(.duplicateCheckIn)
        }

        let checkIn = CheckIn(date: date, isSuccess: true, note: note)
        checkIn.agent = agent
        agent.checkIns.append(checkIn)
        context.insert(checkIn)

        let newStreak = agent.currentStreak
        let xpEarned = calculateXP(streak: newStreak)

        do {
            try context.save()
            let wasDefeated = agent.checkForDefeat()

            UserProfile.addXP(xpEarned)

            let empTokens = UserProfile.empTokensForMilestone(newStreak)
            if empTokens > 0 {
                UserProfile.awardEMPTokens(empTokens)
            }

            // Play appropriate sound
            DispatchQueue.main.async {
                if wasDefeated {
                    SoundManager.shared.playProtocolComplete()
                } else if [7, 21, 66].contains(newStreak) {
                    SoundManager.shared.playMilestone()
                    if empTokens > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            SoundManager.shared.playEMPToken()
                        }
                    }
                } else {
                    SoundManager.shared.playCheckIn()
                }
            }

            WidgetCenter.shared.reloadAllTimelines()
            return .success(xpEarned)
        } catch {
            // Roll back in-memory state to match store
            agent.checkIns.removeAll { $0 === checkIn }
            context.delete(checkIn)
            ErrorLogger.logSaveFailure(error, context: "CheckInService.recordAgentResistance")
            return .failure(.saveFailed(error))
        }
    }

    /// Records a relapse for an Agent
    @discardableResult
    static func recordAgentRelapse(
        agent: Agent,
        date: Date = Date(),
        note: String? = nil,
        context: ModelContext
    ) -> Result<Void, CheckInError> {
        let checkIn = CheckIn(date: date, isSuccess: false, note: note)
        checkIn.agent = agent
        agent.checkIns.append(checkIn)
        context.insert(checkIn)

        do {
            try context.save()

            // Play relapse sound
            DispatchQueue.main.async {
                SoundManager.shared.playRelapse()
            }

            return .success(())
        } catch {
            // Roll back in-memory state to match store
            agent.checkIns.removeAll { $0 === checkIn }
            context.delete(checkIn)
            ErrorLogger.logSaveFailure(error, context: "CheckInService.recordAgentRelapse")
            return .failure(.saveFailed(error))
        }
    }

    // MARK: - Bulk Operations

    /// Submit all incomplete habits at once
    /// - Returns: Total XP earned
    static func submitAllHabits(
        powers: [Power],
        agents: [Agent],
        context: ModelContext
    ) -> Result<Int, CheckInError> {
        var totalXP = 0

        // Filter to incomplete only
        let incompletePowers = powers.filter { !$0.completedToday && $0.isScheduledToday }
        let incompleteAgents = agents.filter { !$0.resistedToday && !$0.relapsedToday && $0.isScheduledToday }

        // Record all check-ins
        for power in incompletePowers {
            let checkIn = CheckIn(date: Date(), isSuccess: true)
            checkIn.power = power
            power.checkIns.append(checkIn)
            context.insert(checkIn)

            let newStreak = power.currentStreak
            totalXP += calculateXP(streak: newStreak)
        }

        for agent in incompleteAgents {
            let checkIn = CheckIn(date: Date(), isSuccess: true)
            checkIn.agent = agent
            agent.checkIns.append(checkIn)
            context.insert(checkIn)

            let newStreak = agent.currentStreak
            totalXP += calculateXP(streak: newStreak)
        }

        do {
            try context.save()

            // Post-save: check unlocks/defeats and award XP
            var hadProtocolComplete = false
            var hadMilestone = false

            for power in incompletePowers {
                if power.checkForUnlock() { hadProtocolComplete = true }
                let streak = power.currentStreak
                if [7, 21, 66].contains(streak) { hadMilestone = true }
                let empTokens = UserProfile.empTokensForMilestone(streak)
                if empTokens > 0 { UserProfile.awardEMPTokens(empTokens) }
            }
            for agent in incompleteAgents {
                if agent.checkForDefeat() { hadProtocolComplete = true }
                let streak = agent.currentStreak
                if [7, 21, 66].contains(streak) { hadMilestone = true }
                let empTokens = UserProfile.empTokensForMilestone(streak)
                if empTokens > 0 { UserProfile.awardEMPTokens(empTokens) }
            }

            UserProfile.addXP(totalXP)

            // Play appropriate sound for bulk submission
            DispatchQueue.main.async {
                if hadProtocolComplete {
                    SoundManager.shared.playProtocolComplete()
                } else if hadMilestone {
                    SoundManager.shared.playMilestone()
                } else if !incompletePowers.isEmpty || !incompleteAgents.isEmpty {
                    SoundManager.shared.playCheckIn()
                }
            }

            WidgetCenter.shared.reloadAllTimelines()
            return .success(totalXP)
        } catch {
            ErrorLogger.logSaveFailure(error, context: "CheckInService.submitAllHabits")
            return .failure(.saveFailed(error))
        }
    }

    // MARK: - EMP Recovery

    /// Use an EMP token to recover a missed day
    static func recoverWithEMP(
        power: Power? = nil,
        agent: Agent? = nil,
        context: ModelContext
    ) -> Result<Void, CheckInError> {
        // Validate at least one target exists before spending the token
        guard power != nil || agent != nil else {
            return .failure(.saveFailed(NSError(domain: "CheckInService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No habit target provided"])))
        }

        guard UserProfile.spendEMPToken() else {
            return .failure(.insufficientEMPTokens)
        }

        let yesterday = DateHelper.yesterday

        if let power = power {
            let checkIn = CheckIn(date: yesterday, isSuccess: true, note: "Recovered with EMP")
            checkIn.power = power
            power.checkIns.append(checkIn)
            context.insert(checkIn)
        }

        if let agent = agent {
            let checkIn = CheckIn(date: yesterday, isSuccess: true, note: "Recovered with EMP")
            checkIn.agent = agent
            agent.checkIns.append(checkIn)
            context.insert(checkIn)
        }

        do {
            try context.save()

            // Play EMP sound for recovery
            DispatchQueue.main.async {
                SoundManager.shared.playEMPToken()
            }

            WidgetCenter.shared.reloadAllTimelines()
            return .success(())
        } catch {
            // Refund the token on failure
            UserProfile.awardEMPTokens(1)
            ErrorLogger.logSaveFailure(error, context: "CheckInService.recoverWithEMP")
            return .failure(.saveFailed(error))
        }
    }

    // MARK: - XP Calculation

    private static func calculateXP(streak: Int) -> Int {
        var xp = 10 // Base XP per check-in

        // Milestone bonuses
        switch streak {
        case 7, 21, 66:
            xp += 50
        default:
            break
        }

        return xp
    }
}

// MARK: - Error Types

enum CheckInError: Error, LocalizedError {
    case duplicateCheckIn
    case saveFailed(Error)
    case insufficientEMPTokens

    var errorDescription: String? {
        switch self {
        case .duplicateCheckIn:
            return "Already checked in for this day"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .insufficientEMPTokens:
            return "No EMP tokens available"
        }
    }

    var userMessage: String {
        switch self {
        case .duplicateCheckIn:
            return "SIGNAL ALREADY LOGGED"
        case .saveFailed:
            return "TRANSMISSION FAILED"
        case .insufficientEMPTokens:
            return "NO EMP TOKENS"
        }
    }
}
