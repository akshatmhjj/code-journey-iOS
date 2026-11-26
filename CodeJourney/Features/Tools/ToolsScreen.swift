import SwiftUI
import SwiftData

/// The Tools tab: the quick tools that help you decide and prepare. Compass is live now;
/// the others arrive in later steps and are shown as "Soon".
struct ToolsScreen: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        CompassScreen()
                    } label: {
                        toolRow(
                            title: "Compass quiz",
                            subtitle: "Eight questions, three roles that fit you",
                            symbol: "location.north.circle"
                        )
                    }
                    .listRowBackground(CJColor.surface)

                    NavigationLink {
                        PayScreen()
                    } label: {
                        toolRow(
                            title: "Pay by role",
                            subtitle: "India and US figures, with their sources",
                            symbol: "indianrupeesign.circle"
                        )
                    }
                    .listRowBackground(CJColor.surface)
                }

                Section {
                    ForEach(upcoming, id: \.title) { tool in
                        toolRow(title: tool.title, subtitle: "Soon", symbol: tool.symbol)
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
        }
    }

    private var upcoming: [(title: String, symbol: String)] {
        [
            ("Compare roles", "rectangle.split.2x1"),
            ("Switch careers", "arrow.triangle.branch"),
            ("Job post checker", "doc.text.magnifyingglass"),
            ("Interview prep", "person.2.wave.2"),
            ("System design", "server.rack"),
            ("Glossary and flashcards", "character.book.closed"),
            ("Guides and blog", "book.closed")
        ]
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
