import StoreKit
import SwiftUI

/// Manages App Store review prompts with engagement gating and sentiment pre-screening
final class ReviewManager {
    static let shared = ReviewManager()

    private init() {}

    // MARK: - Review Decision

    enum Decision {
        case showPreScreen
        case skip
    }

    // MARK: - UserDefaults Keys

    private let lastReviewRequestDateKey = "lastReviewRequestDate"
    private let reviewRequestCountKey = "reviewRequestCount"
    private let firstPromptDateKey = "review_firstPromptDate"
    private let totalCheckInCountKey = "review_totalCheckInCount"
    private let distinctDayCountKey = "review_distinctDayCount"
    private let lastCheckInDateKey = "review_lastCheckInDate"
    private let lastStreakBreakKey = "review_lastStreakBreakDate"

    // MARK: - Configuration

    private let minimumDaysBetweenPrompts = 45
    private let maxRequestsPerYear = 3
    private let reviewTriggerStreaks = [7, 14, 21, 66]
    private let minimumHabits = 1
    private let minimumCheckIns = 1
    private let minimumDistinctDays = 1
    private let streakBreakCooldownHours = 48

    // MARK: - Engagement Tracking

    /// Call on every successful check-in to track engagement metrics
    func trackCheckIn() {
        let defaults = UserDefaults.standard

        // Increment total check-in count
        let count = defaults.integer(forKey: totalCheckInCountKey)
        defaults.set(count + 1, forKey: totalCheckInCountKey)

        // Track distinct calendar days
        let today = Calendar.current.startOfDay(for: Date())
        if let lastDate = defaults.object(forKey: lastCheckInDateKey) as? Date {
            if !Calendar.current.isDate(lastDate, inSameDayAs: today) {
                let days = defaults.integer(forKey: distinctDayCountKey)
                defaults.set(days + 1, forKey: distinctDayCountKey)
            }
        } else {
            defaults.set(1, forKey: distinctDayCountKey)
        }
        defaults.set(today, forKey: lastCheckInDateKey)
    }

    /// Call when a streak breaks (agent relapse)
    func trackStreakBreak() {
        UserDefaults.standard.set(Date(), forKey: lastStreakBreakKey)
    }

    // MARK: - Evaluation

    /// Check if we should show a review pre-screen after a streak milestone
    func checkForReviewPrompt(streak: Int, totalHabitCount: Int) -> Decision {
        guard reviewTriggerStreaks.contains(streak) else { return .skip }
        return evaluateGates(totalHabitCount: totalHabitCount)
    }

    /// Check if we should show a review pre-screen after an achievement unlock
    /// Fires on first achievement and every 5th after that
    func checkForReviewAfterAchievement(achievementCount: Int, totalHabitCount: Int) -> Decision {
        guard achievementCount == 1 || achievementCount % 5 == 0 else { return .skip }
        return evaluateGates(totalHabitCount: totalHabitCount)
    }

    private func evaluateGates(totalHabitCount: Int) -> Decision {
        let defaults = UserDefaults.standard

        // Gate 1: Minimum habits created
        guard totalHabitCount >= minimumHabits else {
            #if DEBUG
            print("ReviewManager: Skip — only \(totalHabitCount) habits (need \(minimumHabits))")
            #endif
            return .skip
        }

        // Gate 2: Minimum total check-ins
        let checkIns = defaults.integer(forKey: totalCheckInCountKey)
        guard checkIns >= minimumCheckIns else {
            #if DEBUG
            print("ReviewManager: Skip — only \(checkIns) check-ins (need \(minimumCheckIns))")
            #endif
            return .skip
        }

        // Gate 3: Minimum distinct calendar days
        let days = defaults.integer(forKey: distinctDayCountKey)
        guard days >= minimumDistinctDays else {
            #if DEBUG
            print("ReviewManager: Skip — only \(days) distinct days (need \(minimumDistinctDays))")
            #endif
            return .skip
        }

        // Gate 4: No streak break in last 48 hours
        if let lastBreak = defaults.object(forKey: lastStreakBreakKey) as? Date {
            let hoursSinceBreak = Calendar.current.dateComponents([.hour], from: lastBreak, to: Date()).hour ?? 0
            guard hoursSinceBreak >= streakBreakCooldownHours else {
                #if DEBUG
                print("ReviewManager: Skip — streak broke \(hoursSinceBreak)h ago (need \(streakBreakCooldownHours)h)")
                #endif
                return .skip
            }
        }

        // Gate 5: Minimum days since last prompt
        if let lastRequest = defaults.object(forKey: lastReviewRequestDateKey) as? Date {
            let daysSince = Calendar.current.dateComponents([.day], from: lastRequest, to: Date()).day ?? 0
            guard daysSince >= minimumDaysBetweenPrompts else {
                #if DEBUG
                print("ReviewManager: Skip — last prompt \(daysSince) days ago (need \(minimumDaysBetweenPrompts))")
                #endif
                return .skip
            }
        }

        // Gate 6: Rolling 365-day annual limit
        guard !hasExceededAnnualLimit() else {
            #if DEBUG
            print("ReviewManager: Skip — annual limit reached")
            #endif
            return .skip
        }

        #if DEBUG
        print("ReviewManager: All gates passed — showing pre-screen")
        #endif
        return .showPreScreen
    }

    // MARK: - Annual Limit (365-day rolling window)

    private func hasExceededAnnualLimit() -> Bool {
        let defaults = UserDefaults.standard

        if let firstPrompt = defaults.object(forKey: firstPromptDateKey) as? Date {
            let daysSinceFirst = Calendar.current.dateComponents([.day], from: firstPrompt, to: Date()).day ?? 0
            if daysSinceFirst >= 365 {
                // Reset the annual window
                defaults.set(0, forKey: reviewRequestCountKey)
                defaults.removeObject(forKey: firstPromptDateKey)
                return false
            }
        }

        let count = defaults.integer(forKey: reviewRequestCountKey)
        return count >= maxRequestsPerYear
    }

    // MARK: - Execute Review

    /// Call when user taps "Yes!" in the pre-screen dialog
    func executeReview() {
        let defaults = UserDefaults.standard

        // Track first prompt date for annual window
        if defaults.object(forKey: firstPromptDateKey) == nil {
            defaults.set(Date(), forKey: firstPromptDateKey)
        }

        // Update tracking
        defaults.set(Date(), forKey: lastReviewRequestDateKey)
        defaults.set(
            defaults.integer(forKey: reviewRequestCountKey) + 1,
            forKey: reviewRequestCountKey
        )

        #if DEBUG
        print("ReviewManager: Requesting App Store review")
        #endif

        // Request review on main thread
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }

    /// Open App Store review page directly (for Settings button)
    func openAppStoreReview() {
        guard let url = URL(string: "https://apps.apple.com/app/id6757750786?action=write-review") else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Reset (for testing)

    func reset() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: lastReviewRequestDateKey)
        defaults.removeObject(forKey: reviewRequestCountKey)
        defaults.removeObject(forKey: firstPromptDateKey)
        defaults.removeObject(forKey: totalCheckInCountKey)
        defaults.removeObject(forKey: distinctDayCountKey)
        defaults.removeObject(forKey: lastCheckInDateKey)
        defaults.removeObject(forKey: lastStreakBreakKey)
    }
}
