import Foundation

struct AppNotification: Identifiable {
    enum Kind {
        case overdue, reminder, dueSoon
    }

    var id = UUID().uuidString
    let kind: Kind
    let time: String
    let title: String
    let message: String
    var unread: Bool
}

struct NotificationGroup: Identifiable {
    var id = UUID().uuidString
    let title: String
    var items: [AppNotification]
}
