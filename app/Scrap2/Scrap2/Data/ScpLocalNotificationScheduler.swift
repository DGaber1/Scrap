import Foundation
import UserNotifications
import ScrapCore

/// Sends a local notification a couple of days before an item expires.
struct ScpLocalNotificationScheduler: ScpReminderScheduling {
    private static let identifierPrefix = "scrap.expiry."
    private static let daysBefore = 2

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        default:
            return false
        }
    }

    func reschedule(for items: [ScpPantryItem]) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        let pending = await center.pendingNotificationRequests()
        let old = pending.map(\.identifier).filter { $0.hasPrefix(Self.identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: old)

        let calendar = Calendar.current
        for item in items {
            guard
                let expiration = item.expirationDate,
                let day = calendar.date(byAdding: .day, value: -Self.daysBefore, to: expiration),
                let fireDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day),
                fireDate > Date()
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = String(localized: "Use it up: \(item.ingredient.name.capitalized)")
            content.body = String(
                localized: "\(item.ingredient.name.capitalized) expires on \(expiration.formatted(date: .abbreviated, time: .omitted))."
            )
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: Self.identifierPrefix + item.id.uuidString,
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }
}
