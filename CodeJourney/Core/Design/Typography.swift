import SwiftUI

/// Ascent text styles. Every style is a built-in Dynamic Type style,
/// so text grows when the user changes their text size in Settings.
enum CJFont {
    /// Big screen titles. Rounded and bold.
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    /// Card titles and role names. Rounded and bold.
    static let title = Font.system(.title2, design: .rounded).weight(.bold)
    /// Row titles and section headings.
    static let headline = Font.headline
    /// Reading text.
    static let body = Font.body
    /// Supporting text inside cards.
    static let callout = Font.callout
    /// Small labels such as "STAGE 1". Add `.textCase(.uppercase)` where the label needs it.
    static let caption = Font.caption.weight(.semibold)
    /// Stats and pay figures. Digits line up in columns.
    static let number = Font.system(.title, design: .rounded).weight(.bold).monospacedDigit()
    /// Code samples.
    static let code = Font.body.monospaced()
}
