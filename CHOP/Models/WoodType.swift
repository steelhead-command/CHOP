import SwiftUI

enum WoodType: String, Codable, CaseIterable {
    case soft
    case medium
    case hard

    // MARK: - Points & Economy

    var basePoints: Int {
        switch self {
        case .soft: return 10
        case .medium: return 15
        case .hard: return 25
        }
    }

    var sellPrice: Int {
        switch self {
        case .soft: return 2
        case .medium: return 4
        case .hard: return 8
        }
    }

    var knotBonus: Int {
        switch self {
        case .hard: return 25
        default: return 0
        }
    }

    // MARK: - Visual Properties

    var color: Color {
        switch self {
        case .soft: return Color(hex: "A67C52")
        case .medium: return Color(hex: "8B6914")
        case .hard: return Color(hex: "5C4612")
        }
    }

    var grainColor: Color {
        switch self {
        case .soft: return Color(hex: "C4A074")   // Lighter pine grain
        case .medium: return Color(hex: "A68B2E") // Golden oak grain
        case .hard: return Color(hex: "7A5C1A")   // Rich walnut grain
        }
    }

    var barkColor: Color {
        switch self {
        case .soft: return Color(hex: "6B4D32")   // Light bark
        case .medium: return Color(hex: "5A4210") // Medium bark
        case .hard: return Color(hex: "3D2E0D")   // Dark bark
        }
    }

    /// Burn time in minutes (for display)
    var burnTimeMinutes: Int {
        Int(burnTime / 60)
    }

    var displayName: String {
        switch self {
        case .soft: return "Soft Wood"
        case .medium: return "Medium Wood"
        case .hard: return "Hard Wood"
        }
    }

    // MARK: - Burn Properties

    var burnTime: TimeInterval {
        switch self {
        case .soft: return 15 * 60      // 15 minutes
        case .medium: return 25 * 60    // 25 minutes
        case .hard: return 45 * 60      // 45 minutes
        }
    }

    var temperatureContribution: Int {
        switch self {
        case .soft: return 200      // Warm
        case .medium: return 400    // Hot
        case .hard: return 600      // Very hot
        }
    }
}
