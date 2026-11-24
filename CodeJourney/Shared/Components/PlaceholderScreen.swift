import SwiftUI

/// A simple Ascent-coloured screen used until a feature gets its real content.
struct PlaceholderScreen: View {
    let title: String
    let message: String

    var body: some View {
        ZStack {
            CJColor.canvas
                .ignoresSafeArea()

            Text(message)
                .font(CJFont.body)
                .foregroundStyle(CJColor.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(CJSpace.xl)
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        PlaceholderScreen(title: "Preview", message: "Placeholder message.")
    }
}
