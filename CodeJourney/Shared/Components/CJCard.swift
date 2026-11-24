import SwiftUI

/// The Ascent card: a rounded surface that holds related content.
/// Wrap any content in it: `CJCard { Text("Hello") }`.
struct CJCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(CJSpace.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                    .fill(CJColor.surface)
            )
    }
}

#Preview("Light") {
    cardPreview
}

#Preview("Dark") {
    cardPreview
        .preferredColorScheme(.dark)
}

private var cardPreview: some View {
    VStack(spacing: CJSpace.m) {
        CJCard {
            Text("Foundations")
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)
            Text("Swift, Git and the basics of networking.")
                .font(CJFont.body)
                .foregroundStyle(CJColor.inkSecondary)
        }
    }
    .padding(CJSpace.l)
    .background(CJColor.canvas)
}
