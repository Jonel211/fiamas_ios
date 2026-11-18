import SwiftUI

/// iOS-menu
struct MenuView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore
    @State private var isConfirmingLogout = false
    @State private var isShowingShareSheet = false

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Menú", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // --- INICIO DEL CAMBIO: Tarjeta clickeable ---
                    Button {
                        router.goToProfileTab()
                    } label: {
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
                            Spacer() // Empuja el contenido a la izquierda
                        }
                        .contentShape(Rectangle()) // Hace que todo el fondo blanco sea clickeable
                    }
                    .buttonStyle(.plain)
                    .fiCard()
                    .padding(.bottom, 24)
                    // --- FIN DEL CAMBIO ---

                    GroupLabel(title: "Seguridad")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        Button { router.push(.changePassword) } label: {
                            // Icono nativo para contraseña/seguridad
                            MenuRowView(icon: "lock.fill", title: "Cambiar contraseña")
                        }
                    }
                    .buttonStyle(.plain)
                    .fiCard(padding: 0)
                    .padding(.bottom, 24)

                    GroupLabel(title: "Soporte")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        Button { router.push(.help) } label: {
                            // Icono nativo de ayuda
                            MenuRowView(icon: "questionmark.circle.fill", title: "Centro de ayuda")
                        }
                        FiDivider(leadingInset: 64)
                        Button { router.push(.about) } label: {
                            // Icono nativo de información
                            MenuRowView(icon: "info.circle.fill", title: "Acerca de Fiamas", detail: AppVersion.short)
                        }
                        FiDivider(leadingInset: 64)
                        Button { isShowingShareSheet = true } label: {
                            MenuRowView(icon: "square.and.arrow.up", title: "Compartir aplicación")
                        }
                    }
                    .buttonStyle(.plain)
                    .fiCard(padding: 0)
                    .padding(.bottom, 24)

                    GroupLabel(title: "Legal")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        Button { router.push(.terms) } label: {
                            // Icono nativo de documentos legales
                            MenuRowView(icon: "doc.text.fill", title: "Términos y condiciones")
                        }
                        FiDivider(leadingInset: 64)
                        Button { router.push(.privacy) } label: {
                            // Icono nativo de escudo/privacidad
                            MenuRowView(icon: "checkmark.shield.fill", title: "Política de privacidad")
                        }
                    }
                    .buttonStyle(.plain)
                    .fiCard(padding: 0)
                    .padding(.bottom, 24)
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
        .sheet(isPresented: $isShowingShareSheet) {
            ShareFiamasSheet()
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(uiColor: .systemBackground))
                .presentationCornerRadius(24)
        }
        .confirmationDialog("¿Quieres cerrar sesión?", isPresented: $isConfirmingLogout, titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) {
                AuthService.shared.logout()
                router.logout()
                profileStore.reload()
            }
        }
    }
}

private struct ShareFiamasSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false
    @State private var resetTask: Task<Void, Never>?

    private let link = "https://fiamas.app/descargar"

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.fiTeal)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color.fiTealSoft))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Compartir Fiamas")
                        .font(.poppins(17, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                    Text("Invita a clientes u otros tenderos")
                        .font(.poppins(13))
                        .foregroundStyle(Color.fiTextSecondary)
                }

                Spacer(minLength: 0)

                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.fiTextSecondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Cerrar")
            }

            HStack(spacing: 10) {
                Image(systemName: "link")
                    .foregroundStyle(Color.fiTeal)

                Text(link)
                    .font(.poppins(12))
                    .foregroundStyle(Color.fiTextPrimary)
                    .lineLimit(2)

                Spacer(minLength: 0)

                Button {
                    UIPasteboard.general.string = link
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    copied = true
                    resetTask?.cancel()
                    resetTask = Task {
                        try? await Task.sleep(for: .seconds(2))
                        if !Task.isCancelled { copied = false }
                    }
                } label: {
                    Label(copied ? "Copiado" : "Copiar", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.poppins(13, .semibold))
                        .foregroundStyle(Color.fiTeal)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(copied ? "Enlace copiado" : "Copiar enlace")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(uiColor: .secondarySystemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(uiColor: .separator).opacity(0.5), lineWidth: 1))
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(uiColor: .separator).opacity(0.35))
                .frame(height: 1)
                .padding(.horizontal, 24)
        }
        .onDisappear { resetTask?.cancel() }
    }
}

#Preview {
    MenuView()
        .environment(AppRouter())
        .environment(ProfileStore())
}
