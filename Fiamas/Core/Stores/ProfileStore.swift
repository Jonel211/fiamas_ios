import SwiftUI
 
import UIKit

@Observable
final class ProfileStore {
    private(set) var profile: UserProfile
    private(set) var photo: UIImage?
    var isUploading: Bool = false
    var errorMessage: String? = nil

    private let defaults: UserDefaults
    private let directory: URL

    init(defaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.defaults = defaults

        let dir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        directory = dir

        profile = UserProfile(firstName: "", lastName: "", phone: "")
        reload()
    }

    // Usuario con sesión activa ("guest" si no hay sesión)
    private var currentUserID: String {
        defaults.string(forKey: "user_id") ?? "guest"
    }

    private var profileKey: String { "userProfile_\(currentUserID)" }

    private var photoURL: URL {
        directory.appendingPathComponent("profile-photo-\(currentUserID).jpg")
    }

    /// Vuelve a leer el perfil y la foto del usuario actual.
    /// Llamar justo después de iniciar sesión y después de cerrar sesión.
    func reload() {
        // 1. Perfil guardado de ESTE usuario
        if let data = defaults.data(forKey: profileKey),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = saved
        }
        // 2. Si no hay, usa los datos del login guardados en UserDefaults
        else {
            let firstName = defaults.string(forKey: "user_firstname") ?? ""
            let lastName = defaults.string(forKey: "user_lastname") ?? ""
            let phone = defaults.string(forKey: "user_phone") ?? ""
            profile = UserProfile(firstName: firstName, lastName: lastName, phone: phone)
        }
        photo = UIImage(contentsOfFile: photoURL.path)
    }

    func update(firstName: String, lastName: String) {
        profile.firstName = firstName.trimmingCharacters(in: .whitespaces)
        profile.lastName = lastName.trimmingCharacters(in: .whitespaces)
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: profileKey)
        }
    }

    func setPhoto(_ image: UIImage?) {
        guard let image else {
            photo = nil
            try? FileManager.default.removeItem(at: photoURL)
            return
        }
        let resized = image.resized(maxDimension: 600)
        photo = resized
        try? resized.jpegData(compressionQuality: 0.85)?.write(to: photoURL, options: .atomic)
    }

    /// Sube la imagen usando el ProfileService del proyecto y actualiza la caché local
    @MainActor
    func uploadPhotoToBackend(_ image: UIImage) async {
        isUploading = true
        errorMessage = nil
        
        do {
            _ = try await ProfileService.shared.uploadAvatar(image: image)
            self.setPhoto(image)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isUploading = false
    }
}
