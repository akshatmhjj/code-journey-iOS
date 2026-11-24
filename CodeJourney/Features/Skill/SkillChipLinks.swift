import SwiftUI

/// Skill chips that open the skill's page when tapped. Used on stage cards and role pages.
/// Slugs that have no content are left out, so a tap never opens an empty page.
struct SkillChipLinks: View {
    let slugs: [String]
    var tone: CJChip.Tone = .neutral

    @Environment(ContentStore.self) private var content

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 120), spacing: CJSpace.xs, alignment: .leading)],
            alignment: .leading,
            spacing: CJSpace.xs
        ) {
            ForEach(skills) { skill in
                NavigationLink(value: skill) {
                    CJChip(title: skill.title, tone: tone)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var skills: [Skill] {
        slugs.compactMap { content.skill(slug: $0) }
    }
}

#Preview {
    NavigationStack {
        SkillChipLinks(slugs: ["git", "command-line"], tone: .accent)
            .padding(CJSpace.l)
    }
    .environment(ContentStore())
}
