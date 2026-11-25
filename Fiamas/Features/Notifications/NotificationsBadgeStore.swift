import Foundation
import Observation

/// iOS-notification-badge
@MainActor
@Observable
final class NotificationsBadgeStore {
    static let shared = NotificationsBadgeStore()

    var unreadCount: Int = 0

    nonisolated static var currentUserKey: String {
        let raw = UserDefaults.standard.string(forKey: "user_id")?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (raw?.isEmpty == false) ? raw! : "guest"
    }

    nonisolated static func readKey(for userKey: String = currentUserKey) -> String {
        "readReminders_\(userKey)"
    }

    nonisolated static func deletedKey(for userKey: String = currentUserKey) -> String {
        "deletedReminders_\(userKey)"
    }

    static func notificationID(for fiado: FiadoAPI, daysUntilDue: Int) -> String {
        let due = fiado.fechaVencimiento ?? ""
        let bucket = daysUntilDue < 0 ? "mora" : "upcoming"
        return "\(fiado.id)-\(due)-\(bucket)"
    }

    func refresh() async {
        do {
            let fiados = try await DebtsService.shared.fetchMyDebts()
            update(from: fiados)
        } catch {
            // Conserva el último conteo conocido si hay error de red
        }
    }

    func update(from fiados: [FiadoAPI]) {
        let read = Set(UserDefaults.standard.stringArray(forKey: Self.readKey()) ?? [])
        let deleted = Set(UserDefaults.standard.stringArray(forKey: Self.deletedKey()) ?? [])

        let activeUnread = fiados.compactMap { fiado -> String? in
            guard let days = fiado.daysUntilDue, days <= 2 else { return nil }
            let id = Self.notificationID(for: fiado, daysUntilDue: days)
            guard !deleted.contains(id), !read.contains(id) else { return nil }
            return id
        }

        unreadCount = activeUnread.count
    }

    func setUnreadCount(_ count: Int) {
        unreadCount = max(0, count)
    }
}
