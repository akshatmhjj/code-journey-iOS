import SwiftUI

/// The Settings tab: theme and app settings.
struct SettingsScreen: View {
    var body: some View {
        NavigationStack {
            PlaceholderScreen(
                title: "Settings",
                message: "Theme and app settings will go here."
            )
        }
    }
}

#Preview {
    SettingsScreen()
}
