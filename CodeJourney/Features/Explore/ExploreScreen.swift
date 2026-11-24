import SwiftUI

/// The Explore tab: every role, grouped by domain, with a search box.
/// Tap a role to see its stages.
struct ExploreScreen: View {
    @Environment(ContentStore.self) private var content
    @State private var query = ""

    var body: some View {
        NavigationStack {
            Group {
                if let loadError = content.loadError {
                    Text(loadError)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.inkSecondary)
                        .padding(CJSpace.xl)
                } else if groups.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    roleList
                }
            }
            .background(CJColor.canvas.ignoresSafeArea())
            .navigationTitle("Explore")
            .searchable(text: $query, prompt: "Search roles")
            .navigationDestination(for: Role.self) { role in
                RoleDetailScreen(role: role)
            }
        }
    }

    private var groups: [DomainGroup] {
        RoleSearch.groups(roles: content.roles, domains: content.domains, query: query)
    }

    private var roleList: some View {
        List {
            ForEach(groups) { group in
                Section {
                    ForEach(group.roles) { role in
                        NavigationLink(value: role) {
                            roleRow(role)
                        }
                        .listRowBackground(CJColor.surface)
                    }
                } header: {
                    Text(group.title.uppercased())
                        .font(CJFont.caption)
                        .tracking(0.6)
                        .foregroundStyle(CJColor.inkSecondary)
                }
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func roleRow(_ role: Role) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.xxs) {
            Text(role.title)
                .font(CJFont.headline)
                .foregroundStyle(CJColor.ink)
            Text("\(role.stages.count) stages")
                .font(CJFont.caption)
                .foregroundStyle(CJColor.inkSecondary)
        }
        .padding(.vertical, CJSpace.xxs)
    }
}

#Preview {
    ExploreScreen()
        .environment(ContentStore())
}
