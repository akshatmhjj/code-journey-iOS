import SwiftUI
import SwiftData

/// The Today tab: the next skill on your path, how far you have come, and your streak.
struct TodayScreen: View {
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
            .navigationTitle("Today")
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
            if let next = nextSkill(for: role) {
                NextSkillCard(skill: next.skill, stageName: next.stageName)
            } else {
                completeCard(role)
            }

            HStack(spacing: CJSpace.l) {
                CJProgressRing(progress: fraction, size: 72)
                VStack(alignment: .leading, spacing: CJSpace.xxs) {
                    Text("\(totals.done) of \(totals.total) skills")
                        .font(CJFont.title)
                        .foregroundStyle(CJColor.ink)
                    Text(role.title)
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }
                Spacer(minLength: 0)
            }

            streakChip

            VStack(alignment: .leading, spacing: CJSpace.m) {
                CJSectionHeader(title: "Your stages")
                ForEach(PathProgress.stages(of: role, done: doneSlugs)) { summary in
                    stageRow(summary)
                }
            }
        }
    }

    private var emptyCard: some View {
        CJCard {
            Text("No path yet")
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)
            Text("Open Explore, pick a role, and tap Make this my path. Your next skill will show here.")
                .font(CJFont.body)
                .foregroundStyle(CJColor.inkSecondary)
        }
    }

    private func completeCard(_ role: Role) -> some View {
        CJCard {
            Label("Route complete", systemImage: "flag.checkered")
                .font(CJFont.title)
                .foregroundStyle(CJColor.success)
            Text("You have finished every skill on the \(role.title) route.")
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)
        }
    }

    private var streakChip: some View {
        let streak = StreakRules.currentStreak(finishedDates: progress.compactMap(\.completedAt))
        return Group {
            if streak > 0 {
                CJChip(title: "\(streak) day streak", systemImage: "flame.fill", tone: .accent)
            } else {
                CJChip(title: "Finish a skill to start a streak", systemImage: "flame")
            }
        }
    }

    private func stageRow(_ summary: PathProgress.StageSummary) -> some View {
        HStack(spacing: CJSpace.m) {
            VStack(alignment: .leading, spacing: CJSpace.xxs) {
                Text(summary.stage.name)
                    .font(CJFont.headline)
                    .foregroundStyle(CJColor.ink)
                Text("\(summary.doneCount) of \(summary.steps.count) done")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            Spacer(minLength: 0)
            CJProgressRing(
                progress: summary.steps.isEmpty ? 0 : Double(summary.doneCount) / Double(summary.steps.count),
                size: 44,
                lineWidth: 5,
                tint: summary.isComplete ? CJColor.success : CJColor.accent
            )
        }
        .padding(CJSpace.m)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    // MARK: - State

    private var role: Role? {
        guard let slug = paths.first?.roleSlug else { return nil }
        return content.role(slug: slug)
    }

    private var doneSlugs: Set<String> {
        Set(progress.filter(\.isDone).map(\.skillSlug))
    }

    /// The next skill to open, with the name of the stage it belongs to.
    private func nextSkill(for role: Role) -> (skill: Skill, stageName: String)? {
        guard let slug = PathProgress.nextSkill(in: role, done: doneSlugs),
              let skill = content.skill(slug: slug),
              let stage = role.stages.first(where: { $0.skills.contains(slug) })
        else { return nil }
        return (skill, stage.name)
    }
}

#Preview {
    TodayScreen()
        .environment(ContentStore())
        .modelContainer(for: [SkillProgress.self, PathSelection.self], inMemory: true)
}
