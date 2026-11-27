import SwiftUI

/// A small link that names where a number or fact came from, such as "PayScale, 2 Nov 2026".
/// Tapping it opens the source in Safari.
struct CJSourceChip: View {
    let name: String
    let url: URL
    var date: String?

    var body: some View {
        Link(destination: url) {
            HStack(spacing: CJSpace.xxs) {
                Image(systemName: "link")
                Text(label)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(CJColor.accent)
            .padding(.horizontal, CJSpace.s)
            .frame(minHeight: 32)
            .background(
                CJColor.accentSoft,
                in: RoundedRectangle(cornerRadius: CJRadius.chip, style: .continuous)
            )
        }
        .accessibilityLabel("Source: \(label)")
        .accessibilityHint("Opens in Safari")
    }

    private var label: String {
        if let date {
            return "\(name), \(date)"
        }
        return name
    }
}

#Preview("Light") {
    sourcePreview
}

#Preview("Dark") {
    sourcePreview
        .preferredColorScheme(.dark)
}

private var sourcePreview: some View {
    VStack(alignment: .leading, spacing: CJSpace.m) {
        CJSourceChip(name: "PayScale", url: URL(string: "https://www.payscale.com")!, date: "7 Jul 2026")
        CJSourceChip(name: "Stack Overflow Survey", url: URL(string: "https://survey.stackoverflow.co")!)
    }
    .padding(CJSpace.l)
    .background(CJColor.canvas)
}
