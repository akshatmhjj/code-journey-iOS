import SwiftUI

/// The Today tab: the next step on your path and your streak. Filled in at step 8.
struct TodayScreen: View {
    var body: some View {
        NavigationStack {
            PlaceholderScreen(
                title: "Today",
                message: "Your next step and your streak will show here."
            )
        }
    }
}

#Preview {
    TodayScreen()
}
