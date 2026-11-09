import SwiftUI

/// The app's main screen: three tabs along the bottom.
struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Roles", systemImage: "map") {
                NavigationStack {
                    PlaceholderScreen(
                        title: "Roles",
                        message: "Every tech role will be listed here."
                    )
                }
            }

            Tab("My Path", systemImage: "checkmark.circle") {
                NavigationStack {
                    PlaceholderScreen(
                        title: "My Path",
                        message: "Your chosen route and progress will show here."
                    )
                }
            }

            Tab("Settings", systemImage: "gearshape") {
                NavigationStack {
                    PlaceholderScreen(
                        title: "Settings",
                        message: "Theme and app settings will go here."
                    )
                }
            }
        }
        .tint(CJColor.accent)
    }
}

/// A simple brand-coloured screen used until each tab gets its real content.
struct PlaceholderScreen: View {
    let title: String
    let message: String

    var body: some View {
        ZStack {
            CJColor.canvas
                .ignoresSafeArea()

            Text(message)
                .font(CJFont.body())
                .foregroundStyle(CJColor.muted)
                .multilineTextAlignment(.center)
                .padding(24)
        }
        .navigationTitle(title)
    }
}

#Preview {
    MainTabView()
}
