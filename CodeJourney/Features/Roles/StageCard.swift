import SwiftUI

/// One stage of a role's route: its skills as a step rail, plus its project and "done when".
struct StageCard: View {
    let number: Int
    let stage: Stage

    @Environment(ContentStore.self) private var content

    var body: some View {
        CJCard {
            Text(stageLabel)
                .font(CJFont.caption)
                .tracking(1.2)
                .foregroundStyle(CJColor.ink)

            Text(stage.name)
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)

            Text(stage.summary)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)

            VStack(alignment: .leading, spacing: CJSpace.s) {
                Text("SKILLS")
                    .font(CJFont.caption)
                    .tracking(1.2)
                    .foregroundStyle(CJColor.inkSecondary)
                CJStepRail(items: railItems)
            }

            detailBlock(title: "PROJECT", text: stage.project)
            detailBlock(title: "YOU'RE DONE WHEN", text: stage.doneWhen)
        }
    }

    /// "STAGE 1" plus the time estimate, when the stage has one.
    private var stageLabel: String {
        if let weeks = stage.weeks {
            return "STAGE \(number) · \(weeks) WEEKS"
        }
        return "STAGE \(number)"
    }

    /// One row per skill. Progress arrives in step 7, so every skill starts as "not started".
    private var railItems: [CJStepRail.Item] {
        stage.skills.map { slug in
            let skill = content.skill(slug: slug)
            return CJStepRail.Item(
                id: slug,
                title: skill?.title ?? slug,
                detail: skill?.hours.map { "About \($0) hours" },
                state: .next
            )
        }
    }

    private func detailBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.xxs) {
            Text(title)
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
    StageCard(
        number: 1,
        stage: Stage(
            name: "Foundations",
            summary: "Swift, Git and networking basics.",
            skills: ["git", "command-line"],
            project: "Solve twenty small problems in Swift.",
            doneWhen: "You're comfortable with optionals and protocols.",
            weeks: "8–12"
        )
    )
    .padding()
    .background(CJColor.canvas)
    .environment(ContentStore())
}
