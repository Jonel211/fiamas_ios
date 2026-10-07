import Foundation

struct Payment: Identifiable {
    let id = UUID()
    let store: String
    var concept = "Abono Víveres"
    var amount = "S/ 50.00"
    var time = "4:15 pm"
    var method = "Efectivo"
}

/// Pagos agrupados por fecha (ej. "Hoy", "06 de sep 2026").
struct PaymentGroup: Identifiable {
    let id = UUID()
    let title: String
    /// Mes al que pertenece (ej. "septiembre 2026")
    var month: String
    let payments: [Payment]
}
