import Foundation

// Modelo para recibir la respuesta del backend
struct ClientProfileResponse: Codable {
    let msg: String
    let cliente: ClientProfileData
}

struct ClientProfileData: Codable {
    let id: String
    let telefono: String
    let nombres: String
    let apellidos: String
    let direccion: String?
    let fotoPerfilUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, telefono, nombres, apellidos, direccion
        case fotoPerfilUrl = "foto_perfil_url"
    }
}

class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    // Función para guardar los cambios (Ahora usa la nueva ruta)
    func updateProfile(nombres: String, apellidos: String, direccion: String? = nil) async throws -> ClientProfileData {
        
        // 1. Armamos el body (sin el ID, el backend lo saca del token)
        var body: [String: Any] = [
            "nombres": nombres,
            "apellidos": apellidos
        ]
        if let direccion = direccion {
            body["direccion"] = direccion
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        // 2. Hacemos la petición al endpoint exacto para clientes
        let response: ClientProfileResponse = try await APIClient.shared.request(
            endpoint: "/app-cliente/mi-perfil",
            method: "PUT",
            body: jsonData
        )
        
        return response.cliente
    }
}
