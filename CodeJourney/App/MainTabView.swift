import SwiftUI

/// The app's root: three tabs along the bottom, one feature per tab.
struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Roles", systemImage: "map") {
                RolesScreen()
            }

            Tab("My Path", systemImage: "checkmark.circle") {
                MyPathScreen()
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsScreen()
            }
        }
        .tint(CJColor.accent)
    }
}

#Preview {
    MainTabView()
}
