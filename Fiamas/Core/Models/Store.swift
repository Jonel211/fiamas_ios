import Foundation

struct Store: Identifiable {
    var id = UUID().uuidString
    let name: String
    var description: String
    var date: String
    var used: Double
    var limit: Double
    var imagenUrl: String? // <-- NUEVA PROPIEDAD

    /// Nombre sin el prefijo "Tienda - " (ej. "Juancito").
    var shortName: String {
        name.replacingOccurrences(of: "Tienda - ", with: "")
    }
}
