import SwiftUI
import UIKit

@Observable
final class ProfileStore {
    private(set) var profile: UserProfile
    private(set) var photo: UIImage?

    private let defaults: UserDefaults
    private let photoURL: URL
    private static let profileKey = "userProfile"

    init(defaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.defaults = defaults

        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        photoURL = directory.appendingPathComponent("profile-photo.jpg")

        // 1. Intentamos leer el perfil guardado previamente
        if let data = defaults.data(forKey: Self.profileKey),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = saved
        }
        // 2. Si no hay, lo creamos con los datos REALES del Login
        else {
            let savedFirstName = defaults.string(forKey: "user_firstname") ?? ""
            let savedLastName = defaults.string(forKey: "user_lastname") ?? ""
            let savedPhone = defaults.string(forKey: "user_phone") ?? ""
            
            // Si el login guardó datos, los usa. Si no, usa el sample.
            if !savedFirstName.isEmpty {
                profile = UserProfile(firstName: savedFirstName, lastName: savedLastName, phone: savedPhone)
            } else {
                profile = .sample
            }
        }
        photo = UIImage(contentsOfFile: photoURL.path)
    }

    func update(firstName: String, lastName: String) {
        profile.firstName = firstName.trimmingCharacters(in: .whitespaces)
        profile.lastName = lastName.trimmingCharacters(in: .whitespaces)
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: Self.profileKey)
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
}
