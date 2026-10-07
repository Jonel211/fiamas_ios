import SwiftUI
import UIKit

// Los diseños usan Poppins e Inter. Si agregas los .ttf de Poppins al proyecto
// (y los registras en Info.plist -> "Fonts provided by application"), se usarán
// automáticamente; si no, se usa la fuente del sistema con el mismo peso.
extension Font {
    static func poppins(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold, .heavy, .black: name = "Poppins-Bold"
        case .semibold: name = "Poppins-SemiBold"
        case .medium: name = "Poppins-Medium"
        default: name = "Poppins-Regular"
        }
        if UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight)
    }

    static func inter(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}
