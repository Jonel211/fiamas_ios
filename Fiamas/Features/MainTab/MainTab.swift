import SwiftUI

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
        case .credits: "list.bullet"
        case .payments: "wallet.bifold"
        case .profile: "person"
        }
    }
}
