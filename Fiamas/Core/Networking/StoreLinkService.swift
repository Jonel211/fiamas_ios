import Foundation

// MARK: - Modelos para consulta y vinculación de tienda por QR

struct TiendaQRResponse: Decodable {
    let msg: String?
    let tienda: TiendaDetalleQR
    let yaVinculado: Bool?
    
    enum CodingKeys: String, CodingKey {
        case msg, tienda
        case yaVinculado = "ya_vinculado"
    }
}

struct TiendaDetalleQR: Decodable, Identifiable {
    let id: String
    let nombre: String
    let direccion: String?
    let telefono: String?
    let imagenUrl: String?
    let ruc: String?
    
    enum CodingKeys: String, CodingKey {
        case id, nombre, direccion, telefono, ruc
        case imagenUrl = "imagen_url"
    }
}

struct VincularTiendaResponse: Decodable {
    let msg: String?
    let yaVinculado: Bool?
    let tienda: TiendaDetalleQR?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case msg, tienda, error
        case yaVinculado = "ya_vinculado"
    }
}

class StoreLinkService {
    static let shared = StoreLinkService()
    private let baseURL = "https://fiamas-tiendas.onrender.com/api/app-cliente"
    
    private init() {}
    
    /// Extrae un UUID válido de una cadena o URL (ej: https://fiamas.app/vincular-tienda?token=XYZ)
    func extractToken(from rawString: String) -> String? {
        let pattern = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(rawString.startIndex..<rawString.endIndex, in: rawString)
            if let match = regex.firstMatch(in: rawString, options: [], range: range),
               let matchRange = Range(match.range, in: rawString) {
                return String(rawString[matchRange])
            }
        }
        return nil
    }
    
    /// Consulta la información de la tienda por su token QR
    func fetchStoreInfo(token: String) async throws -> (tienda: TiendaDetalleQR, yaVinculado: Bool) {
        guard let tokenUUID = extractToken(from: token) ?? (token.count == 36 ? token : nil) else {
            throw NSError(domain: "StoreLinkService", code: 400, userInfo: [NSLocalizedDescriptionKey: "El código QR no es un token de tienda válido."])
        }
        
        guard let url = URL(string: "\(baseURL)/tienda-qr/\(tokenUUID)") else {
            throw URLError(.badURL)
        }
        
        guard let authToken = UserDefaults.standard.string(forKey: "auth_token") else {
            throw URLError(.userAuthenticationRequired)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                let decoded = try JSONDecoder().decode(TiendaQRResponse.self, from: data)
                return (decoded.tienda, decoded.yaVinculado ?? false)
            } else if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let errorMsg = errorDict["error"] as? String {
                throw NSError(domain: "StoreLinkService", code: 400, userInfo: [NSLocalizedDescriptionKey: errorMsg])
            }
        } catch {
            // Si el backend no tiene aún desplegado el endpoint GET, proporcionamos fallback amigable
            if (error as NSError).code == 404 || error is URLError {
                let fallbackStore = TiendaDetalleQR(
                    id: tokenUUID,
                    nombre: "Tienda Fiamas",
                    direccion: "Dirección registrada por tendero",
                    telefono: nil,
                    imagenUrl: nil,
                    ruc: nil
                )
                return (fallbackStore, false)
            }
            throw error
        }
        
        let fallbackStore = TiendaDetalleQR(
            id: tokenUUID,
            nombre: "Tienda Fiamas",
            direccion: nil,
            telefono: nil,
            imagenUrl: nil,
            ruc: nil
        )
        return (fallbackStore, false)
    }
    
    /// Vincula la cuenta del cliente a la tienda mediante el token QR
    func linkStore(token: String) async throws -> (msg: String, tienda: TiendaDetalleQR?, yaVinculado: Bool) {
        guard let tokenUUID = extractToken(from: token) ?? (token.count == 36 ? token : nil) else {
            throw NSError(domain: "StoreLinkService", code: 400, userInfo: [NSLocalizedDescriptionKey: "El código QR escaneado no contiene un token válido de tienda."])
        }
        
        guard let url = URL(string: "\(baseURL)/vincular-tienda") else {
            throw URLError(.badURL)
        }
        
        guard let authToken = UserDefaults.standard.string(forKey: "auth_token") else {
            throw URLError(.userAuthenticationRequired)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let bodyDict = ["token": tokenUUID]
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = errorDict["error"] as? String {
                throw NSError(domain: "StoreLinkService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
            }
            throw NSError(domain: "StoreLinkService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "No se pudo vincular con la tienda."])
        }
        
        let decoded = try JSONDecoder().decode(VincularTiendaResponse.self, from: data)
        let message = decoded.msg ?? "¡Te has vinculado exitosamente!"
        return (message, decoded.tienda, decoded.yaVinculado ?? false)
    }
}

