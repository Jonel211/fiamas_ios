import Foundation
import FirebaseAuth
import SwiftUI

@Observable
class PhoneAuthViewModel {
    var phone: String = ""
    var verificationID: String? = UserDefaults.standard.string(forKey: "authVerificationID")
    var errorMessage: String = ""
    var isLoading: Bool = false

    /// Envía el código de verificación SMS usando callbacks para evitar el fallo interno del SDK
    func sendVerificationCode(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        let cleanPhone = phone.filter(\.isNumber)
        let formattedPhone = phone.hasPrefix("+") ? phone : "+51\(cleanPhone)"
        
        // Llamada usando el bloque de completado tradicional (Objective-C bridge)
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
    
    /// Verifica el código OTP de 6 dígitos ingresado por el usuario
    func verifyCode(otpCode: String, completion: @escaping (Bool) -> Void) {
        guard let verificationID = verificationID else {
            errorMessage = "No se encontró el ID de verificación. Solicita el código nuevamente."
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
}
