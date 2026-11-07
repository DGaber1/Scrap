import Foundation

/// Schedules "this is about to expire" reminders. The app supplies the real
/// implementation (local notifications); ScrapCore only knows the shape.
public protocol ScpReminderScheduling: Sendable {
    /// Asks the user for permission to send reminders. Returns true if allowed.
    func requestPermission() async -> Bool

    /// Replaces every scheduled reminder with one per item that has an expiration date.
    func reschedule(for items: [ScpPantryItem]) async
}

/// A scheduler that does nothing, for previews and tests.
public struct ScpNoReminderScheduler: ScpReminderScheduling {
    public init() {}
    public func requestPermission() async -> Bool { false }
    public func reschedule(for items: [ScpPantryItem]) async {}
}
