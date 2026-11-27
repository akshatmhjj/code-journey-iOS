import SwiftUI

/// A heading with an optional small label above it, such as "STAGE 2" over "Core".
struct CJSectionHeader: View {
    var eyebrow: String?
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.xxs) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(CJFont.caption)
                    .tracking(0.6)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            Text(title)
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Light") {
    headerPreview
}

#Preview("Dark") {
    headerPreview
        .preferredColorScheme(.dark)
}

private var headerPreview: some View {
    VStack(alignment: .leading, spacing: CJSpace.xl) {
        CJSectionHeader(eyebrow: "Stage 2 of 4", title: "Core")
        CJSectionHeader(title: "Saved resources")
    }
    .padding(CJSpace.l)
    .background(CJColor.canvas)
}
