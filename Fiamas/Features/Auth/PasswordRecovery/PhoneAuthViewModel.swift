import Foundation
import FirebaseAuth
import SwiftUI

final class PhoneAuthViewModel: ObservableObject {
    @Published var phone: String = "" {
        didSet {
            let filtered = phone.filter(\.isNumber)
            if filtered.count > 9 {
                phone = String(filtered.prefix(9))
            }
        }
    }
    
    @Published var verificationID: String? = UserDefaults.standard.string(forKey: "authVerificationID")
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    @Published var newPassword: String = "" {
        didSet {
            if newPassword.count > 6 {
                newPassword = String(newPassword.prefix(6))
            }
        }
    }
    
    @Published var confirmPassword: String = "" {
        didSet {
            if confirmPassword.count > 6 {
                confirmPassword = String(confirmPassword.prefix(6))
            }
        }
    }

    func sendVerificationCode(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
         
        let cleanPhone = phone.filter(\.isNumber)
        let formattedPhone = phone.hasPrefix("+") ? phone : "+51\(cleanPhone)"
         
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true

        PhoneAuthProvider.provider().verifyPhoneNumber(formattedPhone, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                 
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                 
                guard let verificationID = verificationID else {
                    self.errorMessage = "No se pudo obtener el ID de verificación."
                    completion(false)
                    return
                }
                 
                self.verificationID = verificationID
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                completion(true)
            }
        }
    }
     
    func verifyCode(otpCode: String, completion: @escaping (Bool) -> Void) {
        guard let verificationID = verificationID else {
            errorMessage = "No se encontró el ID de verificación."
            completion(false)
            return
        }
         
        isLoading = true
        errorMessage = ""
         
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: otpCode
        )
         
        Auth.auth().signIn(with: credential) { [weak self] _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                 
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                 
                completion(true)
            }
        }
    }

    func updatePassword(completion: @escaping (Bool) -> Void) {
            guard newPassword == confirmPassword else {
                errorMessage = "Las contraseñas no coinciden."
                completion(false)
                return
            }
            
            guard newPassword.count == 6 else {
                errorMessage = "La contraseña debe tener exactamente 6 caracteres."
                completion(false)
                return
            }
            
            isLoading = true
            errorMessage = ""
            
            let cleanPhone = phone.filter(\.isNumber)
            
            guard let url = URL(string: "https://tu-api.com/api/v1/app-cliente/recuperar-password-sms") else {
                self.errorMessage = "URL de API inválida."
                self.isLoading = false
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "telefono": cleanPhone,
                "new_password": newPassword
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                self.errorMessage = "Error al empaquetar los datos."
                self.isLoading = false
                completion(false)
                return
            }
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        self.errorMessage = "El servidor rechazó la actualización de contraseña."
                        completion(false)
                        return
                    }
                    
                    // Éxito real en el backend
                    completion(true)
                }
            }.resume()
        }
}
