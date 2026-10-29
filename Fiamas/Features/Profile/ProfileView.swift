import SwiftUI

/// iOS-perfil-clientes
struct ProfileView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var store
    @State private var isChoosingPhoto = false

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Perfil",
                trailingIcon: "square.and.pencil",
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.editProfile) }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    profileCard
                        .padding(.bottom, 28)

                    GroupLabel(title: "Información personal")
                        .padding(.bottom, 8)
                    VStack(spacing: 0) {
                        row(icon: "person", title: "Nombres", value: store.profile.firstName) {
                            router.push(.editProfile)
                        }
                        FiDivider(leadingInset: 64)
                        row(icon: "person.text.rectangle", title: "Apellidos", value: store.profile.lastName) {
                            router.push(.editProfile)
                        }
                    }
                    .fiCard(padding: 0)
                    .padding(.bottom, 24)

                    GroupLabel(title: "Contacto")
                        .padding(.bottom, 8)
                    HStack(spacing: 14) {
                        IconTile(systemName: "phone", size: 36)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Teléfono")
                                .font(.poppins(12))
                                .foregroundStyle(Color.fiTextSecondary)
                            Text(store.profile.phone)
                                .font(.poppins(15, .medium))
                                .foregroundStyle(Color.fiTextPrimary)
                        }
                        Spacer()
                        StatusBadge(text: "Verificado", icon: "checkmark")
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .fiCard(padding: 0)
                    .padding(.bottom, 24)

                    GroupLabel(title: "Seguridad")
                        .padding(.bottom, 8)
                    row(icon: "lock", title: "Cambiar contraseña", value: nil) {
                        router.push(.changePassword)
                    }
                    .fiCard(padding: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .fiScreenBackground()
        .photoSourcePicker(
            isPresented: $isChoosingPhoto,
            canRemove: store.photo != nil,
            onPick: { selectedImage in
                Task {
                    await store.uploadPhotoToBackend(selectedImage)
                }
            },
            onRemove: {
                store.setPhoto(nil)
            }
        )
    }

    private var profileCard: some View {
        VStack(spacing: 4) {
            Button { isChoosingPhoto = true } label: {
                ZStack {
                    ProfileAvatarView(photo: store.photo, initials: store.profile.initials, size: 92)
                    
                    if store.isUploading {
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 92, height: 92)
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(store.isUploading)
            .accessibilityLabel("Cambiar foto de perfil")
            .padding(.bottom, 10)

            Text(store.profile.fullName)
                .font(.poppins(21, .semibold))
                .foregroundStyle(Color.fiTextPrimary)
            Text(store.profile.phone)
                .font(.poppins(14))
                .foregroundStyle(Color.fiTextSecondary)

            HStack(spacing: 8) {
                StatusBadge(text: "Teléfono verificado", icon: "checkmark.seal.fill")
                StatusBadge(text: "Pagador bueno", icon: "hand.thumbsup.fill", foreground: .fiWarning, background: .fiGoldSoft)
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20).fill(.white)
                LinearGradient(colors: [Color.fiTealSoft, .white], startPoint: .top, endPoint: .bottom)
                    .frame(height: 90)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
            }
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
    }

    private func row(icon: String, title: String, value: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                IconTile(systemName: icon, size: 36)
                Text(title)
                    .font(.poppins(15, value == nil ? .medium : .regular))
                    .foregroundStyle(value == nil ? Color.fiTextPrimary : Color.fiTextSecondary)
                Spacer()
                if let value {
                    Text(value)
                        .font(.poppins(15, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.fiTextTertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
        .environment(AppRouter())
        .environment(ProfileStore())
}
