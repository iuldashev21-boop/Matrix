import SwiftUI

extension Color {
    // Primary
    static let matrixBlack = Color(red: 13/255, green: 13/255, blue: 13/255)
    static let deepBlack = Color(red: 0, green: 0, blue: 0)
    static let matrixGreen = Color(red: 0, green: 255/255, blue: 65/255)
    static let softGreen = Color(red: 0, green: 204/255, blue: 51/255)
    static let terminalGreen = Color(red: 51/255, green: 255/255, blue: 102/255)

    // Neutrals
    static let lightGray = Color(red: 179/255, green: 179/255, blue: 179/255)
    static let mediumGray = Color(red: 102/255, green: 102/255, blue: 102/255)
    static let darkGray = Color(red: 26/255, green: 26/255, blue: 26/255)
    static let charcoal = Color(red: 45/255, green: 45/255, blue: 45/255)

    // Semantic
    static let success = Color.matrixGreen
    static let danger = Color(red: 255/255, green: 51/255, blue: 51/255)
    static let warning = Color(red: 255/255, green: 204/255, blue: 0)
    static let agentRed = Color(red: 255/255, green: 0, blue: 51/255)

    // Achievement colors
    static let matrixGold = Color(red: 255/255, green: 215/255, blue: 0)
}

