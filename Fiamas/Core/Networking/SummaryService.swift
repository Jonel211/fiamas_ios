import Foundation

struct ClientSummaryResponse: Decodable {
    let msg: String?
    let resumenGlobal: ResumenGlobal?
    let detallePorTienda: [StoreSummary]?

    enum CodingKeys: String, CodingKey {
        case msg
        case resumenGlobal = "resumen_global"
        case detallePorTienda = "detalle_por_tienda"
    }

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        msg = try? container?.decode(String.self, forKey: .msg)
        resumenGlobal = try? container?.decode(ResumenGlobal.self, forKey: .resumenGlobal)
        detallePorTienda = try? container?.decode([StoreSummary].self, forKey: .detallePorTienda)
    }
}

struct ResumenGlobal: Decodable {
    let saldoTotalPendiente: Double
    let totalTiendas: Int?
    let limiteCreditoTotal: Double?

    private enum CodingKeys: String, CodingKey {
        case saldoTotalPendiente, totalTiendas, limiteCreditoTotal
    }

    init(saldoTotalPendiente: Double = 0.0, totalTiendas: Int? = nil, limiteCreditoTotal: Double? = nil) {
        self.saldoTotalPendiente = saldoTotalPendiente
        self.totalTiendas = totalTiendas
        self.limiteCreditoTotal = limiteCreditoTotal
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        totalTiendas = try? values.decode(Int.self, forKey: .totalTiendas)
        saldoTotalPendiente = values.decodeMoney(forKey: .saldoTotalPendiente)
        limiteCreditoTotal = values.decodeMoney(forKey: .limiteCreditoTotal)
    }
}

struct StoreSummary: Decodable, Identifiable {
    var id: String { tienda.id }
    let tienda: TiendaInfo
    let limiteCredito: Double
    let saldoActual: Double
    let scorePagador: Int?
    let categoriaPagador: String

    private enum CodingKeys: String, CodingKey {
        case tienda, limiteCredito, saldoActual, scorePagador, categoriaPagador
    }

    init(
        tienda: TiendaInfo,
        limiteCredito: Double = 1000.0,
        saldoActual: Double = 0.0,
        scorePagador: Int? = 100,
        categoriaPagador: String = "nuevo"
    ) {
        self.tienda = tienda
        self.limiteCredito = limiteCredito
        self.saldoActual = saldoActual
        self.scorePagador = scorePagador
        self.categoriaPagador = categoriaPagador
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tienda = (try? values.decode(TiendaInfo.self, forKey: .tienda)) ?? TiendaInfo(id: UUID().uuidString, nombre: "Tienda")
        limiteCredito = values.decodeMoney(forKey: .limiteCredito)
        saldoActual = values.decodeMoney(forKey: .saldoActual)
        
        if let s = try? values.decode(Int.self, forKey: .scorePagador) {
            scorePagador = s
        } else if let sStr = try? values.decode(String.self, forKey: .scorePagador), let s = Int(sStr) {
            scorePagador = s
        } else {
            scorePagador = nil
        }
        
        categoriaPagador = (try? values.decode(String.self, forKey: .categoriaPagador)) ?? "nuevo"
    }
}

private extension KeyedDecodingContainer {
    func decodeMoney(forKey key: Key) -> Double {
        if let value = try? decode(Double.self, forKey: key) { return value }
        if let value = try? decode(Int.self, forKey: key) { return Double(value) }
        if let value = try? decode(String.self, forKey: key), let number = Double(value) { return number }
        return 0.0
    }
}

class SummaryService {
    static let shared = SummaryService()
    private init() {}

    func fetchMySummary() async throws -> (score: Int?, category: String, totalOwed: Double, stores: [StoreSummary]) {
        do {
            let response: ClientSummaryResponse = try await APIClient.shared.request(endpoint: "/app-cliente/mi-resumen")
            let stores = response.detallePorTienda ?? []
            let scores = stores.compactMap(\.scorePagador)
            let score = scores.isEmpty ? nil : scores.reduce(0, +) / scores.count
            let category: String
            if let score {
                category = score >= 90 ? "Excelente pagador" : score >= 75 ? "Buen pagador"
                    : score >= 50 ? "Pagador regular" : "En mora"
            } else {
                category = stores.isEmpty ? "Sin historial" : "Nuevo cliente"
            }
            let totalOwed = response.resumenGlobal?.saldoTotalPendiente ?? stores.reduce(0.0) { $0 + $1.saldoActual }
            return (score, category, totalOwed, stores)
        } catch {
            print("SummaryService warning: \(error.localizedDescription) - usando fallback dinámico")
            return (nil, "Sin historial", 0.0, [])
        }
    }
}
