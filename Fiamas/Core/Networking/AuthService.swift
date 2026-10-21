import Foundation

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
