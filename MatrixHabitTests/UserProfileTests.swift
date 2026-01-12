import XCTest
@testable import MatrixHabit

final class UserProfileTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset UserProfile state before each test
        UserProfile.reset()
    }

    override func tearDown() {
        // Clean up after tests
        UserProfile.reset()
        super.tearDown()
    }

    // MARK: - Operative Name Tests

    func test_operativeName_defaultIsNil() {
        XCTAssertNil(UserProfile.operativeName)
    }

    func test_operativeName_canBeSet() {
        UserProfile.operativeName = "Neo"

        XCTAssertEqual(UserProfile.operativeName, "Neo")
    }

    func test_displayName_withoutName_returnsOperative() {
        XCTAssertEqual(UserProfile.displayName, "Operative")
    }

    func test_displayName_withName_returnsName() {
        UserProfile.operativeName = "Trinity"

        XCTAssertEqual(UserProfile.displayName, "Trinity")
    }

    // MARK: - Onboarding Tests

    func test_hasCompletedOnboarding_defaultIsFalse() {
        XCTAssertFalse(UserProfile.hasCompletedOnboarding)
    }

    func test_completeOnboarding_setsFlag() {
        UserProfile.completeOnboarding()

        XCTAssertTrue(UserProfile.hasCompletedOnboarding)
    }

    func test_completeOnboarding_recordsFirstLaunch() {
        UserProfile.completeOnboarding()

        XCTAssertNotNil(UserProfile.firstLaunchDate)
    }

    // MARK: - First Launch Date Tests

    func test_firstLaunchDate_defaultIsNil() {
        XCTAssertNil(UserProfile.firstLaunchDate)
    }

    func test_recordFirstLaunchIfNeeded_setsDate() {
        UserProfile.recordFirstLaunchIfNeeded()

        XCTAssertNotNil(UserProfile.firstLaunchDate)
    }

    func test_recordFirstLaunchIfNeeded_doesNotOverwrite() {
        UserProfile.recordFirstLaunchIfNeeded()
        let firstDate = UserProfile.firstLaunchDate

        Thread.sleep(forTimeInterval: 0.01)
        UserProfile.recordFirstLaunchIfNeeded()

        XCTAssertEqual(UserProfile.firstLaunchDate, firstDate)
    }

    func test_daysSinceJoined_withNoFirstLaunch_returnsZero() {
        XCTAssertEqual(UserProfile.daysSinceJoined, 0)
    }

    func test_daysSinceJoined_withTodayLaunch_returnsZero() {
        UserProfile.recordFirstLaunchIfNeeded()

        XCTAssertEqual(UserProfile.daysSinceJoined, 0)
    }

    // MARK: - XP Tests

    func test_totalXP_defaultIsZero() {
        XCTAssertEqual(UserProfile.totalXP, 0)
    }

    func test_addXP_increasesTotal() {
        UserProfile.addXP(100)

        XCTAssertEqual(UserProfile.totalXP, 100)
    }

    func test_addXP_accumulates() {
        UserProfile.addXP(50)
        UserProfile.addXP(75)
        UserProfile.addXP(25)

        XCTAssertEqual(UserProfile.totalXP, 150)
    }

    func test_currentLevel_atZeroXP_returnsOne() {
        XCTAssertEqual(UserProfile.currentLevel, 1)
    }

    func test_currentLevel_increasesWithXP() {
        UserProfile.addXP(500) // Should be enough for level 2+

        XCTAssertGreaterThan(UserProfile.currentLevel, 1)
    }

    func test_currentRank_atStart_isCoppertop() {
        let rank = UserProfile.currentRank

        XCTAssertEqual(rank, .copperTop)
    }

    // MARK: - EMP Token Tests

    func test_empTokens_defaultIsZero() {
        XCTAssertEqual(UserProfile.empTokens, 0)
    }

    func test_hasEMPTokens_withZero_returnsFalse() {
        XCTAssertFalse(UserProfile.hasEMPTokens)
    }

    func test_hasEMPTokens_withTokens_returnsTrue() {
        UserProfile.awardEMPTokens(1)

        XCTAssertTrue(UserProfile.hasEMPTokens)
    }

    func test_awardEMPTokens_increasesCount() {
        UserProfile.awardEMPTokens(3)

        XCTAssertEqual(UserProfile.empTokens, 3)
    }

    func test_awardEMPTokens_accumulates() {
        UserProfile.awardEMPTokens(2)
        UserProfile.awardEMPTokens(3)

        XCTAssertEqual(UserProfile.empTokens, 5)
    }

    func test_spendEMPToken_withTokens_returnsTrue() {
        UserProfile.awardEMPTokens(1)

        let result = UserProfile.spendEMPToken()

        XCTAssertTrue(result)
        XCTAssertEqual(UserProfile.empTokens, 0)
    }

    func test_spendEMPToken_withNoTokens_returnsFalse() {
        let result = UserProfile.spendEMPToken()

        XCTAssertFalse(result)
        XCTAssertEqual(UserProfile.empTokens, 0)
    }

    func test_spendEMPToken_decrementsCount() {
        UserProfile.awardEMPTokens(5)

        _ = UserProfile.spendEMPToken()
        _ = UserProfile.spendEMPToken()

        XCTAssertEqual(UserProfile.empTokens, 3)
    }

    func test_spendEMPToken_cannotGoNegative() {
        UserProfile.awardEMPTokens(1)

        _ = UserProfile.spendEMPToken()
        let result = UserProfile.spendEMPToken()

        XCTAssertFalse(result)
        XCTAssertEqual(UserProfile.empTokens, 0)
    }

    // MARK: - EMP Milestone Tests

    func test_empTokensForMilestone_day7_returnsOne() {
        let tokens = UserProfile.empTokensForMilestone(7)

        XCTAssertEqual(tokens, 1)
    }

    func test_empTokensForMilestone_day21_returnsTwo() {
        let tokens = UserProfile.empTokensForMilestone(21)

        XCTAssertEqual(tokens, 2)
    }

    func test_empTokensForMilestone_day66_returnsFive() {
        let tokens = UserProfile.empTokensForMilestone(66)

        XCTAssertEqual(tokens, 5)
    }

    func test_empTokensForMilestone_nonMilestone_returnsZero() {
        XCTAssertEqual(UserProfile.empTokensForMilestone(1), 0)
        XCTAssertEqual(UserProfile.empTokensForMilestone(10), 0)
        XCTAssertEqual(UserProfile.empTokensForMilestone(50), 0)
        XCTAssertEqual(UserProfile.empTokensForMilestone(100), 0)
    }

    // MARK: - Reset Tests

    func test_reset_clearsAllData() {
        UserProfile.operativeName = "Neo"
        UserProfile.completeOnboarding()
        UserProfile.addXP(1000)
        UserProfile.awardEMPTokens(10)

        UserProfile.reset()

        XCTAssertNil(UserProfile.operativeName)
        XCTAssertFalse(UserProfile.hasCompletedOnboarding)
        XCTAssertNil(UserProfile.firstLaunchDate)
        XCTAssertEqual(UserProfile.totalXP, 0)
        XCTAssertEqual(UserProfile.empTokens, 0)
    }
}
