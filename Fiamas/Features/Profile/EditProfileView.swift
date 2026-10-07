import SwiftUI

/// Editar perfil: foto, nombres y apellidos.
struct EditProfileView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var store

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var photo: UIImage?
    @State private var didChangePhoto = false
    @State private var isChoosingPhoto = false
    @State private var didLoad = false

    private var draftProfile: UserProfile {
        UserProfile(firstName: firstName, lastName: lastName, phone: store.profile.phone)
    }

    private var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var hasChanges: Bool {
        didChangePhoto
            || firstName.trimmingCharacters(in: .whitespaces) != store.profile.firstName
            || lastName.trimmingCharacters(in: .whitespaces) != store.profile.lastName
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Editar perfil", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Button { isChoosingPhoto = true } label: {
                        VStack(spacing: 10) {
                            ProfileAvatarView(photo: photo, initials: draftProfile.initials, size: 96)
                            Text(photo == nil ? "Agregar foto" : "Cambiar foto")
                                .font(.poppins(13, .medium))
                                .foregroundStyle(Color.fiTeal)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)

                    label("Nombres")
                    FiTextField(text: $firstName, placeholder: "Tus nombres", height: 40, cornerRadius: 8)
                        .textContentType(.givenName)

                    label("Apellidos")
                    FiTextField(text: $lastName, placeholder: "Tus apellidos", height: 40, cornerRadius: 8)
                        .textContentType(.familyName)

                    label("Teléfono")
                    HStack {
                        Text(store.profile.phone)
                            .font(.inter(15))
                            .foregroundStyle(Color.fiGrayText)
                        Spacer()
                        Image(systemName: "lock")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.fiLightGrayText)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.fiVerifyBackground))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.fiNeutralBorder, lineWidth: 1))
                    Text("Tu número está verificado y no se puede cambiar desde aquí.")
                        .font(.inter(11))
                        .foregroundStyle(Color.fiLightGrayText)
                        .padding(.top, 6)

                    Button(action: save) {
                        Text("Guardar cambios")
                            .font(.poppins(15, .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isValid && hasChanges ? Color.fiGold : Color.fiGoldLight)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!(isValid && hasChanges))
                    .padding(.top, 32)
                }
                .padding(.horizontal, 32)
                .padding(.top, 28)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .photoSourcePicker(
            isPresented: $isChoosingPhoto,
            canRemove: photo != nil,
            onPick: { image in
                photo = image
                didChangePhoto = true
            },
            onRemove: {
                photo = nil
                didChangePhoto = true
            }
        )
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            firstName = store.profile.firstName
            lastName = store.profile.lastName
            photo = store.photo
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.poppins(14, .medium))
            .padding(.top, 14)
            .padding(.bottom, 8)
    }

    private func save() {
        store.update(firstName: firstName, lastName: lastName)
        if didChangePhoto {
            store.setPhoto(photo)
        }
        router.pop()
    }
}

#Preview {
    EditProfileView()
        .environment(AppRouter())
        .environment(ProfileStore())
}
