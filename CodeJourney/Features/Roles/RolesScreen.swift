import SwiftUI

/// The Roles tab: every role from the bundled data. Tap one to see its stages.
struct RolesScreen: View {
    @State private var roles: [Role] = []
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            Group {
                if let loadError {
                    Text(loadError)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.inkSecondary)
                        .padding(CJSpace.xl)
                } else {
                    List(roles) { role in
                        NavigationLink {
                            RoleDetailScreen(role: role)
                        } label: {
                            VStack(alignment: .leading, spacing: CJSpace.xxs) {
                                Text(role.title)
                                    .font(CJFont.title)
                                    .foregroundStyle(CJColor.ink)
                                Text("\(role.stages.count) stages")
                                    .font(CJFont.caption)
                                    .foregroundStyle(CJColor.inkSecondary)
                            }
                            .padding(.vertical, CJSpace.xxs)
                        }
                        .listRowBackground(CJColor.surface)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(CJColor.canvas.ignoresSafeArea())
            .navigationTitle("Explore")
            .task { load() }
        }
    }

    private func load() {
        do {
            roles = try RoleLoader.loadRoles()
        } catch {
            loadError = error.localizedDescription
        }
    }
}

#Preview {
    RolesScreen()
}
