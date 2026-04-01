import XCTest
@testable import MatrixHabit

final class TierPromotionTests: XCTestCase {

    // MARK: - checkForPromotions Tests

    func test_checkForPromotions_easyAgentAboveThreshold_returnsCandidate() {
        // "No Vaping Indoors" is an Easy tier agent in the Vaping family
        let agent = Agent(name: "No Vaping Indoors")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 14, startingDaysAgo: 0)

        let candidates = TierPromotionManager.checkForPromotions(agents: [agent])

        XCTAssertEqual(candidates.count, 1)
        XCTAssertEqual(candidates.first?.currentTier, .easy)
        XCTAssertEqual(candidates.first?.nextTier, .medium)
    }

    func test_checkForPromotions_agentBelowThreshold_returnsEmpty() {
        let agent = Agent(name: "No Vaping Indoors")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 5, startingDaysAgo: 0)

        let candidates = TierPromotionManager.checkForPromotions(agents: [agent])

        XCTAssertTrue(candidates.isEmpty, "Agent below threshold should not be a candidate")
    }

    func test_checkForPromotions_defeatedAgent_returnsEmpty() {
        let agent = Agent(name: "No Vaping Indoors")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 14, startingDaysAgo: 0)
        agent.isDefeated = true

        let candidates = TierPromotionManager.checkForPromotions(agents: [agent])

        XCTAssertTrue(candidates.isEmpty, "Defeated agent should not be a candidate")
    }

    func test_checkForPromotions_legacyAgent_returnsEmpty() {
        // "No Brain Rot" is a legacy agent with no family
        let agent = Agent(name: "No Brain Rot")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 30, startingDaysAgo: 0)

        let candidates = TierPromotionManager.checkForPromotions(agents: [agent])

        XCTAssertTrue(candidates.isEmpty, "Legacy agent with no family should not be a candidate")
    }

    func test_checkForPromotions_hardTierAgent_returnsEmpty() {
        // "No Vaping" is Hard tier — no promotion available
        let agent = Agent(name: "No Vaping")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 30, startingDaysAgo: 0)

        let candidates = TierPromotionManager.checkForPromotions(agents: [agent])

        XCTAssertTrue(candidates.isEmpty, "Hard tier agent should not be a candidate")
    }

    func test_checkForPromotions_mediumAgentAboveThreshold_returnsCandidate() {
        // "No Vaping Before Noon" is Medium tier in Vaping family
        let agent = Agent(name: "No Vaping Before Noon")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 28, startingDaysAgo: 0)

        let candidates = TierPromotionManager.checkForPromotions(agents: [agent])

        XCTAssertEqual(candidates.count, 1)
        XCTAssertEqual(candidates.first?.currentTier, .medium)
        XCTAssertEqual(candidates.first?.nextTier, .hard)
    }

    // MARK: - promotionMessage Tests

    func test_promotionMessage_returnsNonEmptyStrings() {
        let agent = Agent(name: "No Vaping Indoors")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 14, startingDaysAgo: 0)

        let candidates = TierPromotionManager.checkForPromotions(agents: [agent])
        guard let candidate = candidates.first else {
            XCTFail("Expected a promotion candidate")
            return
        }

        let message = TierPromotionManager.promotionMessage(for: candidate)

        XCTAssertFalse(message.title.isEmpty)
        XCTAssertFalse(message.message.isEmpty)
    }
}
