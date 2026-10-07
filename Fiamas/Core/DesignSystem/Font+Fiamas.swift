import CoreText
import SwiftUI

extension Font {
    /// Poppins (la tipografía de los diseños), incluida en Resources/Fonts.
    static func poppins(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        FontRegistrar.registerIfNeeded()
        let name: String
        switch weight {
        case .bold, .heavy, .black: name = "Poppins-Bold"
        case .semibold: name = "Poppins-SemiBold"
        case .medium: name = "Poppins-Medium"
        default: name = "Poppins-Regular"
        }
        return .custom(name, fixedSize: size)
    }
}

/// Registra las fuentes incluidas en la app (no hace falta declararlas en Info.plist).
enum FontRegistrar {
    private static let registered: Void = {
        let urls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()

    static func registerIfNeeded() {
        _ = registered
    }
}
