import Foundation
import Observation

/// iOS-notification-badge
@MainActor
@Observable
final class NotificationsBadgeStore {
    static let shared = NotificationsBadgeStore()

    var unreadCount: Int = 0

    private var userKey: String {
        UserDefaults.standard.string(forKey: "user_id") ?? "guest"
    }

    private var readKey: String {
        "readReminders_\(userKey)"
    }

    private var deletedKey: String {
        "deletedReminders_\(userKey)"
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
        let read = Set(UserDefaults.standard.stringArray(forKey: readKey) ?? [])
        let deleted = Set(UserDefaults.standard.stringArray(forKey: deletedKey) ?? [])

        let activeUnread = fiados.compactMap { fiado -> String? in
            guard let days = fiado.daysUntilDue, days <= 2 else { return nil }
            let id = "\(fiado.id)-\(fiado.fechaVencimiento ?? "")-\(days < 0 ? "mora" : String(days))"
            guard !deleted.contains(id), !read.contains(id) else { return nil }
            return id
        }

        unreadCount = activeUnread.count
    }

    func setUnreadCount(_ count: Int) {
        unreadCount = max(0, count)
    }
}
