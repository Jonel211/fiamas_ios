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

    /// Azul marino del logo FIAMAS
    static let fiNavy = Color(hex: 0x263650)
    /// Celeste de fondo (registro, login, resumen de cuenta)
    static let fiSky = Color(hex: 0xBAD7F0)
    /// Celeste de las pantallas de recuperar contraseña
    static let fiSkyLight = Color(hex: 0xB0D6F5)
    /// Verde azulado principal (barras, botones)
    static let fiTeal = Color(hex: 0x47908F)
    /// Verde azulado intenso (botones del flujo de recuperar contraseña)
    static let fiTealBright = Color(hex: 0x1A9090)
    /// Verde azulado oscuro (score, avatar)
    static let fiTealDark = Color(hex: 0x2B6665)
    /// Dorado (Registrarme, Cerrar sesión, pasos)
    static let fiGold = Color(hex: 0xD7AA4E)
    /// Dorado desactivado (Guardar)
    static let fiGoldLight = Color(hex: 0xEBD3A3)
    /// Dorado de las etiquetas "Abono Viveres"
    static let fiGoldChip = Color(hex: 0xE3C27E)

    static let fiFieldBorder = Color(hex: 0xC4C4C4)
    static let fiCardBorder = Color(hex: 0xCFE1F1)
    static let fiGrayText = Color(hex: 0x6B7280)
    static let fiLightGrayText = Color(hex: 0x9CA3AF)
    static let fiVerifyBackground = Color(hex: 0xF4F9F9)
    static let fiSectionBackground = Color(hex: 0xF1F8F9)
    static let fiNotificationBackground = Color(hex: 0xF3F5FC)
    static let fiProfileBackground = Color(hex: 0xF8F4FA)
    static let fiTotalBox = Color(hex: 0xD9D9D9)

    static let fiRed = Color(hex: 0xC0392B)
    static let fiRedSoft = Color(hex: 0xFADADD)
    static let fiOrange = Color(hex: 0xE07B00)
    static let fiOrangeSoft = Color(hex: 0xFDEFD3)
    static let fiGreenSoft = Color(hex: 0xE3F0EC)
    static let fiLogoutRed = Color(hex: 0xE5484D)
    static let fiAmberText = Color(hex: 0x8A5A00)

    // Textos
    static let fiTextPrimary = Color(hex: 0x1F2937)
    static let fiTextBody = Color(hex: 0x374151)
    static let fiTextSecondary = Color(hex: 0x4B5563)

    // Bordes y separadores
    /// Borde verde grisáceo de Ayuda y Reclamos
    static let fiOutline = Color(hex: 0x5E8C86)
    static let fiCardOutline = Color(hex: 0x8A9A98)
    static let fiSummaryBorder = Color(hex: 0x5D7A99)
    static let fiGoldChipBorder = Color(hex: 0xB8954A)
    static let fiNeutralBorder = Color(hex: 0xE5E7EB)
    static let fiDivider = Color(hex: 0xEBEBEB)
    static let fiChevron = Color(hex: 0xBDBDBD)
    static let fiIconBackground = Color(hex: 0xE3EEF7)
}
