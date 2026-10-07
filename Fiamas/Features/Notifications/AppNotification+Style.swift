import Foundation

/// Apariencia de cada tipo de notificación.
extension AppNotification.Kind {
    var icon: String {
        switch self {
        case .overdue: "exclamationmark.circle"
        case .reminder: "bell"
        case .dueSoon: "clock"
        }
    }
}
