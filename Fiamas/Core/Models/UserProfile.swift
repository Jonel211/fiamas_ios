import Foundation

struct UserProfile: Codable, Equatable {
    var firstName: String
    var lastName: String
    var phone: String

    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    /// Iniciales para el avatar cuando no hay foto (ej. "MG").
    var initials: String {
        let letters = [firstName, lastName].compactMap { $0.trimmingCharacters(in: .whitespaces).first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }
}
