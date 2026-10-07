import SwiftUI

/// Estructura común de iOS-recuperar-contraseña, iOS-verificar-codigo e iOS-new-password:
/// cabecera celeste con logo y hoja blanca con el indicador de pasos.
struct PasswordRecoveryLayout<Content: View>: View {
    @Environment(AppRouter.self) private var router
    let step: Int
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .top) {
            Color.fiSkyLight.ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    FiamasLogo(layout: .vertical, iconHeight: 50)
                        .frame(maxWidth: .infinity)
                        .frame(height: 190)

                    Button { router.pop() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.fiNavy)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.leading, 8)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        StepIndicator(current: step)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 18)
                        content
                    }
                    .padding(.horizontal, 36)
                    .padding(.top, 18)
                    .padding(.bottom, 30)
                }
                .scrollBounceBehavior(.basedOnSize)
                .background(
                    TopRoundedSheet(radius: 28)
                        .fill(.white)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
