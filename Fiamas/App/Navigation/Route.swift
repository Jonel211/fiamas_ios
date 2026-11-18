import Foundation

enum Route: Hashable {
    // Autenticación
    case welcome
    case register(qrCode: String?)
    case login
    case phoneVerification
    case recoverPassword
    case verifyCode
    case newPassword
    
    // App
    case menu
    case notifications
    case creditDetail(Credit)
    case paymentDetail(Payment?)
    case changePassword
    case editProfile
    case help
    case about
    
    // Legal
    case terms
    case privacy
    
    static var paymentDetail: Route {
        .paymentDetail(nil)
    }
}
