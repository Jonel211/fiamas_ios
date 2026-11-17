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

final class StoreLinkService: Sendable {
    static let shared = StoreLinkService()
    private let baseURL = "https://fiamas-tiendas.onrender.com/api/app-cliente"

    private init() {}

    /// Extrae y valida un UUID v4 desde un texto o URL (ej. https://fiamas.app/vincular-tienda?token=XYZ)
    func extractToken(from rawString: String) -> String? {
        let trimmed = rawString.trimmingCharacters(in: .whitespacesAndNewlines)
        if let directUUID = UUID(uuidString: trimmed) {
            return directUUID.uuidString.lowercased()
        }

        let pattern = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
        guard let match = regex.firstMatch(in: trimmed, options: [], range: range),
              let matchRange = Range(match.range, in: trimmed),
              let validUUID = UUID(uuidString: String(trimmed[matchRange])) else {
            return nil
        }
        return validUUID.uuidString.lowercased()
    }

    /// Consulta la información de la tienda por su token QR
    func fetchStoreInfo(token: String) async throws -> (tienda: TiendaDetalleQR, yaVinculado: Bool) {
        guard let tokenUUID = extractToken(from: token) else {
            throw serviceError(code: 400, message: "El código QR no contiene un token de tienda válido.")
        }

        let request = try makeAuthorizedRequest(path: "/tienda-qr/\(tokenUUID)", method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let msg = parseBackendError(from: data) ?? "No se pudo verificar la tienda (Error \(httpResponse.statusCode))."
            throw serviceError(code: httpResponse.statusCode, message: msg)
        }

        let decoded = try JSONDecoder().decode(TiendaQRResponse.self, from: data)
        return (decoded.tienda, decoded.yaVinculado ?? false)
    }

    /// Vincula la cuenta del cliente a la tienda mediante el token QR
    func linkStore(token: String) async throws -> (msg: String, tienda: TiendaDetalleQR?, yaVinculado: Bool) {
        guard let tokenUUID = extractToken(from: token) else {
            throw serviceError(code: 400, message: "El código QR escaneado no contiene un token válido de tienda.")
        }

        var request = try makeAuthorizedRequest(path: "/vincular-tienda", method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["token": tokenUUID])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let msg = parseBackendError(from: data) ?? "No se pudo vincular con la tienda."
            throw serviceError(code: httpResponse.statusCode, message: msg)
        }

        let decoded = try JSONDecoder().decode(VincularTiendaResponse.self, from: data)
        let message = decoded.msg ?? "¡Te has vinculado exitosamente!"
        return (message, decoded.tienda, decoded.yaVinculado ?? false)
    }

    // MARK: - Helpers

    private func makeAuthorizedRequest(path: String, method: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }
        guard let authToken = UserDefaults.standard.string(forKey: "auth_token"), !authToken.isEmpty else {
            throw URLError(.userAuthenticationRequired)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func parseBackendError(from data: Data) -> String? {
        guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return (dict["error"] as? String) ?? (dict["msg"] as? String)
    }

    private func serviceError(code: Int, message: String) -> NSError {
        NSError(domain: "StoreLinkService", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
