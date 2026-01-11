import XCTest
@testable import MatrixHabit

final class RankSystemTests: XCTestCase {

    // MARK: - levelFromXP Tests

    func test_levelFromXP_withZeroXP_returnsLevelOne() {
        let level = RankSystem.levelFromXP(0)

        XCTAssertEqual(level, 1)
    }

    func test_levelFromXP_withNegativeXP_returnsLevelOne() {
        let level = RankSystem.levelFromXP(-100)

        XCTAssertEqual(level, 1)
    }

    func test_levelFromXP_justBelowLevelTwo_returnsLevelOne() {
        // Level 2 requires 60 XP (50 + 1*10)
        let level = RankSystem.levelFromXP(59)

        XCTAssertEqual(level, 1)
    }

    func test_levelFromXP_atLevelTwoThreshold_returnsLevelTwo() {
        // Level 2 requires 60 XP
        let level = RankSystem.levelFromXP(60)

        XCTAssertEqual(level, 2)
    }

    func test_levelFromXP_progressesThroughLevels() {
        // Test a few key level thresholds
        // Formula: each level requires 50 + (level * 10) more XP
        // Level 1: 0 XP
        // Level 2: 60 XP (50 + 10)
        // Level 3: 130 XP (60 + 70)
        // Level 4: 210 XP (130 + 80)

        XCTAssertEqual(RankSystem.levelFromXP(0), 1)
        XCTAssertEqual(RankSystem.levelFromXP(60), 2)
        XCTAssertEqual(RankSystem.levelFromXP(130), 3)
        XCTAssertEqual(RankSystem.levelFromXP(210), 4)
    }

    func test_levelFromXP_withHighXP_returnsHighLevel() {
        // Very high XP should still work
        let level = RankSystem.levelFromXP(10000)

        XCTAssertGreaterThan(level, 20)
    }

    // MARK: - rankFromLevel Tests

    func test_rankFromLevel_levelsOneToFive_returnsCopperTop() {
        XCTAssertEqual(RankSystem.rankFromLevel(1), .copperTop)
        XCTAssertEqual(RankSystem.rankFromLevel(3), .copperTop)
        XCTAssertEqual(RankSystem.rankFromLevel(5), .copperTop)
    }

    func test_rankFromLevel_levelsSixToTen_returnsNebuchadnezzarCrew() {
        XCTAssertEqual(RankSystem.rankFromLevel(6), .nebuchadnezzarCrew)
        XCTAssertEqual(RankSystem.rankFromLevel(8), .nebuchadnezzarCrew)
        XCTAssertEqual(RankSystem.rankFromLevel(10), .nebuchadnezzarCrew)
    }

    func test_rankFromLevel_levelsElevenToTwenty_returnsOperator() {
        XCTAssertEqual(RankSystem.rankFromLevel(11), .operator)
        XCTAssertEqual(RankSystem.rankFromLevel(15), .operator)
        XCTAssertEqual(RankSystem.rankFromLevel(20), .operator)
    }

    func test_rankFromLevel_levelsTwentyOneToFortyNine_returnsZionCaptain() {
        XCTAssertEqual(RankSystem.rankFromLevel(21), .zionCaptain)
        XCTAssertEqual(RankSystem.rankFromLevel(35), .zionCaptain)
        XCTAssertEqual(RankSystem.rankFromLevel(49), .zionCaptain)
    }

    func test_rankFromLevel_levelFiftyPlus_returnsTheOne() {
        XCTAssertEqual(RankSystem.rankFromLevel(50), .theOne)
        XCTAssertEqual(RankSystem.rankFromLevel(100), .theOne)
    }

    // MARK: - rankFromXP Tests

    func test_rankFromXP_combinesLevelAndRank() {
        // At 0 XP, should be Level 1, Rank Copper Top
        XCTAssertEqual(RankSystem.rankFromXP(0), .copperTop)

        // Test progression through ranks with XP
        // Level 6 (Nebuchadnezzar Crew) requires ~400 XP
        XCTAssertEqual(RankSystem.rankFromXP(500), .nebuchadnezzarCrew)

        // Very high XP should lead to The One (level 50+)
        // Level 50 requires approximately 75,000+ XP
        XCTAssertEqual(RankSystem.rankFromXP(100000), .theOne)
    }

    // MARK: - xpForNextLevel Tests

    func test_xpForNextLevel_atZeroXP_returnsXPNeededForLevelTwo() {
        let needed = RankSystem.xpForNextLevel(0)

        XCTAssertEqual(needed, 60, "Need 60 XP to reach level 2 from 0")
    }

    func test_xpForNextLevel_partialProgress_returnsRemaining() {
        // At 30 XP (halfway to level 2)
        let needed = RankSystem.xpForNextLevel(30)

        XCTAssertEqual(needed, 30, "Need 30 more XP to reach level 2")
    }

    func test_xpForNextLevel_atLevelBoundary_returnsNextLevelRequirement() {
        // At exactly 60 XP (level 2), need XP for level 3
        let needed = RankSystem.xpForNextLevel(60)

        XCTAssertEqual(needed, 70, "Need 70 XP for level 3 (130 - 60)")
    }

    // MARK: - progressToNextLevel Tests

    func test_progressToNextLevel_atZero_returnsZero() {
        let progress = RankSystem.progressToNextLevel(0)

        XCTAssertEqual(progress, 0.0, accuracy: 0.01)
    }

    func test_progressToNextLevel_halfwayToLevelTwo_returnsHalf() {
        // Level 2 is at 60 XP, so 30 XP is halfway
        let progress = RankSystem.progressToNextLevel(30)

        XCTAssertEqual(progress, 0.5, accuracy: 0.01)
    }

    func test_progressToNextLevel_justBelowNextLevel_returnsNearOne() {
        // 59 XP is almost level 2 (60 XP)
        let progress = RankSystem.progressToNextLevel(59)

        XCTAssertGreaterThan(progress, 0.9)
        XCTAssertLessThan(progress, 1.0)
    }

    // MARK: - Rank Properties Tests

    func test_rank_minLevel_matchesExpectedProgression() {
        XCTAssertEqual(Rank.copperTop.minLevel, 1)
        XCTAssertEqual(Rank.nebuchadnezzarCrew.minLevel, 6)
        XCTAssertEqual(Rank.operator.minLevel, 11)
        XCTAssertEqual(Rank.zionCaptain.minLevel, 21)
        XCTAssertEqual(Rank.theOne.minLevel, 50)
    }

    func test_rank_quote_isNotEmpty() {
        for rank in Rank.allCases {
            XCTAssertFalse(rank.quote.isEmpty, "\(rank) should have a quote")
        }
    }
}
