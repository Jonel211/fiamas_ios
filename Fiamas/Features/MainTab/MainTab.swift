import Foundation

enum MainTab: CaseIterable {
    case home, credits, payments, profile

    var title: String {
        switch self {
        case .home: "Inicio"
        case .credits: "Mis fiados"
        case .payments: "Pagos"
        case .profile: "Perfil"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .credits: "list.bullet.rectangle"
        case .payments: "wallet.bifold"
        case .profile: "person"
        }
    }

    var selectedIcon: String { icon + ".fill" }
}
