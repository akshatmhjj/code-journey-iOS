import SwiftUI

/// The Ascent button look. Use it with `.buttonStyle(.cjPrimary)` and friends.
struct CJButtonStyle: ButtonStyle {
    enum Kind {
        /// The main action on a screen. Filled with the accent colour.
        case primary
        /// A second action. Outlined.
        case secondary
        /// A quieter action. Soft accent wash.
        case tinted
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        CJButtonBody(configuration: configuration, kind: kind)
    }
}

/// Reads the environment (disabled, Reduce Motion) and draws the button.
/// SwiftUI's `ButtonStyle` cannot read the environment itself, so a small view does it.
private struct CJButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: CJButtonStyle.Kind

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: CJRadius.button, style: .continuous)

        configuration.label
            .font(CJFont.headline)
            .frame(maxWidth: .infinity, minHeight: CJLayout.buttonHeight)
            .padding(.horizontal, CJSpace.m)
            .foregroundStyle(foreground)
            .background(fill, in: shape)
            .overlay {
                if kind == .secondary {
                    shape.strokeBorder(CJColor.ink, lineWidth: 1.5)
                }
            }
            .contentShape(shape)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: configuration.isPressed)
            .opacity(isEnabled ? 1 : 0.4)
    }

    private var foreground: Color {
        switch kind {
        case .primary: CJColor.onAccent
        case .secondary: CJColor.ink
        case .tinted: CJColor.accent
        }
    }

    private var fill: Color {
        switch kind {
        case .primary: CJColor.accent
        case .secondary: .clear
        case .tinted: CJColor.accentSoft
        }
    }
}

extension ButtonStyle where Self == CJButtonStyle {
    /// `Button("Continue") { }.buttonStyle(.cjPrimary)`
    static var cjPrimary: CJButtonStyle { CJButtonStyle(kind: .primary) }
    /// `Button("Not now") { }.buttonStyle(.cjSecondary)`
    static var cjSecondary: CJButtonStyle { CJButtonStyle(kind: .secondary) }
    /// `Button("Save") { }.buttonStyle(.cjTinted)`
    static var cjTinted: CJButtonStyle { CJButtonStyle(kind: .tinted) }
}

#Preview("Light") {
    buttonPreview
}

#Preview("Dark") {
    buttonPreview
        .preferredColorScheme(.dark)
}

private var buttonPreview: some View {
    VStack(spacing: CJSpace.m) {
        Button("Continue") {}.buttonStyle(.cjPrimary)
        Button("Not now") {}.buttonStyle(.cjSecondary)
        Button("Save for later") {}.buttonStyle(.cjTinted)
        Button("Disabled") {}.buttonStyle(.cjPrimary).disabled(true)
    }
    .padding(CJSpace.l)
    .background(CJColor.canvas)
}
