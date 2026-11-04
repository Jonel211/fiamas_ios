import Foundation
import UserNotifications

struct PreRegistroResponse: Decodable {
    let encontrado: Bool
    let yaRegistrado: Bool?
    let nombres: String?
    let apellidos: String?
    let direccion: String?
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
    
    // Sin QR activa la cuenta pre-registrada; con QR registra y vincula a la tienda.
    func registro(telefono: String, password: String, direccion: String, nombres: String? = nil, apellidos: String? = nil, qrCode: String? = nil) async throws {
        var body: [String: Any] = [
            "telefono": telefono,
            "password": password,
            "direccion": direccion.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        if let qrCode {
            let token = URLComponents(string: qrCode)?.queryItems?.first(where: { $0.name == "token" })?.value ?? qrCode
            body["nombres"] = nombres?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            body["apellidos"] = apellidos?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            body["token"] = token
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        let _: RegistroClienteResponse = try await APIClient.shared.request(
            endpoint: "/auth/register/cliente",
            method: "POST",
            body: jsonData,
            requiresAuth: false
        )
    }
    
    func logout() {
        Task {
            let center = UNUserNotificationCenter.current()
            let ids = await center.pendingNotificationRequests().map(\.identifier)
                .filter { $0.hasPrefix("fiamas-fiado-") }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
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
