import SwiftUI

@Observable
final class AppRouter {
    enum Phase { case splash, auth, main }

    var phase: Phase = .splash
    var authPath: [Route] = []
    var mainPath: [Route] = []
    var initialTab: MainTab = .home

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
        mainPath = []
        phase = .main
    }

    func logout() {
        authPath = [.login]
        phase = .auth
    }
}
