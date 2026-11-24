import SwiftUI

/// One role's page: a 60-minute taste test, the route, the skills, the day to day, interviews and the market.
/// "Make this my path" arrives with My Path in step 8.
struct RoleDetailScreen: View {
    let role: Role

    @Environment(ContentStore.self) private var content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xxl) {
                header

                if let tasteTest = role.tasteTest {
                    tasteSection(tasteTest)
                }

                stagesSection
                skillsSection
                dayInLifeSection
                workSection
                interviewSection
                aiSection
                marketSection
                nearbySection

                Text("Last checked \(role.updated)")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(role.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            if let domain = domainName {
                Text(domain.uppercased())
                    .font(CJFont.caption)
                    .tracking(0.6)
                    .foregroundStyle(CJColor.inkSecondary)
            }

            Text(role.title)
                .font(CJFont.largeTitle)
                .foregroundStyle(CJColor.ink)

            if !role.aliases.isEmpty {
                Text("Also called \(role.aliases.joined(separator: ", "))")
                    .font(CJFont.callout)
                    .foregroundStyle(CJColor.inkSecondary)
            }

            Text(role.summary)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)

            Text("\(role.stages.count) stages · \(skillCount) skills")
                .font(CJFont.caption)
                .foregroundStyle(CJColor.inkSecondary)
        }
    }

    private func tasteSection(_ test: Role.TasteTest) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(eyebrow: "Try it first", title: "60 minutes")

            CJCard {
                labelled("THE TASK", test.task)
                labelled("YOU'RE DONE WHEN", test.doneWhen)
                labelled("YOU MIGHT ENJOY IT IF", test.forYouIf)
                labelled("YOU MIGHT NOT IF", test.notForYouIf)
            }
        }
    }

    private var stagesSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(eyebrow: "\(role.stages.count) stages", title: "The route")

            ForEach(Array(role.stages.enumerated()), id: \.element.id) { index, stage in
                StageCard(number: index + 1, stage: stage)
            }
        }
    }

    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "Skills")

            priorityGroup("Must have", slugs: role.skills.must, tone: .accent)
            priorityGroup("Should have", slugs: role.skills.should, tone: .neutral)
            priorityGroup("Nice to have", slugs: role.skills.nice, tone: .neutral)
        }
    }

    private var dayInLifeSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "A day in the life")

            VStack(alignment: .leading, spacing: CJSpace.s) {
                ForEach(role.dayInLife, id: \.self) { item in
                    HStack(alignment: .top, spacing: CJSpace.s) {
                        Text("•")
                            .foregroundStyle(CJColor.accent)
                        Text(item)
                            .foregroundStyle(CJColor.ink)
                    }
                    .font(CJFont.body)
                }
            }
        }
    }

    private var workSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "Where they work")

            Text(role.whereTheyWork)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)

            Text("TOOLS")
                .font(CJFont.caption)
                .tracking(1.2)
                .foregroundStyle(CJColor.inkSecondary)

            chipGrid(role.tools.map { CJChip(title: $0) })
        }
    }

    private var interviewSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "Interviews")

            VStack(alignment: .leading, spacing: CJSpace.s) {
                ForEach(Array(role.interview.rounds.enumerated()), id: \.offset) { index, round in
                    HStack(alignment: .top, spacing: CJSpace.s) {
                        Text("\(index + 1).")
                            .font(CJFont.headline)
                            .foregroundStyle(CJColor.accent)
                        Text(round)
                            .font(CJFont.body)
                            .foregroundStyle(CJColor.ink)
                    }
                }
            }

            if !role.interview.practice.isEmpty {
                Text("PRACTICE")
                    .font(CJFont.caption)
                    .tracking(1.2)
                    .foregroundStyle(CJColor.inkSecondary)

                ForEach(role.interview.practice) { resource in
                    Link(destination: resource.url) {
                        HStack {
                            Text(resource.title)
                                .font(CJFont.headline)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .foregroundStyle(CJColor.accent)
                        .padding(.vertical, CJSpace.xs)
                    }
                }
            }
        }
    }

    private var aiSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "AI and this job")

            Text(role.aiImpact)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)
        }
    }

    private var marketSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "The market")

            ForEach(Array(role.market.enumerated()), id: \.offset) { _, note in
                VStack(alignment: .leading, spacing: CJSpace.xs) {
                    Text(note.text)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)
                    if let source = note.source {
                        CJSourceChip(name: source.title, url: source.url)
                    }
                }
            }
        }
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "Nearby roles")

            ForEach(nearbyRoles) { nearby in
                NavigationLink(value: nearby) {
                    HStack {
                        Text(nearby.title)
                            .font(CJFont.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(CJColor.ink)
                    .padding(CJSpace.m)
                    .background(
                        RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                            .fill(CJColor.surface)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private var domainName: String? {
        content.domains.first { $0.slug == role.domain }?.name
    }

    private var skillCount: Int {
        Set(role.skills.must + role.skills.should + role.skills.nice).count
    }

    private var nearbyRoles: [Role] {
        role.adjacent.compactMap { content.role(slug: $0) }
    }

    private func skillTitle(_ slug: String) -> String {
        content.skill(slug: slug)?.title ?? slug
    }

    private func priorityGroup(_ label: String, slugs: [String], tone: CJChip.Tone) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            if !slugs.isEmpty {
                Text(label.uppercased())
                    .font(CJFont.caption)
                    .tracking(1.2)
                    .foregroundStyle(CJColor.inkSecondary)
                chipGrid(slugs.map { CJChip(title: skillTitle($0), tone: tone) })
            }
        }
    }

    /// Chips in a grid that wraps onto new lines when there is no room.
    private func chipGrid(_ chips: [CJChip]) -> some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 120), spacing: CJSpace.xs, alignment: .leading)],
            alignment: .leading,
            spacing: CJSpace.xs
        ) {
            ForEach(Array(chips.enumerated()), id: \.offset) { _, chip in
                chip
            }
        }
    }

    private func labelled(_ label: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.xxs) {
            Text(label)
                .font(CJFont.caption)
                .tracking(1.2)
                .foregroundStyle(CJColor.inkSecondary)
            Text(text)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)
        }
    }
}

#Preview {
    NavigationStack {
        // Uses the real bundled content, so the preview shows real data.
        if let role = ContentStore().roles.first {
            RoleDetailScreen(role: role)
        }
    }
    .environment(ContentStore())
}
