import SwiftUI
import SwiftData

/// The Tools tab: the quick tools that help you decide and prepare.
/// Compass, Pay, Compare and Switch careers are live. The rest arrive in later steps.
struct ToolsScreen: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    tool(title: "Compass quiz", subtitle: "Eight questions, three roles that fit you", symbol: "location.north.circle") {
                        CompassScreen()
                    }
                    tool(title: "Compare roles", subtitle: "Two roles side by side", symbol: "rectangle.split.2x1") {
                        CompareScreen()
                    }
                    tool(title: "Switch careers", subtitle: "Start from the job you do now", symbol: "arrow.triangle.branch") {
                        SwitchScreen()
                    }
                    tool(title: "Pay by role", subtitle: "India and US figures, with their sources", symbol: "indianrupeesign.circle") {
                        PayScreen()
                    }
                    tool(title: "Job post checker", subtitle: "Paste a job post, see the skills it asks for", symbol: "doc.text.magnifyingglass") {
                        JobPostScreen()
                    }
                }

                Section {
                    ForEach(upcoming, id: \.title) { item in
                        toolRow(title: item.title, subtitle: "Soon", symbol: item.symbol)
                            .opacity(0.6)
                            .listRowBackground(CJColor.surface)
                    }
                } header: {
                    Text("COMING SOON")
                        .font(CJFont.caption)
                        .tracking(0.6)
                        .foregroundStyle(CJColor.inkSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(CJColor.canvas.ignoresSafeArea())
            .navigationTitle("Tools")
            .navigationDestination(for: Role.self) { role in
                RoleDetailScreen(role: role)
            }
            .navigationDestination(for: Skill.self) { skill in
                SkillScreen(skill: skill)
            }
            .navigationDestination(for: SwitchJob.self) { job in
                SwitchJobScreen(job: job)
            }
        }
    }

    private var upcoming: [(title: String, symbol: String)] {
        [
            ("Interview prep", "person.2.wave.2"),
            ("System design", "server.rack"),
            ("Glossary and flashcards", "character.book.closed"),
            ("Guides and blog", "book.closed")
        ]
    }

    /// A live tool: a row that opens its screen.
    private func tool<Destination: View>(
        title: String,
        subtitle: String,
        symbol: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            toolRow(title: title, subtitle: subtitle, symbol: symbol)
        }
        .listRowBackground(CJColor.surface)
    }

    private func toolRow(title: String, subtitle: String, symbol: String) -> some View {
        HStack(spacing: CJSpace.m) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(CJColor.accent)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: CJRadius.chip, style: .continuous)
                        .fill(CJColor.accentSoft)
                )

            VStack(alignment: .leading, spacing: CJSpace.xxs) {
                Text(title)
                    .font(CJFont.headline)
                    .foregroundStyle(CJColor.ink)
                Text(subtitle)
                    .font(CJFont.callout)
                    .foregroundStyle(CJColor.inkSecondary)
            }
        }
        .padding(.vertical, CJSpace.xs)
    }
}

#Preview {
    ToolsScreen()
        .environment(ContentStore())
        .modelContainer(for: [SkillProgress.self, PathSelection.self], inMemory: true)
}
