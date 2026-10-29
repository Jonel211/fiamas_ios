import SwiftUI
 

/// iOS-menu
struct MenuView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore
    @State private var isConfirmingLogout = false

    private let shareMessage = "Revisa tus fiados y pagos con Fiamas."

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Menú", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 14) {
                        ProfileAvatarView(photo: profileStore.photo, initials: profileStore.profile.initials,
                                          size: 56, showsCameraBadge: false)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profileStore.profile.fullName)
                                .font(.poppins(17, .semibold))
                                .foregroundStyle(Color.fiTextPrimary)
                            Text(profileStore.profile.phone)
                                .font(.poppins(13))
                                .foregroundStyle(Color.fiTextSecondary)
                        }
                    }
                    .fiCard()
                    .padding(.bottom, 24)

                    GroupLabel(title: "Soporte")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        Button { router.push(.help) } label: {
                            MenuRowView(icon: "questionmark.circle", title: "Centro de ayuda")
                        }
                        FiDivider(leadingInset: 64)
                        Button { router.push(.complaints) } label: {
                            MenuRowView(icon: "exclamationmark.bubble", title: "Atención de reclamos")
                        }
                        FiDivider(leadingInset: 64)
                        ShareLink(item: shareMessage) {
                            MenuRowView(icon: "square.and.arrow.up", title: "Compartir aplicación")
                        }
                    }
                    .buttonStyle(.plain)
                    .fiCard(padding: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }

            FiButton(title: "Cerrar sesión", style: .accent, icon: "rectangle.portrait.and.arrow.right") {
                isConfirmingLogout = true
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Text("Fiamas · versión 1.0")
                .font(.poppins(12))
                .foregroundStyle(Color.fiTextTertiary)
                .padding(.bottom, 12)
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("¿Quieres cerrar sesión?", isPresented: $isConfirmingLogout, titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) {
                router.logout()
                profileStore.reload()
            }
        }
    }
}

#Preview {
    MenuView()
        .environment(AppRouter())
        .environment(ProfileStore())
}
