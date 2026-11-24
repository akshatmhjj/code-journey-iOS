import SwiftUI

/// The My Path tab: the user's chosen route and progress.
struct MyPathScreen: View {
    var body: some View {
        NavigationStack {
            PlaceholderScreen(
                title: "My Path",
                message: "Your chosen route and progress will show here."
            )
        }
    }
}

#Preview {
    MyPathScreen()
}
