import Foundation

enum Route: Hashable {
    // Autenticación
    case login
    case phoneVerification
    case recoverPassword
    case verifyCode
    case newPassword
    // App
    case menu
    case notifications
    case paymentDetail
    case changePassword
    case help
    case complaints
}
