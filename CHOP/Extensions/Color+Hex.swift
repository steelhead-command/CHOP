import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - CHOP Brand Colors

    static let chopOrange = Color(hex: "E87C3A")
    static let forestGreen = Color(hex: "4A7C59")
    static let creamWhite = Color(hex: "F5ECD7")
    static let charcoalBrown = Color(hex: "3D3229")
    static let amberGold = Color(hex: "FFB347")

    // MARK: - UI Colors

    static let chopBackground = creamWhite
    static let chopText = charcoalBrown
    static let chopSecondaryText = Color(hex: "6B4423")
    static let chopAccent = chopOrange
    static let chopSuccess = Color(hex: "4A7C59")
    static let chopWarning = Color(hex: "DAA520")
    static let chopError = Color(hex: "C73E1D")

    // MARK: - Furnace Colors

    static let furnaceCold = Color(hex: "7D7D7D")
    static let furnaceWarm = Color(hex: "FF6B35")
    static let furnaceHot = Color(hex: "FF4500")
    static let furnaceVeryHot = Color(hex: "FFD700")

    // MARK: - Durability Colors

    static func durabilityColor(for percentage: Double) -> Color {
        switch percentage {
        case 0.5...: return .forestGreen
        case 0.25...: return .chopWarning
        default: return .chopError
        }
    }
}
