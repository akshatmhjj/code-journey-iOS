import SwiftUI
import SwiftData

/// One role's page, laid out as a climb: the hero, "Make this my path", a 60-minute taste test,
/// the stages as swipeable camps, then the skills, the day to day, interviews and the market.
struct RoleDetailScreen: View {
    let role: Role

    @Environment(ContentStore.self) private var content
    @Environment(\.modelContext) private var context
    @Query private var paths: [PathSelection]
    @State private var confirmSwitch = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xxxl) {
                RoleHero(role: role, domainName: domainName)
                    .padding(.horizontal, CJLayout.sideMargin)
                    .padding(.top, CJSpace.m)
                    .revealOnScroll()

                pathButton
                    .padding(.horizontal, CJLayout.sideMargin)
                    .revealOnScroll()

                if let tasteTest = role.tasteTest {
                    TasteTestCard(test: tasteTest)
                        .padding(.horizontal, CJLayout.sideMargin)
                        .revealOnScroll()
                }

                climbSection
                    .revealOnScroll()
                skillsSection
                    .padding(.horizontal, CJLayout.sideMargin)
                    .revealOnScroll()
                dayInLifeSection
                    .padding(.horizontal, CJLayout.sideMargin)
                    .revealOnScroll()
                workSection
                    .padding(.horizontal, CJLayout.sideMargin)
                    .revealOnScroll()
                interviewSection
                    .padding(.horizontal, CJLayout.sideMargin)
                    .revealOnScroll()
                aiSection
                    .padding(.horizontal, CJLayout.sideMargin)
                    .revealOnScroll()
                marketSection
                    .padding(.horizontal, CJLayout.sideMargin)
                    .revealOnScroll()
                nearbySection
                    .revealOnScroll()

                Text("Last checked \(role.updated)")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
                    .padding(.horizontal, CJLayout.sideMargin)
                    .padding(.bottom, CJSpace.xxl)
            }
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(role.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var climbSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(eyebrow: "\(role.stages.count) camps", title: "The climb")
                .padding(.horizontal, CJLayout.sideMargin)

            StageDeck(stages: role.stages)
        }
    }

    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.l) {
            CJSectionHeader(title: "Skills")

            skillGroup("Must have", slugs: role.skills.must, tone: .accent)
            skillGroup("Should have", slugs: role.skills.should, tone: .neutral)
            skillGroup("Nice to have", slugs: role.skills.nice, tone: .neutral)
        }
    }

    private var dayInLifeSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(eyebrow: "Daily", title: "A day in the life")

            ForEach(Array(role.dayInLife.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: CJSpace.m) {
                    Text(String(format: "%02d", index + 1))
                        .font(CJFont.number)
                        .foregroundStyle(CJColor.accent)
                    Text(item)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)
                    Spacer(minLength: 0)
                }
                .padding(CJSpace.m)
                .background(
                    RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                        .fill(CJColor.surface)
                )
            }
        }
    }

    private var workSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "Where they work")

            Text(role.whereTheyWork)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)

            label("Tools")
            CJChipWrap(chips: role.tools.map { CJChip(title: $0) })
        }
    }

    private var interviewSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(eyebrow: "\(role.interview.rounds.count) rounds", title: "Interviews")

            CJStepRail(items: role.interview.rounds.enumerated().map { index, round in
                CJStepRail.Item(id: "round-\(index)", title: round, state: .next)
            })

            if !role.interview.practice.isEmpty {
                label("Practice")
                ForEach(role.interview.practice) { resource in
                    Link(destination: resource.url) {
                        HStack {
                            Text(resource.title)
                                .font(CJFont.headline)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .foregroundStyle(CJColor.accent)
                        .padding(CJSpace.m)
                        .background(
                            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                                .fill(CJColor.surface)
                        )
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
                .padding(CJSpace.l)
                .background(
                    RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                        .fill(CJColor.accentSoft)
                )
        }
    }

    private var marketSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "The market")

            ForEach(Array(role.market.enumerated()), id: \.offset) { _, note in
                VStack(alignment: .leading, spacing: CJSpace.s) {
                    Text(note.text)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)
                    if let source = note.source {
                        CJSourceChip(name: source.title, url: source.url)
                    }
                }
                .padding(CJSpace.l)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                        .fill(CJColor.surface)
                )
            }
        }
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "Nearby roles")
                .padding(.horizontal, CJLayout.sideMargin)

            ScrollView(.horizontal) {
                HStack(spacing: CJSpace.m) {
                    ForEach(nearbyRoles) { nearby in
                        NavigationLink(value: nearby) {
                            VStack(alignment: .leading, spacing: CJSpace.s) {
                                Image(systemName: "arrow.up.right.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(CJColor.accent)
                                Spacer(minLength: 0)
                                Text(nearby.title)
                                    .font(CJFont.headline)
                                    .foregroundStyle(CJColor.ink)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(CJSpace.l)
                            .frame(width: 200, height: 150, alignment: .topLeading)
                            .background(
                                RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                                    .fill(CJColor.surface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, CJLayout.sideMargin)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Helpers

    /// "Make this my path", or "This is your path" when it already is. Switching asks first.
    private var pathButton: some View {
        let isCurrent = paths.first?.roleSlug == role.slug

        return Button {
            if paths.isEmpty || isCurrent {
                choosePath()
            } else {
                confirmSwitch = true
            }
        } label: {
            Text(isCurrent ? "This is your path" : "Make this my path")
        }
        .buttonStyle(isCurrent ? .cjTinted : .cjPrimary)
        .disabled(isCurrent)
        .confirmationDialog(
            "Switch your path to \(role.title)?",
            isPresented: $confirmSwitch,
            titleVisibility: .visible
        ) {
            Button("Switch path") { choosePath() }
            Button("Keep my current path", role: .cancel) {}
        } message: {
            Text("The skills you have finished are kept.")
        }
    }

    private func choosePath() {
        PathChooser.choose(roleSlug: role.slug, existing: paths, in: context)
    }

    private var domainName: String? {
        content.domains.first { $0.slug == role.domain }?.name
    }

    private var nearbyRoles: [Role] {
        role.adjacent.compactMap { content.role(slug: $0) }
    }

    private func skillGroup(_ title: String, slugs: [String], tone: CJChip.Tone) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            if !slugs.isEmpty {
                label(title)
                SkillChipLinks(slugs: slugs, tone: tone)
            }
        }
    }

    private func label(_ text: String) -> some View {
        Text(text.uppercased())
            .font(CJFont.caption)
            .tracking(1.2)
            .foregroundStyle(CJColor.inkSecondary)
    }
}

/// Fades a section in and lifts it slightly as it scrolls into view.
private extension View {
    func revealOnScroll() -> some View {
        scrollTransition(axis: .vertical) { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.35)
                .offset(y: phase.isIdentity ? 0 : 28)
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
