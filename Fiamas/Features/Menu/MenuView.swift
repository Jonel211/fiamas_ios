import SwiftUI

/// iOS-menu
struct MenuView: View {
    @Environment(AppRouter.self) private var router

    private let shareMessage = "Revisa tus fiados y pagos con Fiamas."

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Menu", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            VStack(spacing: 0) {
                Button {
                    router.push(.help)
                } label: {
                    MenuRowView(icon: "questionmark.circle", title: "Centro de ayuda")
                }
                divider

                Button {
                    router.push(.complaints)
                } label: {
                    MenuRowView(icon: "exclamationmark.bubble", title: "Atención de reclamos")
                }
                divider

                ShareLink(item: shareMessage) {
                    MenuRowView(icon: "square.and.arrow.up", title: "Compartir aplicación")
                }
                divider
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()

            Button {
                router.logout()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Cerrar sesión")
                        .font(.poppins(15, .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.fiGold))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.fiDivider)
            .frame(height: 1)
            .padding(.leading, 36)
    }
}

#Preview {
    MenuView().environment(AppRouter())
}
