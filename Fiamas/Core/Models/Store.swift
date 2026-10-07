import Foundation

struct Store: Identifiable {
    let id = UUID()
    let name: String
    var description: String
    /// Fecha del último movimiento
    var date: String
    /// Crédito usado en soles
    var used: Int
    /// Límite de crédito en soles
    var limit: Int

    /// Nombre sin el prefijo "Tienda - " (ej. "Juancito").
    var shortName: String {
        name.replacingOccurrences(of: "Tienda - ", with: "")
    }
}
