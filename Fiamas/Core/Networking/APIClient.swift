import Foundation

// 1. Definimos los errores que pueden ocurrir en la red
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La dirección del servidor es incorrecta."
        case .invalidResponse:
            return "No se pudo conectar con el servidor. Intenta de nuevo."
        case .decodingError:
            return "Hubo un problema al leer los datos del servidor."
        case .serverError(let message):
            return message // <--- ESTO hace la magia de mostrar el mensaje del backend
        }
    }
}

// 2. Creamos el cliente base
class APIClient {
    
    // ¡ATENCIÓN AQUÍ! Cambia esto por la URL de tu backend (ej: http://localhost:3000/api o la IP)
    static let shared = APIClient()
    private let baseURL = "https://fiamas-tiendas.onrender.com/api"
    
    // Función genérica para hacer peticiones GET, POST, etc.
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Si requiere autenticación, buscamos el token guardado (lo haremos en el siguiente paso)
        if requiresAuth, let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Si el servidor responde con error (400, 401, 500...)
        guard (200...299).contains(httpResponse.statusCode) else {
            // Intentamos leer el mensaje de error del backend
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorDict["error"] as? String {
                throw APIError.serverError(errorMessage)
            }
            throw APIError.serverError("Error del servidor: \(httpResponse.statusCode)")
        }
        
        do {
            let decoder = JSONDecoder()
            // Si el backend usa snake_case (ej: password_hash) y tu Swift usa camelCase (ej: passwordHash)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error decodificando: \(error)")
            throw APIError.decodingError
        }
    }
}
