import Foundation

struct AppNotification: Identifiable {
    enum Kind {
        case overdue, reminder, dueSoon
    }

    let id = UUID()
    let kind: Kind
    let time: String
    let title: String
    let message: String
    var unread: Bool
}

struct NotificationGroup: Identifiable {
    let id = UUID()
    let title: String
    var items: [AppNotification]
}
