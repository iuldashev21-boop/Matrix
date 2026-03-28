import StoreKit
import SwiftUI

/// Manages App Store review prompts at appropriate moments
final class ReviewManager {
    static let shared = ReviewManager()

    private init() {}

    // MARK: - UserDefaults Keys
    private let lastReviewRequestDateKey = "lastReviewRequestDate"
    private let reviewRequestCountKey = "reviewRequestCount"
    private let hasRequestedReviewKey = "hasRequestedReview"

    // MARK: - Configuration
    /// Minimum days between review prompts
    private let minimumDaysBetweenPrompts = 90
    /// Maximum number of review requests (Apple limits to 3 per year)
    private let maxRequestsPerYear = 3

    // MARK: - Milestone Triggers
    /// Streaks that should trigger a review prompt consideration
    private let reviewTriggerStreaks = [7, 21, 66]

    /// Check if we should request a review after reaching a streak milestone
    func checkForReviewPrompt(streak: Int) {
        guard reviewTriggerStreaks.contains(streak) else { return }
        requestReviewIfAppropriate()
    }

    /// Check if we should request a review after unlocking an achievement
    func checkForReviewAfterAchievement() {
        // Only prompt on first few achievements, not every one
        let achievementCount = UserDefaults.standard.integer(forKey: "unlockedAchievementCount")
        if achievementCount == 1 || achievementCount == 5 {
            requestReviewIfAppropriate()
        }
    }

    /// Request review if conditions are met
    func requestReviewIfAppropriate() {
        // Check if enough time has passed since last request
        if let lastRequest = UserDefaults.standard.object(forKey: lastReviewRequestDateKey) as? Date {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequest, to: Date()).day ?? 0
            guard daysSinceLastRequest >= minimumDaysBetweenPrompts else {
                #if DEBUG
                print("ReviewManager: Too soon since last request (\(daysSinceLastRequest) days)")
                #endif
                return
            }
        }

        // Check if we've hit the yearly limit
        let requestCount = UserDefaults.standard.integer(forKey: reviewRequestCountKey)
        guard requestCount < maxRequestsPerYear else {
            #if DEBUG
            print("ReviewManager: Hit yearly limit (\(requestCount) requests)")
            #endif
            return
        }

        // Request the review
        requestReview()
    }

    /// Actually request the review from Apple
    private func requestReview() {
        #if DEBUG
        print("ReviewManager: Requesting App Store review")
        #endif

        // Update tracking
        UserDefaults.standard.set(Date(), forKey: lastReviewRequestDateKey)
        UserDefaults.standard.set(
            UserDefaults.standard.integer(forKey: reviewRequestCountKey) + 1,
            forKey: reviewRequestCountKey
        )
        UserDefaults.standard.set(true, forKey: hasRequestedReviewKey)

        // Request review on main thread
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }

    /// Reset review tracking (for testing)
    func reset() {
        UserDefaults.standard.removeObject(forKey: lastReviewRequestDateKey)
        UserDefaults.standard.removeObject(forKey: reviewRequestCountKey)
        UserDefaults.standard.removeObject(forKey: hasRequestedReviewKey)
    }
}
