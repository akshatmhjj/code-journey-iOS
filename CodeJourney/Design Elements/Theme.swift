import SwiftUI
import UIKit

/// Code Journey brand colours, taken from the website's Tangerine theme (default).
/// Each colour adapts automatically between light and dark mode.
enum CJColor {
    /// Page background.
    static let canvas = Color(light: "#FAF3E1", dark: "#222222")
    /// Main text and lines.
    static let ink = Color(light: "#222222", dark: "#FAF3E1")
    /// Card and surface background.
    static let support = Color(light: "#F5E7C6", dark: "#302E2D")
    /// Brand orange. Use as a fill or highlight, not for small text.
    static let accent = Color(light: "#FF6D1F", dark: "#FF6D1F")
    /// Text placed on top of the accent colour.
    static let onAccent = Color(light: "#222222", dark: "#222222")
    /// Secondary text (the website's "muted" tone).
    static let muted = Color(light: "#222222", dark: "#FAF3E1").opacity(0.84)
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
    /// Builds a colour from a hex string such as "#FF6D1F".
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
