import SwiftUI

/// A small label for filters, tags and states, such as "Free" or "You have".
struct CJChip: View {
    enum Tone {
        /// Plain chip with a thin outline.
        case neutral
        /// Filled ink. Use for the selected filter.
        case selected
        /// Soft accent wash. Use for a tag or an action.
        case accent
        /// Soft green. Use for "you have" or done.
        case success
    }

    let title: String
    var systemImage: String?
    var tone: Tone = .neutral

    var body: some View {
        HStack(spacing: CJSpace.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(foreground)
        .padding(.horizontal, CJSpace.s)
        .frame(minHeight: 32)
        .background(
            background,
            in: RoundedRectangle(cornerRadius: CJRadius.chip, style: .continuous)
        )
        .overlay {
            if tone == .neutral {
                RoundedRectangle(cornerRadius: CJRadius.chip, style: .continuous)
                    .strokeBorder(CJColor.hairline, lineWidth: 1)
            }
        }
    }

    private var foreground: Color {
        switch tone {
        case .neutral: CJColor.ink
        case .selected: CJColor.canvas
        case .accent: CJColor.accent
        case .success: CJColor.success
        }
    }

    private var background: Color {
        switch tone {
        case .neutral: CJColor.surface
        case .selected: CJColor.ink
        case .accent: CJColor.accentSoft
        case .success: CJColor.success.opacity(0.14)
        }
    }
}

#Preview("Light") {
    chipPreview
}

#Preview("Dark") {
    chipPreview
        .preferredColorScheme(.dark)
}

private var chipPreview: some View {
    VStack(alignment: .leading, spacing: CJSpace.s) {
        CJChip(title: "All")
        CJChip(title: "Docs", systemImage: "book.closed", tone: .selected)
        CJChip(title: "Free", systemImage: "gift", tone: .accent)
        CJChip(title: "You have", systemImage: "checkmark", tone: .success)
    }
    .padding(CJSpace.l)
    .background(CJColor.canvas)
}
