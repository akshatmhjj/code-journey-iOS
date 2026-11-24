import SwiftUI

/// The Tools tab: Compass, Compare, Pay, Job post checker and the other tools.
/// Each tool gets its own step later.
struct ToolsScreen: View {
    var body: some View {
        NavigationStack {
            PlaceholderScreen(
                title: "Tools",
                message: "Compass, compare, pay, the job post checker and more will show here."
            )
        }
    }
}

#Preview {
    ToolsScreen()
}
