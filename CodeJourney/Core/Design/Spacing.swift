import CoreGraphics

/// Spacing steps in points. Use these names instead of typing numbers,
/// so every screen stays on the same scale.
enum CJSpace {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

/// Corner radii. Draw them with continuous corners:
/// `RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)`.
enum CJRadius {
    static let chip: CGFloat = 10
    static let button: CGFloat = 14
    static let card: CGFloat = 16
    static let sheet: CGFloat = 24
}

/// Layout rules shared by every screen.
enum CJLayout {
    /// Left and right margin on phones.
    static let sideMargin: CGFloat = 20
    /// Height of primary buttons.
    static let buttonHeight: CGFloat = 52
}
