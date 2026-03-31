import Foundation
import SwiftData

// MARK: - Tier Promotion Manager
// Handles automatic tier progression based on user success streaks
// 14 days Easy → suggest Medium
// 28 days Medium → suggest Hard

struct PromotionCandidate: Identifiable {
    let id: UUID
    let agent: Agent
    let currentHabit: AgentHabit
    let nextHabit: AgentHabit
    let currentStreak: Int
    let currentTier: DifficultyTier
    let nextTier: DifficultyTier

    init(agent: Agent, currentHabit: AgentHabit, nextHabit: AgentHabit, currentStreak: Int, currentTier: DifficultyTier, nextTier: DifficultyTier) {
        self.id = agent.id
        self.agent = agent
        self.currentHabit = currentHabit
        self.nextHabit = nextHabit
        self.currentStreak = currentStreak
        self.currentTier = currentTier
        self.nextTier = nextTier
    }
}

class TierPromotionManager {

    // MARK: - Check for Promotions

    /// Returns agents eligible for tier promotion
    static func checkForPromotions(agents: [Agent]) -> [PromotionCandidate] {
        var candidates: [PromotionCandidate] = []

        for agent in agents {
            // Skip defeated agents
            guard !agent.isDefeated else { continue }

            // Match agent name to AgentHabit enum
            guard let agentHabit = AgentHabit.allCases.first(where: { $0.rawValue == agent.name }) else {
                continue
            }

            // Check if this agent has a family (skip legacy agents)
            guard agentHabit.family != nil else { continue }

            // Check if there's a next tier to promote to
            guard let nextHabit = agentHabit.nextTierAgent else { continue }

            // Check if streak meets promotion threshold
            let threshold = agentHabit.promotionThreshold
            guard threshold > 0 && agent.currentStreak >= threshold else { continue }

            // Create promotion candidate
            let candidate = PromotionCandidate(
                agent: agent,
                currentHabit: agentHabit,
                nextHabit: nextHabit,
                currentStreak: agent.currentStreak,
                currentTier: agentHabit.difficulty,
                nextTier: nextHabit.difficulty
            )
            candidates.append(candidate)
        }

        return candidates
    }

    // MARK: - Execute Promotion

    /// Promotes an agent to the next tier by creating a new agent
    /// Returns the new agent
    @discardableResult
    static func promoteAgent(
        candidate: PromotionCandidate,
        modelContext: ModelContext
    ) -> Agent {
        let oldAgent = candidate.agent
        let newHabit = candidate.nextHabit

        // Create new agent with next tier habit
        let newAgent = Agent(name: newHabit.rawValue, icon: newHabit.icon)

        // Transfer some progress context (keep streaks fresh for new challenge)
        // But preserve the creation momentum
        newAgent.createdAt = Date()

        // Insert new agent
        modelContext.insert(newAgent)

        // Mark old agent as defeated (graduated)
        oldAgent.isDefeated = true
        oldAgent.defeatedAt = Date()

        do {
            try modelContext.save()
        } catch {
            ErrorLogger.logSaveFailure(error, context: "TierPromotionManager.promoteAgent")
        }

        return newAgent
    }

    // MARK: - Decline Promotion

    /// User declines promotion - store preference to avoid repeated prompts
    /// We'll prompt again after another threshold period
    static func declinePromotion(for agent: Agent) {
        // Store declined date in UserDefaults
        let key = "promotion_declined_\(agent.id.uuidString)"
        UserDefaults.standard.set(Date(), forKey: key)
    }

    /// Check if promotion was recently declined (within last 7 days)
    static func wasPromotionRecentlyDeclined(for agent: Agent) -> Bool {
        let key = "promotion_declined_\(agent.id.uuidString)"
        guard let declinedDate = UserDefaults.standard.object(forKey: key) as? Date else {
            return false
        }

        let daysSinceDeclined = Calendar.current.dateComponents([.day], from: declinedDate, to: Date()).day ?? 0
        return daysSinceDeclined < 7  // Re-prompt after 7 days
    }

    // MARK: - Filter Candidates

    /// Filter out recently declined promotions
    static func filterDeclinedPromotions(_ candidates: [PromotionCandidate]) -> [PromotionCandidate] {
        candidates.filter { !wasPromotionRecentlyDeclined(for: $0.agent) }
    }

    // MARK: - Promotion Message

    /// Generate Matrix-themed promotion message
    static func promotionMessage(for candidate: PromotionCandidate) -> (title: String, message: String) {
        let tierName = candidate.nextTier.rawValue.uppercased()
        let daysCompleted = candidate.currentStreak

        let titles = [
            "SIGNAL UPGRADE DETECTED",
            "TRAINING COMPLETE",
            "LEVEL UP AVAILABLE",
            "NEW PROTOCOL READY"
        ]

        let messages: [String] = [
            "\(daysCompleted) days of resistance.\nYour signal is strong enough for \(tierName) tier.\n\nReady to increase the challenge?",
            "You've proven yourself at this level.\n\(tierName) tier awaits.\n\nThe Matrix won't know what hit it.",
            "\(daysCompleted) consecutive days.\nYou're ready for the next level.\n\nUpgrade to \(tierName) protocol?",
            "Your discipline has been noted.\n\(tierName) tier is now unlocked.\n\nAccept the challenge?"
        ]

        let randomIndex = Int.random(in: 0..<titles.count)
        return (titles[randomIndex], messages[randomIndex])
    }
}
