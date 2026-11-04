import Foundation

struct ClientSummaryResponse: Decodable {
    let resumenGlobal: ResumenGlobal
    let detallePorTienda: [StoreSummary]
}

struct ResumenGlobal: Decodable {
    let saldoTotalPendiente: Double

    private enum CodingKeys: String, CodingKey { case saldoTotalPendiente }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        saldoTotalPendiente = try values.decodeMoney(forKey: .saldoTotalPendiente)
    }
}

struct StoreSummary: Decodable {
    let tienda: TiendaInfo
    let limiteCredito: Double
    let saldoActual: Double
    let scorePagador: Int?
    let categoriaPagador: String

    private enum CodingKeys: String, CodingKey {
        case tienda, limiteCredito, saldoActual, scorePagador, categoriaPagador
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tienda = try values.decode(TiendaInfo.self, forKey: .tienda)
        limiteCredito = try values.decodeMoney(forKey: .limiteCredito)
        saldoActual = try values.decodeMoney(forKey: .saldoActual)
        scorePagador = try values.decodeIfPresent(Int.self, forKey: .scorePagador)
        categoriaPagador = try values.decode(String.self, forKey: .categoriaPagador)
    }
}

private extension KeyedDecodingContainer {
    func decodeMoney(forKey key: Key) throws -> Double {
        if let value = try? decode(Double.self, forKey: key) { return value }
        if let value = try? decode(String.self, forKey: key), let number = Double(value) { return number }
        throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Importe inválido")
    }
}

class SummaryService {
    static let shared = SummaryService()
    private init() {}

    func fetchMySummary() async throws -> (score: Int?, category: String, totalOwed: Double, stores: [StoreSummary]) {
        let response: ClientSummaryResponse = try await APIClient.shared.request(endpoint: "/app-cliente/mi-resumen")
        let scores = response.detallePorTienda.compactMap(\.scorePagador)
        let score = scores.isEmpty ? nil : scores.reduce(0, +) / scores.count
        let category: String
        if let score {
            category = score >= 90 ? "Excelente pagador" : score >= 75 ? "Buen pagador"
                : score >= 50 ? "Pagador regular" : "En mora"
        } else {
            category = "Sin historial"
        }
        return (score, category, response.resumenGlobal.saldoTotalPendiente, response.detallePorTienda)
    }
}
