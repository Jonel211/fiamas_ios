import Foundation

// Estructura para leer el JSON exacto del backend
struct PaymentsResponse: Decodable {
    let msg: String?
    let total_pagos: Int?
    let total_pagado: Double?
    let pagos: [PaymentAPI]
    
    enum CodingKeys: String, CodingKey {
        case msg
        case total_pagos
        case total_pagado
        case pagos
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        
        if let count = try? container.decode(Int.self, forKey: .total_pagos) {
            total_pagos = count
        } else if let str = try? container.decode(String.self, forKey: .total_pagos), let count = Int(str) {
            total_pagos = count
        } else {
            total_pagos = nil
        }
        
        if let val = try? container.decode(Double.self, forKey: .total_pagado) {
            total_pagado = val
        } else if let val = try? container.decode(Int.self, forKey: .total_pagado) {
            total_pagado = Double(val)
        } else if let str = try? container.decode(String.self, forKey: .total_pagado), let val = Double(str) {
            total_pagado = val
        } else {
            total_pagado = 0.0
        }
        
        pagos = (try? container.decode([PaymentAPI].self, forKey: .pagos)) ?? []
    }
}

struct PaymentAPI: Decodable, Identifiable {
    let id: String
    let monto: Double
    let fecha_pago: String
    let metodo_pago: String
    let referencia: String?
    let notas: String?
    let fiado: FiadoInfo?
    
    struct FiadoInfo: Decodable {
        let id: String
        let monto_total: Double
        let estado: String
        let tienda: TiendaInfo?
        
        enum CodingKeys: String, CodingKey {
            case id
            case monto_total
            case estado
            case tienda
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let strId = try? container.decode(String.self, forKey: .id) {
                id = strId
            } else if let intId = try? container.decode(Int.self, forKey: .id) {
                id = String(intId)
            } else {
                id = UUID().uuidString
            }
            
            if let val = try? container.decode(Double.self, forKey: .monto_total) {
                monto_total = val
            } else if let val = try? container.decode(Int.self, forKey: .monto_total) {
                monto_total = Double(val)
            } else if let str = try? container.decode(String.self, forKey: .monto_total), let val = Double(str) {
                monto_total = val
            } else {
                monto_total = 0.0
            }
            
            estado = (try? container.decode(String.self, forKey: .estado)) ?? "pendiente"
            tienda = try? container.decode(TiendaInfo.self, forKey: .tienda)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, monto, fecha_pago, metodo_pago, tipo_pago, referencia, notas, fiado
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let strId = try? container.decode(String.self, forKey: .id) {
            id = strId
        } else if let intId = try? container.decode(Int.self, forKey: .id) {
            id = String(intId)
        } else {
            id = UUID().uuidString
        }
        
        fecha_pago = (try? container.decode(String.self, forKey: .fecha_pago)) ?? ""
        
        if let m = try? container.decode(String.self, forKey: .metodo_pago), !m.isEmpty {
            metodo_pago = m
        } else if let t = try? container.decode(String.self, forKey: .tipo_pago), !t.isEmpty {
            metodo_pago = t
        } else {
            metodo_pago = "efectivo"
        }
        
        referencia = try? container.decode(String.self, forKey: .referencia)
        notas = try? container.decode(String.self, forKey: .notas)
        fiado = try? container.decode(FiadoInfo.self, forKey: .fiado)
        
        if let val = try? container.decode(Double.self, forKey: .monto) {
            monto = val
        } else if let val = try? container.decode(Int.self, forKey: .monto) {
            monto = Double(val)
        } else if let str = try? container.decode(String.self, forKey: .monto), let val = Double(str) {
            monto = val
        } else {
            monto = 0.0
        }
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
            
            let (data, response) = try await URLSession.shared.data(for: mutableRequest)
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMsg = errorDict["error"] as? String {
                    throw NSError(domain: "PaymentService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
                }
                throw NSError(domain: "PaymentService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error del servidor: \(httpResponse.statusCode)"])
            }
            
            let decoded = try JSONDecoder().decode(PaymentsResponse.self, from: data)
            return decoded.pagos
        } else {
            throw URLError(.userAuthenticationRequired)
        }
    }
}
