import Foundation

extension PaymentGroup {
    static let samples = [
        PaymentGroup(title: "Hoy", month: "septiembre 2026", payments: [
            Payment(store: "Bodega Don Pepe"),
        ]),
        PaymentGroup(title: "06 de sep 2026", month: "septiembre 2026", payments: [
            Payment(store: "Bodega Don Daniel"),
            Payment(store: "Bodega Don Alessandro"),
            Payment(store: "Bodega Don David"),
        ]),
    ]
}
