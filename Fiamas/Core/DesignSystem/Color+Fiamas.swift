import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    // MARK: Marca (tomados de los diseños de Figma)

    /// Azul marino del logo FIAMAS
    static let fiNavy = Color(hex: 0x263650)
    /// Verde azulado principal: barras, botones y acentos
    static let fiTeal = Color(hex: 0x47908F)
    /// Verde azulado oscuro: degradados y avatar
    static let fiTealDark = Color(hex: 0x2B6665)
    /// Fondo suave para íconos y etiquetas verdes
    static let fiTealSoft = Color(hex: 0xE8F2F1)
    /// Dorado: acción principal (Registrarme, Guardar, Cerrar sesión)
    static let fiGold = Color(hex: 0xD7AA4E)
    static let fiGoldSoft = Color(hex: 0xFBF3E3)
    /// Celeste de las pantallas de acceso
    static let fiSky = Color(hex: 0xBAD7F0)
    static let fiSkySoft = Color(hex: 0xEAF3FB)

    // MARK: Neutros

    /// Fondo de las pantallas con tarjetas
    static let fiCanvas = Color(hex: 0xF4F6F8)
    static let fiBorder = Color(hex: 0xDDE3E8)
    static let fiDivider = Color(hex: 0xEEF1F4)
    static let fiTextPrimary = Color(hex: 0x1F2937)
    static let fiTextSecondary = Color(hex: 0x6B7280)
    static let fiTextTertiary = Color(hex: 0x9CA3AF)

    // MARK: Estados

    static let fiDanger = Color(hex: 0xC0392B)
    static let fiDangerSoft = Color(hex: 0xFCE8E6)
    static let fiWarning = Color(hex: 0xB86E00)
    static let fiWarningSoft = Color(hex: 0xFDF1DC)
}
