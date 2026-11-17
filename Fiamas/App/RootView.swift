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
                    WelcomeView()
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
            case .welcome: WelcomeView()
            case .register(let qrCode): RegisterView(qrCode: qrCode)
            case .login: LoginView()
            case .phoneVerification: PhoneVerificationView()
            case .recoverPassword: RecoverPasswordView()
            case .verifyCode: VerifyCodeView()
            case .newPassword: NewPasswordView()
            case .menu: MenuView()
            case .notifications: NotificationsView()
            case .paymentDetail(let payment): PaymentDetailView(payment: payment)
            case .changePassword: ChangePasswordView()
            case .editProfile: EditProfileView()
            case .help: HelpView()
            case .terms: TermsView()
            case .privacy: PrivacyView()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
