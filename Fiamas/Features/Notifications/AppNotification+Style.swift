import SwiftUI

/// Apariencia de cada tipo de notificación.
extension AppNotification.Kind {
    var label: String {
        switch self {
        case .overdue: "Vencido"
        case .reminder: "Recordatorio"
        case .dueSoon: "Por vencer"
        }
    }

    var icon: String {
        switch self {
        case .overdue: "exclamationmark"
        case .reminder: "bell"
        case .dueSoon: "clock"
        }
    }

    var foreground: Color {
        switch self {
        case .overdue: .fiRed
        case .reminder: .fiTealDark
        case .dueSoon: .fiAmberText
        }
    }

    var background: Color {
        switch self {
        case .overdue: .fiRedSoft
        case .reminder: .fiGreenSoft
        case .dueSoon: .fiOrangeSoft
        }
    }
}
