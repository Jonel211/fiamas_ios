#if DEBUG
import Foundation

extension AppRouter {
    /// Abre una pantalla directamente al lanzar la app desde Xcode o el simulador.
    /// Uso: argumento de lanzamiento `-screen <nombre>` (ej. `-screen pagos`).
    func applyDebugLaunchScreen() {
        guard let name = UserDefaults.standard.string(forKey: "screen") else { return }
        switch name {
        case "registro": phase = .auth
        case "verificacion": phase = .auth; authPath = [.phoneVerification]
        case "login": phase = .auth; authPath = [.login]
        case "recuperar": phase = .auth; authPath = [.login, .recoverPassword]
        case "codigo": phase = .auth; authPath = [.login, .recoverPassword, .verifyCode]
        case "nueva": phase = .auth; authPath = [.login, .recoverPassword, .verifyCode, .newPassword]
        case "inicio": phase = .main
        case "fiados": phase = .main; initialTab = .credits
        case "menu": phase = .main; mainPath = [.menu]
        case "notificaciones": phase = .main; mainPath = [.notifications]
        case "pagos": phase = .main; initialTab = .payments
        case "perfil": phase = .main; initialTab = .profile
        case "detalle": phase = .main; mainPath = [.paymentDetail]
        case "cambiar": phase = .main; mainPath = [.changePassword]
        case "editar": phase = .main; initialTab = .profile; mainPath = [.editProfile]
        case "ayuda": phase = .main; mainPath = [.menu, .help]
        case "reclamos": phase = .main; mainPath = [.menu, .complaints]
        default: break
        }
    }
}
#endif
