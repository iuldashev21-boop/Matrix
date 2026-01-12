import Foundation
import UserNotifications

/// Manages local notifications for habit reminders
@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false
    @Published var pendingPermissionRequest: Bool = false

    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Notification Identifiers

    private enum NotificationID {
        static let dailyReminder = "com.matrixhabit.dailyReminder"
    }

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let notificationsEnabled = "notificationsEnabled"
        static let reminderHour = "reminderHour"
        static let reminderMinute = "reminderMinute"
    }

    // MARK: - Settings

    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.notificationsEnabled) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.notificationsEnabled)
            if newValue {
                scheduleDailyReminder()
            } else {
                cancelAllReminders()
            }
        }
    }

    var reminderHour: Int {
        get {
            let hour = UserDefaults.standard.integer(forKey: Keys.reminderHour)
            return hour == 0 ? 20 : hour // Default 8 PM
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.reminderHour)
            if notificationsEnabled { scheduleDailyReminder() }
        }
    }

    var reminderMinute: Int {
        get { UserDefaults.standard.integer(forKey: Keys.reminderMinute) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.reminderMinute)
            if notificationsEnabled { scheduleDailyReminder() }
        }
    }

    // MARK: - Initialization

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isAuthorized = granted
                if granted && notificationsEnabled {
                    scheduleDailyReminder()
                }
            }
            return granted
        } catch {
            ErrorLogger.log(error, operation: "requestNotificationAuthorization", context: "NotificationManager")
            return false
        }
    }

    // MARK: - Scheduling

    func scheduleDailyReminder() {
        guard isAuthorized && notificationsEnabled else { return }

        // Cancel existing reminder first
        cancelAllReminders()

        // Create content
        let content = UNMutableNotificationContent()
        content.title = "SIGNAL CHECK"
        content.body = "Time to log your daily progress, Operator."
        content.sound = .default
        content.badge = 1

        // Create trigger for daily reminder at specified time
        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create request
        let request = UNNotificationRequest(
            identifier: NotificationID.dailyReminder,
            content: content,
            trigger: trigger
        )

        // Schedule
        notificationCenter.add(request) { error in
            if let error = error {
                ErrorLogger.log(error, operation: "scheduleNotification", context: "NotificationManager")
            }
        }
    }

    func cancelAllReminders() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.dailyReminder])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [NotificationID.dailyReminder])
    }

    // MARK: - Badge Management

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
}
