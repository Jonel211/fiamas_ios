import Foundation

// 1. Definición de errores de red
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
            return message
        }
    }
}

// 2. Cliente base de red
class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://fiamas-tiendas.onrender.com/api"
    
    private init() {}
    
    /// Petición genérica para JSON (GET, POST, PUT, DELETE, etc.)
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
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorDict["error"] as? String {
                throw APIError.serverError(errorMessage)
            }
            throw APIError.serverError("Error del servidor: \(httpResponse.statusCode)")
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error decodificando JSON: \(error)")
            throw APIError.decodingError
        }
    }
    
    /// Petición multipart/form-data para subir archivos e imágenes
    func uploadMultipart<T: Decodable>(
        endpoint: String,
        method: String = "PATCH",
        fileData: Data,
        fieldName: String = "foto",
        fileName: String = "avatar.jpg",
        mimeType: String = "image/jpeg"
    ) async throws -> T {
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorDict["error"] as? String {
                throw APIError.serverError(errorMessage)
            }
            throw APIError.serverError("Error del servidor: \(httpResponse.statusCode)")
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error decodificando respuesta de imagen: \(error)")
            throw APIError.decodingError
        }
    }
}
