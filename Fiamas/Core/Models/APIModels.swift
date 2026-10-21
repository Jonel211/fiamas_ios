import Foundation

// MARK: - Respuesta del Login
struct LoginResponse: Codable {
    let msg: String
    let token: String
    let usuario: UserAPI
}

// MARK: - Datos del Usuario (tal cual los devuelve el backend)
struct UserAPI: Codable {
    let id: String
    let nombre: String
    let telefono: String
    let rol: String
    let tiendaId: String?
    
    // Esto mapea "tienda_id" del JSON a "tiendaId" en Swift
    enum CodingKeys: String, CodingKey {
        case id, nombre, telefono, rol
        case tiendaId = "tienda_id"
    }
}
