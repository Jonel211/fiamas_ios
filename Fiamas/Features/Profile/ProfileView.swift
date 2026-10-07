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
                        .padding(.bottom, 18)

                    sectionTitle("INFORMACIÓN PERSONAL")
                    VStack(spacing: 0) {
                        row(icon: "person", title: "Nombres", value: store.profile.firstName)
                        Divider().padding(.horizontal, 12)
                        row(icon: "person.text.rectangle", title: "Apellidos", value: store.profile.lastName)
                    }
                    .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                    .padding(.bottom, 14)

                    sectionTitle("CONTACTO")
                    HStack(spacing: 10) {
                        iconBox("phone")
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Teléfono").font(.inter(9)).foregroundStyle(Color.fiGrayText)
                            Text(store.profile.phone).font(.inter(12, .medium))
                        }
                        Spacer()
                        StatusBadge(text: "Verificado", foreground: .fiTeal, background: .fiGreenSoft, font: .inter(9, .medium))
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                    .padding(.bottom, 14)

                    sectionTitle("SEGURIDAD")
                    Button { router.push(.changePassword) } label: {
                        HStack(spacing: 10) {
                            iconBox("lock")
                            Text("Cambiar contraseña").font(.inter(12, .medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.fiLightGrayText)
                        }
                        .foregroundStyle(.black)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 16)
            }
            .background(Color.fiProfileBackground)
        }
        .photoSourcePicker(
            isPresented: $isChoosingPhoto,
            canRemove: store.photo != nil,
            onPick: { store.setPhoto($0) },
            onRemove: { store.setPhoto(nil) }
        )
    }

    private var profileCard: some View {
        VStack(spacing: 2) {
            Button { isChoosingPhoto = true } label: {
                ProfileAvatarView(photo: store.photo, initials: store.profile.initials)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 10)

            Text(store.profile.fullName)
                .font(.inter(18, .semibold))
            Text(store.profile.phone)
                .font(.inter(11))
                .foregroundStyle(Color.fiGrayText)

            HStack(spacing: 8) {
                chip(icon: "checkmark.circle", text: "Teléfono verificado")
                chip(icon: "hand.thumbsup", text: "Pagador bueno")
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(.white)
                Circle().fill(Color.fiGreenSoft.opacity(0.6)).frame(width: 90)
                    .offset(x: 120, y: -40)
                Circle().fill(Color.fiGreenSoft.opacity(0.6)).frame(width: 60)
                    .offset(x: -140, y: 50)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        )
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    private func chip(icon: String, text: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 9))
            Text(text).font(.inter(9, .medium))
        }
        .foregroundStyle(Color.fiTeal)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.fiGreenSoft))
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.inter(9, .semibold))
            .foregroundStyle(Color.fiTextSecondary)
            .padding(.bottom, 8)
    }

    private func iconBox(_ name: String) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.fiIconBackground)
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: name)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.fiTealDark)
            )
    }

    private func row(icon: String, title: String, value: String) -> some View {
        Button { router.push(.editProfile) } label: {
            HStack(spacing: 10) {
                iconBox(icon)
                Text(title).font(.inter(12)).foregroundStyle(Color.fiGrayText)
                Spacer()
                Text(value).font(.inter(12, .semibold)).foregroundStyle(.black)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.fiLightGrayText)
            }
            .padding(12)
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
