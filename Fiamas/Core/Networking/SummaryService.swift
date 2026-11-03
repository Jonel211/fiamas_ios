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
}

struct ResumenGlobal: Decodable {
    let totalTiendas: Int?
    let saldoTotalPendiente: Double?
    let limiteCreditoTotal: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalTiendas = "total_tiendas"
        case saldoTotalPendiente = "saldo_total_pendiente"
        case limiteCreditoTotal = "limite_credito_total"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalTiendas = try? container.decode(Int.self, forKey: .totalTiendas)
        
        if let val = try? container.decode(Double.self, forKey: .saldoTotalPendiente) {
            saldoTotalPendiente = val
        } else if let val = try? container.decode(Int.self, forKey: .saldoTotalPendiente) {
            saldoTotalPendiente = Double(val)
        } else if let str = try? container.decode(String.self, forKey: .saldoTotalPendiente), let val = Double(str) {
            saldoTotalPendiente = val
        } else {
            saldoTotalPendiente = 0.0
        }
        
        if let val = try? container.decode(Double.self, forKey: .limiteCreditoTotal) {
            limiteCreditoTotal = val
        } else if let val = try? container.decode(Int.self, forKey: .limiteCreditoTotal) {
            limiteCreditoTotal = Double(val)
        } else if let str = try? container.decode(String.self, forKey: .limiteCreditoTotal), let val = Double(str) {
            limiteCreditoTotal = val
        } else {
            limiteCreditoTotal = 0.0
        }
    }
}

struct StoreSummary: Decodable, Identifiable {
    var id: String { tienda?.id ?? UUID().uuidString }
    let tienda: TiendaInfo?
    let limiteCredito: Double?
    let saldoActual: Double?
    let scorePagador: Int?
    let categoriaPagador: String?
    
    enum CodingKeys: String, CodingKey {
        case tienda
        case limiteCredito = "limite_credito"
        case saldoActual = "saldo_actual"
        case scorePagador = "score_pagador"
        case categoriaPagador = "categoria_pagador"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tienda = try? container.decode(TiendaInfo.self, forKey: .tienda)
        
        if let val = try? container.decode(Double.self, forKey: .limiteCredito) {
            limiteCredito = val
        } else if let val = try? container.decode(Int.self, forKey: .limiteCredito) {
            limiteCredito = Double(val)
        } else if let str = try? container.decode(String.self, forKey: .limiteCredito), let val = Double(str) {
            limiteCredito = val
        } else {
            limiteCredito = 0.0
        }
        
        if let val = try? container.decode(Double.self, forKey: .saldoActual) {
            saldoActual = val
        } else if let val = try? container.decode(Int.self, forKey: .saldoActual) {
            saldoActual = Double(val)
        } else if let str = try? container.decode(String.self, forKey: .saldoActual), let val = Double(str) {
            saldoActual = val
        } else {
            saldoActual = 0.0
        }
        
        if let val = try? container.decode(Int.self, forKey: .scorePagador) {
            scorePagador = val
        } else if let str = try? container.decode(String.self, forKey: .scorePagador), let val = Int(str) {
            scorePagador = val
        } else {
            scorePagador = 100
        }
        
        categoriaPagador = try? container.decode(String.self, forKey: .categoriaPagador)
    }
}

class SummaryService {
    static let shared = SummaryService()
    private init() {}
    
    func fetchMySummary() async throws -> (score: Int, category: String, totalOwed: Double) {
        guard let url = URL(string: "https://fiamas-tiendas.onrender.com/api/app-cliente/mi-resumen") else {
            throw URLError(.badURL)
        }
        
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            throw URLError(.userAuthenticationRequired)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ClientSummaryResponse.self, from: data)
        let stores = decoded.detallePorTienda ?? []
        let totalOwed = decoded.resumenGlobal?.saldoTotalPendiente ?? 0.0
        
        if !stores.isEmpty {
            let validScores = stores.compactMap { $0.scorePagador }
            let avgScore = validScores.isEmpty ? 100 : (validScores.reduce(0, +) / validScores.count)
            let topCategory = stores.first?.categoriaPagador ?? "bueno"
            return (avgScore, topCategory, totalOwed)
        }
        
        return (100, "nuevo", totalOwed)
    }
}

