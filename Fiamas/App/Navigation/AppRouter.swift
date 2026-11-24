import SwiftUI

@Observable
final class AppRouter {
    enum Phase { case splash, auth, main }

    var phase: Phase = .splash
    var authPath: [Route] = []
    var mainPaths: [MainTab: [Route]] = [:]
    var initialTab: MainTab = .home
    var activeTab: MainTab = .home

    var mainPath: [Route] {
        get { mainPaths[activeTab] ?? [] }
        set { mainPaths[activeTab] = newValue }
    }

    init() {
        #if DEBUG
        applyDebugLaunchScreen()
        #endif
    }

    func push(_ route: Route) {
        if phase == .main { mainPath.append(route) } else { authPath.append(route) }
    }

    func pop() {
        if phase == .main { _ = mainPath.popLast() } else { _ = authPath.popLast() }
    }

    func popToRoot() {
        if phase == .main {
            mainPath.removeAll()
        } else {
            authPath.removeAll()
        }
    }

    func enterApp() {
        mainPaths = [:]
        activeTab = initialTab
        phase = .main
        activeTab = .home // Reiniciamos a home al entrar
    }

    func logout() {
        mainPaths = [:]
        authPath = [] // Se deja en blanco para cargar el WelcomeView con su diseño completo
        phase = .auth
    }
    
    // Cierra el menú y va al perfil
    func goToProfileTab() {
        popToRoot() // Esto cierra el menú u otras ventanas encima
        activeTab = .profile // Cambia la pestaña inferior a Perfil
    }
}
