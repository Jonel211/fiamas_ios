import Foundation
import Security
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
    private struct SavedCredentials: Codable {
        let phone: String
        let password: String
    }
    private let credentialAccount = "cliente-session"
    @MainActor private var refreshTask: Task<Bool, Never>?
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
        try Task.checkCancellation()
        if rol == "cliente" {
            saveCredentials(SavedCredentials(phone: identificador, password: password))
        }
        
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

    @MainActor
    func restoreSession() async -> Bool {
        if let token = UserDefaults.standard.string(forKey: "auth_token"),
           UserDefaults.standard.string(forKey: "user_rol") == "cliente",
           UserDefaults.standard.string(forKey: "user_id") != nil,
           Self.isTokenValid(token) {
            return true
        }
        guard loadCredentials() != nil else { return false }
        // No cerrar la sesión por errores temporales de red; se reintentará al pedir datos.
        let refreshed = await refreshSession()
        return refreshed || loadCredentials() != nil
    }

    @MainActor
    func refreshSession() async -> Bool {
        if let refreshTask { return await refreshTask.value }
        guard let credentials = loadCredentials() else { return false }
        let task = Task { [self] in
            do {
                _ = try await login(identificador: credentials.phone, password: credentials.password, rol: "cliente")
                return true
            } catch {
                return false
            }
        }
        refreshTask = task
        let success = await task.value
        refreshTask = nil
        return success
    }

    private static func isTokenValid(_ token: String) -> Bool {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return false }
        let payload = String(parts[1]).replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = payload.padding(toLength: ((payload.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        guard let data = Data(base64Encoded: padded),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let expiration = json["exp"] as? TimeInterval else { return false }
        return expiration > Date().addingTimeInterval(60).timeIntervalSince1970
    }

    private func loadCredentials() -> SavedCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "Fiamas",
            kSecAttrAccount as String: credentialAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(SavedCredentials.self, from: data)
    }

    private func saveCredentials(_ credentials: SavedCredentials) {
        guard let data = try? JSONEncoder().encode(credentials) else { return }
        let key: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "Fiamas",
            kSecAttrAccount as String: credentialAccount
        ]
        let update: [String: Any] = [kSecValueData as String: data]
        if SecItemUpdate(key as CFDictionary, update as CFDictionary) == errSecItemNotFound {
            var attributes = key
            attributes[kSecValueData as String] = data
            attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            SecItemAdd(attributes as CFDictionary, nil)
        }
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
    
    @MainActor
    func logout() {
        refreshTask?.cancel()
        refreshTask = nil
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "Fiamas",
            kSecAttrAccount as String: credentialAccount
        ] as CFDictionary)
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
