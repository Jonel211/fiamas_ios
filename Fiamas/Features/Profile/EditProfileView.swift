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
    
    // ESTADOS PARA LA CONEXIÓN CON EL SERVIDOR
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

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
                        VStack(spacing: 12) {
                            ProfileAvatarView(photo: photo, initials: draftProfile.initials, size: 104)
                            Text(photo == nil ? "Agregar foto" : "Cambiar foto")
                                .font(.poppins(15, .semibold))
                                .foregroundStyle(Color.fiTeal)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 28)

                    VStack(spacing: 16) {
                        FiTextField(label: "Nombres", text: $firstName, placeholder: "Tus nombres",
                                    icon: "person", contentType: .givenName, capitalization: .words)
                        FiTextField(label: "Apellidos", text: $lastName, placeholder: "Tus apellidos",
                                    icon: "person.text.rectangle", contentType: .familyName, capitalization: .words)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Teléfono")
                                .font(.poppins(14, .medium))
                                .foregroundStyle(Color.fiTextPrimary)
                            HStack(spacing: 10) {
                                Image(systemName: "phone")
                                    .font(.system(size: 16))
                                    .frame(width: 20)
                                Text(store.profile.phone)
                                    .font(.poppins(15))
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 13))
                            }
                            .foregroundStyle(Color.fiTextTertiary)
                            .padding(.horizontal, 14)
                            .frame(height: 50)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.fiDivider))
                            Text("Tu número está verificado y no se puede cambiar desde aquí.")
                                .font(.poppins(12))
                                .foregroundStyle(Color.fiTextTertiary)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                    )
                    
                    // Mensaje de error si el servidor falla
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.poppins(12))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                    }

                    // Botón de guardar (con estado de carga)
                    FiButton(
                        title: isSaving ? "Guardando..." : "Guardar cambios",
                        style: .accent,
                        isEnabled: isValid && hasChanges && !isSaving,
                        action: { Task { await save() } }
                    )
                    .padding(.top, 28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .fiScreenBackground()
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

    // MARK: - Función para guardar en el backend
    private func save() async {
        isSaving = true
        errorMessage = nil
        
        do {
            // 1. Llamamos al endpoint PUT /api/clientes/:id (en el ProfileService)
            let updated = try await ProfileService.shared.updateProfile(
                nombres: firstName,
                apellidos: lastName
            )
            
            // 2. Actualizamos el Store local con los datos reales que confirmó el servidor
            store.update(firstName: updated.nombres, lastName: updated.apellidos)
            
            if didChangePhoto {
                store.setPhoto(photo) // La foto aún no tiene endpoint, se guarda local
            }
            
            // 3. Cerramos la pantalla y volvemos al perfil
            router.pop()
        } catch {
            // 4. Si el servidor falla, mostramos el error en rojo
            errorMessage = error.localizedDescription
        }
        
        isSaving = false
    }
}

#Preview {
    EditProfileView()
        .environment(AppRouter())
        .environment(ProfileStore())
}
