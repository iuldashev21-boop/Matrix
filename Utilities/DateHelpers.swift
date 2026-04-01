import Foundation

enum DateHelpers {
    /// Returns the number of days between two dates
    static func daysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        return calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
    }
}

// MARK: - DateHelper (Cached Date Values)

/// Provides stable, cached date values to prevent midnight race conditions.
/// All date comparisons in the app should use these methods instead of Date() directly.
enum DateHelper {

    // MARK: - Cache Storage

    private static let lock = NSLock()
    private static var _cachedToday: Date?
    private static var _cachedYesterday: Date?
    private static var _lastCacheTime: Date?

    /// Cache duration in seconds - dates are stable within this window
    private static let cacheDuration: TimeInterval = 2.0

    // MARK: - Public Properties

    /// Today's date (start of day), cached for stability during operations
    static var today: Date {
        refreshCacheIfNeeded()
        return lock.withLock { _cachedToday! }
    }

    /// Yesterday's date (start of day), cached for stability
    static var yesterday: Date {
        refreshCacheIfNeeded()
        return lock.withLock { _cachedYesterday! }
    }

    /// Current hour (0-23) based on cached time
    static var currentHour: Int {
        refreshCacheIfNeeded()
        return lock.withLock { Calendar.current.component(.hour, from: _lastCacheTime!) }
    }

    // MARK: - Comparison Methods

    /// Check if a date falls on today
    static func isToday(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) == today
    }

    /// Check if a date falls on yesterday
    static func isYesterday(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) == yesterday
    }

    /// Check if a date is before yesterday (streak is broken)
    static func isBeforeYesterday(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) < yesterday
    }

    // MARK: - Force Refresh

    /// Force a cache refresh - call this when the app comes to foreground
    static func invalidateCache() {
        lock.withLock {
            _cachedToday = nil
            _cachedYesterday = nil
            _lastCacheTime = nil
        }
    }

    // MARK: - Private

    private static func refreshCacheIfNeeded() {
        lock.withLock {
            let now = Date()

            // Check if cache is still valid
            if let lastCache = _lastCacheTime,
               now.timeIntervalSince(lastCache) < cacheDuration,
               _cachedToday != nil {
                return
            }

            // Refresh cache
            let calendar = Calendar.current
            _cachedToday = calendar.startOfDay(for: now)
            _cachedYesterday = calendar.date(byAdding: .day, value: -1, to: _cachedToday!)
            _lastCacheTime = now
        }
    }
}

