import Foundation

struct Store: Identifiable {
    var id = UUID().uuidString
    let name: String
    var description: String
    /// Fecha del último movimiento
    var date: String
    /// Crédito usado en soles
    var used: Double
    /// Límite de crédito en soles
    var limit: Double

    /// Nombre sin el prefijo "Tienda - " (ej. "Juancito").
    var shortName: String {
        name.replacingOccurrences(of: "Tienda - ", with: "")
    }
}
