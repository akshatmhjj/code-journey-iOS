import SwiftUI

/// The app's root: five tabs along the bottom, one area per tab.
/// Symbols follow the Ascent spec (section 2.5).
struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Today", systemImage: "sun.horizon") {
                TodayScreen()
            }

            Tab("Explore", systemImage: "safari") {
                RolesScreen()
            }

            Tab("Path", systemImage: "figure.hiking") {
                MyPathScreen()
            }

            Tab("Tools", systemImage: "square.grid.2x2") {
                ToolsScreen()
            }

            Tab("You", systemImage: "person.crop.circle") {
                SettingsScreen()
            }
        }
        .tint(CJColor.accent)
    }
}

#Preview {
    MainTabView()
}
