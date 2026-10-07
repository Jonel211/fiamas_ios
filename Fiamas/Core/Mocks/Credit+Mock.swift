import Foundation

extension Credit {
    /// Fiados de ejemplo por tienda
    static let samples: [String: [Credit]] = [
        "Tienda - Juancito": [
            Credit(amount: "S/ 38.00", items: "Manteca, Fideos, Galletas Soda, Jabón de barra",
                   date: "10 sep 2024", status: .overdue, footnote: "Vencido hace 3 días"),
            Credit(amount: "S/ 140.00", items: "Generales X, Y, Z, Canastos sin stock, Preparación…",
                   date: "19 ago 2024", status: .pending, footnote: "Pagado: S/ 140.00"),
        ],
        "Tienda - Plasencia": [
            Credit(amount: "S/ 25.50", items: "Arroz 5 kg, Aceite 1 L, Azúcar rubia",
                   date: "05 sep 2024", status: .overdue, footnote: "Vencido hace 8 días"),
            Credit(amount: "S/ 62.00", items: "Leche evaporada x6, Atún, Pan de molde, Huevos",
                   date: "12 sep 2024", status: .pending, footnote: "Pagado: S/ 20.00"),
        ],
        "Tienda - Hector": [
            Credit(amount: "S/ 18.90", items: "Detergente, Papel higiénico x4, Lejía",
                   date: "11 sep 2024", status: .pending, footnote: "Pagado: S/ 0.00"),
        ],
    ]
}
