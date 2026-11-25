import SwiftUI
import SwiftData

/// The Path tab: the whole route for the role you chose, stage by stage, with each skill's state.
struct PathScreen: View {
    @Environment(ContentStore.self) private var content
    @Query private var paths: [PathSelection]
    @Query private var progress: [SkillProgress]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CJSpace.xxl) {
                    if let role {
                        pathContent(role)
                    } else {
                        emptyCard
                    }
                }
                .padding(CJLayout.sideMargin)
            }
            .background(CJColor.canvas.ignoresSafeArea())
            .navigationTitle("Path")
            .navigationDestination(for: Skill.self) { skill in
                SkillScreen(skill: skill)
            }
        }
    }

    // MARK: - Content

    private func pathContent(_ role: Role) -> some View {
        let totals = PathProgress.totals(for: role, done: doneSlugs)
        let fraction = totals.total == 0 ? 0 : Double(totals.done) / Double(totals.total)

        return VStack(alignment: .leading, spacing: CJSpace.xxl) {
            HStack(spacing: CJSpace.l) {
                CJProgressRing(progress: fraction, size: 84, lineWidth: 8)
                VStack(alignment: .leading, spacing: CJSpace.xxs) {
                    Text(role.title)
                        .font(CJFont.title)
                        .foregroundStyle(CJColor.ink)
                    Text("\(totals.done) of \(totals.total) skills")
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }
                Spacer(minLength: 0)
            }

            if let slug = PathProgress.nextSkill(in: role, done: doneSlugs),
               let skill = content.skill(slug: slug) {
                NextSkillCard(skill: skill, stageName: stageName(containing: slug, in: role))
            }

            ForEach(PathProgress.stages(of: role, done: doneSlugs)) { summary in
                stageSection(summary)
            }
        }
    }

    private func stageSection(_ summary: PathProgress.StageSummary) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(
                eyebrow: "Stage \(summary.number) · \(summary.doneCount) of \(summary.steps.count) done",
                title: summary.stage.name
            )

            CJStepRail(items: summary.steps.map { step in
                CJStepRail.Item(
                    id: step.slug,
                    title: content.skill(slug: step.slug)?.title ?? step.slug,
                    detail: nil,
                    state: step.state
                )
            })
            .padding(CJSpace.l)
            .background(
                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                    .fill(CJColor.surface)
            )
        }
    }

    private var emptyCard: some View {
        CJCard {
            Text("No path yet")
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)
            Text("Open Explore, pick a role, and tap Make this my path. Every stage and skill will show here.")
                .font(CJFont.body)
                .foregroundStyle(CJColor.inkSecondary)
        }
    }

    // MARK: - State

    private var role: Role? {
        guard let slug = paths.first?.roleSlug else { return nil }
        return content.role(slug: slug)
    }

    private var doneSlugs: Set<String> {
        Set(progress.filter(\.isDone).map(\.skillSlug))
    }

    private func stageName(containing slug: String, in role: Role) -> String? {
        role.stages.first { $0.skills.contains(slug) }?.name
    }
}

#Preview {
    PathScreen()
        .environment(ContentStore())
        .modelContainer(for: [SkillProgress.self, PathSelection.self], inMemory: true)
}
