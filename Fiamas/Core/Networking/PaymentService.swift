import Foundation

// Estructura para leer el JSON exacto del backend
struct PaymentsResponse: Decodable {
    let msg: String
    let total_pagos: Int
    let total_pagado: Double
    let pagos: [PaymentAPI]
}

struct PaymentAPI: Decodable, Identifiable {
    let id: String
    let monto: Double
    let fecha_pago: String
    let metodo_pago: String
    let referencia: String?
    let notas: String?
    let fiado: FiadoInfo
    
    struct FiadoInfo: Decodable {
        let id: String
        let monto_total: Double
        let estado: String
        let tienda: TiendaInfo
    }
    
    // Diccionario manual para los montos
    enum CodingKeys: String, CodingKey {
        case id, monto, fecha_pago, metodo_pago, referencia, notas, fiado
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fecha_pago = try container.decode(String.self, forKey: .fecha_pago)
        metodo_pago = try container.decode(String.self, forKey: .metodo_pago)
        referencia = try? container.decode(String.self, forKey: .referencia)
        notas = try? container.decode(String.self, forKey: .notas)
        fiado = try container.decode(FiadoInfo.self, forKey: .fiado)
        
        // Decodificación segura para los montos
        func decodeDouble(forKey key: CodingKeys) -> Double {
            if let val = try? container.decode(Double.self, forKey: key) { return val }
            if let val = try? container.decode(Int.self, forKey: key) { return Double(val) }
            if let str = try? container.decode(String.self, forKey: key), let val = Double(str) { return val }
            return 0.0
        }
        monto = decodeDouble(forKey: .monto)
    }
}

class PaymentService {
    static let shared = PaymentService()
    private init() {}
    
    func fetchMyPayments() async throws -> [PaymentAPI] {
        guard let url = URL(string: "https://fiamas-tiendas.onrender.com/api/app-cliente/mis-pagos") else {
            throw URLError(.badURL)
        }
        
        let request = URLRequest(url: url)
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            var mutableRequest = request
            mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared.data(for: mutableRequest)
            let decoded = try JSONDecoder().decode(PaymentsResponse.self, from: data)
            return decoded.pagos
        } else {
            throw URLError(.userAuthenticationRequired)
        }
    }
}
