import SwiftUI

/// Estructura de las pantallas de acceso: zona superior con el logo
/// y una hoja con esquinas redondeadas para el formulario.
struct AuthLayout<Content: View>: View {
    @Environment(AppRouter.self) private var router

    var topColor: Color = .fiSky
    var sheetColor: Color = .white
    var logoLayout: FiamasLogo.Layout = .vertical
    var topHeight: CGFloat = 220
    var onBack: (() -> Void)? = nil
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .top) {
            topColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Logo interactivo que regresa a la pantalla de bienvenida
                Button(action: {
                    router.popToRoot()
                }) {
                    FiamasLogo(layout: logoLayout, iconHeight: logoLayout == .horizontal ? 48 : 64)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .frame(height: topHeight)
                .overlay(alignment: .topLeading) {
                    if let onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.fiNavy)
                                .frame(width: 42, height: 42)
                                .background(Circle().fill(.white.opacity(0.75)))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Atrás")
                        .padding(.leading, 20)
                        .padding(.top, 8)
                    }
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        content
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 32)
                    .padding(.bottom, 32)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32)
                        .fill(sheetColor)
                        .shadow(color: .black.opacity(0.06), radius: 12, y: -4)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// Título y subtítulo de las pantallas de acceso.
struct AuthTitle: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.poppins(26, .bold))
                .foregroundStyle(Color.fiTextPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(.poppins(15))
                    .foregroundStyle(Color.fiTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// "¿Pregunta? Enlace" al pie de los formularios.
struct AuthFooterLink: View {
    let prompt: String
    let link: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(prompt)
                .font(.poppins(14))
                .foregroundStyle(Color.fiTextSecondary)
            Button(action: action) {
                Text(link)
                    .font(.poppins(14, .semibold))
                    .foregroundStyle(Color.fiTeal)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
