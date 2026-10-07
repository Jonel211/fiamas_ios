import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        Group {
            switch router.phase {
            case .splash:
                SplashView()
            case .auth:
                NavigationStack(path: $router.authPath) {
                    RegisterView()
                        .navigationDestination(for: Route.self, destination: destination)
                }
            case .main:
                NavigationStack(path: $router.mainPath) {
                    MainTabView()
                        .navigationDestination(for: Route.self, destination: destination)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: router.phase)
    }

    @ViewBuilder
    private func destination(_ route: Route) -> some View {
        Group {
            switch route {
            case .login: LoginView()
            case .phoneVerification: PhoneVerificationView()
            case .recoverPassword: RecoverPasswordView()
            case .verifyCode: VerifyCodeView()
            case .newPassword: NewPasswordView()
            case .menu: MenuView()
            case .notifications: NotificationsView()
            case .paymentDetail: PaymentDetailView()
            case .changePassword: ChangePasswordView()
            case .help: HelpView()
            case .complaints: ComplaintsView()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
