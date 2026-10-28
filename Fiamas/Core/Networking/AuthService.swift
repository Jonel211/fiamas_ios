import Foundation

struct PreRegistroResponse: Decodable {
    let encontrado: Bool
    let yaRegistrado: Bool?
    let nombres: String?
    let apellidos: String?
}

struct RegistroClienteResponse: Decodable {
    let msg: String
}

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    func login(identificador: String, password: String, rol: String) async throws -> LoginResponse {
        let body: [String: Any] = [
            "identificador": identificador,
            "password": password,
            "rol": rol
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        let response: LoginResponse = try await APIClient.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: jsonData,
            requiresAuth: false
        )
        
        // Guardamos el token y datos básicos
        UserDefaults.standard.set(response.token, forKey: "auth_token")
        UserDefaults.standard.set(response.usuario.id, forKey: "user_id")
        UserDefaults.standard.set(response.usuario.rol, forKey: "user_rol")
        
        // NUEVO: Guardamos el nombre y teléfono reales para el ProfileStore
        // El backend devuelve "Cliente Prueba" en "nombre", lo separamos
        let nombreCompleto = response.usuario.nombre.components(separatedBy: " ")
        let nombres = nombreCompleto.first ?? ""
        let apellidos = nombreCompleto.dropFirst().joined(separator: " ")
        
        UserDefaults.standard.set(nombres, forKey: "user_firstname")
        UserDefaults.standard.set(apellidos, forKey: "user_lastname")
        UserDefaults.standard.set(response.usuario.telefono, forKey: "user_phone")
        
        return response
    }
    
    // Consulta pública: devuelve nombres y apellidos si el tendero ya registró este celular
    func preRegistro(telefono: String) async throws -> PreRegistroResponse {
        return try await APIClient.shared.request(
            endpoint: "/auth/register/cliente/consulta?telefono=\(telefono)",
            method: "GET",
            requiresAuth: false
        )
    }
    
    // Activa la cuenta del cliente creada por el tendero (solo celular + contraseña)
    func registro(telefono: String, password: String) async throws {
        let body: [String: Any] = [
            "telefono": telefono,
            "password": password
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        let _: RegistroClienteResponse = try await APIClient.shared.request(
            endpoint: "/auth/register/cliente",
            method: "POST",
            body: jsonData,
            requiresAuth: false
        )
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "user_rol")
        UserDefaults.standard.removeObject(forKey: "user_firstname")
        UserDefaults.standard.removeObject(forKey: "user_lastname")
        UserDefaults.standard.removeObject(forKey: "user_phone")
    }
    
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: "auth_token") != nil
    }
}
