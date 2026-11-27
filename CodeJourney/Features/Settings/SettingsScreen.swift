import SwiftUI

/// The Settings tab: theme and app settings.
struct SettingsScreen: View {
    var body: some View {
        NavigationStack {
            PlaceholderScreen(
                title: "You",
                message: "Appearance, notifications, sign-in and your data will go here."
            )
        }
    }
}

#Preview {
    SettingsScreen()
}
