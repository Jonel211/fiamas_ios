import Foundation
import os

struct ClientSummaryResponse: Decodable {
    let resumenGlobal: ResumenGlobal
    let detallePorTienda: [StoreSummary]

    private enum CodingKeys: String, CodingKey {
        case resumenGlobal, detallePorTienda
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        resumenGlobal = try container.decode(ResumenGlobal.self, forKey: .resumenGlobal)
        detallePorTienda = (try? container.decodeIfPresent([StoreSummary].self, forKey: .detallePorTienda)) ?? []
    }
}

struct ResumenGlobal: Decodable {
    let saldoTotalPendiente: Double

    private enum CodingKeys: String, CodingKey { case saldoTotalPendiente }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        saldoTotalPendiente = values.decodeMoney(forKey: .saldoTotalPendiente)
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

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tienda = try values.decode(TiendaInfo.self, forKey: .tienda)
        limiteCredito = values.decodeMoney(forKey: .limiteCredito)
        saldoActual = values.decodeMoney(forKey: .saldoActual)

        if let s = try? values.decode(Int.self, forKey: .scorePagador) {
            scorePagador = s
        } else if let sStr = try? values.decode(String.self, forKey: .scorePagador), let s = Int(sStr) {
            scorePagador = s
        } else {
            scorePagador = nil
        }

        categoriaPagador = (try? values.decode(String.self, forKey: .categoriaPagador)) ?? "Sin historial"
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
    private let logger = Logger(subsystem: "com.fiamas", category: "Refresh")
    private init() {}

    func fetchMySummary() async throws -> (score: Int?, category: String, totalOwed: Double, stores: [StoreSummary]) {
        let response: ClientSummaryResponse
        do {
            response = try await APIClient.shared.request(
                endpoint: "/app-cliente/mi-resumen", cachePolicy: .reloadIgnoringLocalCacheData
            )
        } catch {
            if (error as? URLError)?.code == .cancelled || error is CancellationError {
                logger.debug("SummaryService: cancelled")
            } else {
                logger.error("SummaryService: \(String(describing: error), privacy: .public)")
            }
            throw error
        }
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
