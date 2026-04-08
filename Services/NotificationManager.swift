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
            // Use object(forKey:) so midnight (0) isn't treated as unset
            if UserDefaults.standard.object(forKey: Keys.reminderHour) == nil {
                return 20 // Default 8 PM
            }
            return UserDefaults.standard.integer(forKey: Keys.reminderHour)
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

    /// Returns the stored reminder time as a Date (for DatePicker binding)
    func timeAsDate() -> Date {
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        return Calendar.current.date(from: components) ?? Date()
    }

    /// Sets reminder hour and minute from a Date
    func setTime(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        if let hour = components.hour {
            UserDefaults.standard.set(hour, forKey: Keys.reminderHour)
        }
        if let minute = components.minute {
            UserDefaults.standard.set(minute, forKey: Keys.reminderMinute)
        }
        if notificationsEnabled { scheduleDailyReminder() }
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
