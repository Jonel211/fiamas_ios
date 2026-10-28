import Foundation
import UIKit

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

// Modelo para respuestas genéricas con mensaje
struct SimpleResponse: Codable {
    let msg: String
}

// Modelo para la respuesta de subida de la foto de perfil
struct UploadAvatarResponse: Codable {
    let msg: String
    let fotoPerfilUrl: String?
}

class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    /// Actualiza nombres, apellidos y dirección del cliente
    func updateProfile(nombres: String, apellidos: String, direccion: String? = nil) async throws -> ClientProfileData {
        var body: [String: Any] = [
            "nombres": nombres,
            "apellidos": apellidos
        ]
        if let direccion = direccion {
            body["direccion"] = direccion
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        let response: ClientProfileResponse = try await APIClient.shared.request(
            endpoint: "/app-cliente/mi-perfil",
            method: "PUT",
            body: jsonData
        )
        
        return response.cliente
    }
    
    /// Sube la imagen seleccionada al servidor mediante multipart/form-data
    func uploadAvatar(image: UIImage) async throws -> String {
        let resizedImage = image.resized(maxDimension: 600)
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.85) else {
            throw APIError.serverError("No se pudo procesar la imagen seleccionada.")
        }
        
        let response: UploadAvatarResponse = try await APIClient.shared.uploadMultipart(
            endpoint: "/app-cliente/mi-perfil/foto",
            method: "PATCH",
            fileData: imageData,
            fieldName: "foto"
        )
        
        return response.fotoPerfilUrl ?? ""
    }

    /// Envía la petición para cambiar la contraseña o PIN
    func changePassword(currentPassword: String, newPassword: String) async throws {
        let body: [String: Any] = [
            "currentPassword": currentPassword,
            "newPassword": newPassword
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        let _: SimpleResponse = try await APIClient.shared.request(
            endpoint: "/app-cliente/cambiar-password",
            method: "PUT",
            body: jsonData
        )
    }
}
