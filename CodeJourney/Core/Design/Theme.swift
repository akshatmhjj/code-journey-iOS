import SwiftUI
import UIKit

/// Ascent colours. Each one switches between a light and a dark value automatically.
/// Change a hex value here and the whole app follows.
enum CJColor {
    /// Screen background.
    static let canvas = Color(light: "#F6F6F3", dark: "#0D0E11")
    /// Cards and grouped rows.
    static let surface = Color(light: "#FFFFFF", dark: "#17191E")
    /// Sheets and pressed cards.
    static let surfaceRaised = Color(light: "#EEEEEA", dark: "#21242B")
    /// Primary text.
    static let ink = Color(light: "#15171C", dark: "#F2F3F5")
    /// Secondary text. Passes 4.5:1 contrast on the canvas and the surface.
    static let inkSecondary = Color(light: "#5A5F6B", dark: "#A3A8B3")
    /// Iris: primary actions, links and the current step.
    static let accent = Color(light: "#4A46D6", dark: "#9B98FF")
    /// Text and icons placed on top of the accent colour.
    static let onAccent = Color(light: "#FFFFFF", dark: "#0D0E11")
    /// A faint accent wash for selected chips and the current step.
    static var accentSoft: Color { accent.opacity(0.14) }
    /// Done steps and "you have".
    static let success = Color(light: "#16855A", dark: "#45C98E")
    /// Streak at risk and approximate results.
    static let warning = Color(light: "#A65F00", dark: "#F2A93B")
    /// Destructive actions and errors.
    static let critical = Color(light: "#C9302C", dark: "#FF7A73")
    /// Thin dividers and outlines.
    static var hairline: Color { ink.opacity(0.10) }
}

extension Color {
    /// A colour that switches between a light and a dark hex value.
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }
}

extension UIColor {
    /// Builds a colour from a hex string such as "#4A46D6".
    convenience init(hex: String) {
        let cleaned = hex.replacingOccurrences(of: "#", with: "")
        let value = UInt64(cleaned, radix: 16) ?? 0
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
