import Foundation

struct Payment: Identifiable, Hashable {
    let id: String
    let store: String
    var concept: String
    var amount: String
    var amountValue: Double
    var time: String
    var date: String
    var method: String
    var reference: String?
    var fiadoId: String?
    var fiadoTotal: Double?
    var fiadoEstado: String?

    init(
        id: String = UUID().uuidString,
        store: String,
        concept: String = "Abono Víveres",
        amount: String = "S/ 50.00",
        amountValue: Double = 50.0,
        time: String = "4:15 pm",
        date: String = "",
        method: String = "Efectivo",
        reference: String? = nil,
        fiadoId: String? = nil,
        fiadoTotal: Double? = nil,
        fiadoEstado: String? = nil
    ) {
        self.id = id
        self.store = store
        self.concept = concept
        self.amount = amount
        self.amountValue = amountValue
        self.time = time
        self.date = date
        self.method = method
        self.reference = reference
        self.fiadoId = fiadoId
        self.fiadoTotal = fiadoTotal
        self.fiadoEstado = fiadoEstado
    }
}

/// Pagos agrupados por fecha (ej. "Hoy", "06 de sep 2026").
struct PaymentGroup: Identifiable {
    let id = UUID()
    let title: String
    /// Mes al que pertenece (ej. "septiembre 2026")
    var month: String
    let payments: [Payment]
}
