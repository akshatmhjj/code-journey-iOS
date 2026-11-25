import Foundation

/// Counts how many days in a row the person has finished a skill.
/// Pure logic: the calendar and "now" are passed in, so the rules are easy to test.
enum StreakRules {
    /// The number of days in a row that end today, or yesterday if nothing was finished today yet.
    /// A day counts when at least one skill was finished on it.
    static func currentStreak(
        finishedDates: [Date],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let finishedDays = Set(finishedDates.map { calendar.startOfDay(for: $0) })
        var day = calendar.startOfDay(for: now)

        // Today has no finished skill yet, so the streak can still continue from yesterday.
        if !finishedDays.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }

        var streak = 0
        while finishedDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }
}
