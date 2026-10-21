import Foundation

struct FiadosResponse: Decodable {
    let msg: String
    let total: Int
    let fiados: [FiadoAPI]
}

struct TiendaInfo: Decodable {
    let id: String
    let nombre: String
}

struct FiadoAPI: Decodable, Identifiable {
    let id: String
    let tienda: TiendaInfo?
    let montoTotal: Double
    let montoPagado: Double
    let saldoPendiente: Double
    let estado: String
    let fechaCreacion: String
    
    enum CodingKeys: String, CodingKey {
        case id, tienda, estado
        case montoTotal = "monto_total"
        case montoPagado = "monto_pagado"
        case saldoPendiente = "saldo_pendiente"
        case fechaCreacion = "fecha_creacion"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        tienda = try? container.decode(TiendaInfo.self, forKey: .tienda)
        estado = (try? container.decode(String.self, forKey: .estado)) ?? "pendiente"
        fechaCreacion = (try? container.decode(String.self, forKey: .fechaCreacion)) ?? "Sin fecha"
        
        func decodeDouble(forKey key: CodingKeys) -> Double {
            if let val = try? container.decode(Double.self, forKey: key) { return val }
            if let val = try? container.decode(Int.self, forKey: key) { return Double(val) }
            if let str = try? container.decode(String.self, forKey: key), let val = Double(str) { return val }
            return 0.0
        }
        
        montoTotal = decodeDouble(forKey: .montoTotal)
        montoPagado = decodeDouble(forKey: .montoPagado)
        saldoPendiente = decodeDouble(forKey: .saldoPendiente)
    }
}

class DebtsService {
    static let shared = DebtsService()
    private init() {}
    
    func fetchMyDebts() async throws -> [FiadoAPI] {
        guard let url = URL(string: "https://fiamas-tiendas.onrender.com/api/app-cliente/mis-fiados") else {
            throw URLError(.badURL)
        }
        
        // Usamos 'let' en lugar de 'var' para quitar el warning amarillo
        let request = URLRequest(url: url)
        
        // Arreglamos el error del token (era el causante del warning)
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            // Necesitamos una variable local para modificar los headers
            var mutableRequest = request
            mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared.data(for: mutableRequest)
            let decoded = try JSONDecoder().decode(FiadosResponse.self, from: data)
            return decoded.fiados
        } else {
            throw URLError(.userAuthenticationRequired)
        }
    }
}
