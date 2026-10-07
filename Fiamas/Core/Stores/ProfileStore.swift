import SwiftUI
import UIKit

/// Perfil del usuario. Guarda los datos en UserDefaults y la foto en Application Support.
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

        if let data = defaults.data(forKey: Self.profileKey),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = saved
        } else {
            profile = .sample
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
