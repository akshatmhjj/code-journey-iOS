import SwiftUI

/// One stage of a role's route, shown as a card with its project and "done when".
struct StageCard: View {
    let number: Int
    let stage: Stage

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
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

            detailBlock(title: "SKILLS", text: skillsText)
            detailBlock(title: "PROJECT", text: stage.project)
            detailBlock(title: "YOU'RE DONE WHEN", text: stage.doneWhen)
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    /// "STAGE 1" plus the time estimate, when the stage has one.
    private var stageLabel: String {
        if let weeks = stage.weeks {
            return "STAGE \(number) · \(weeks) WEEKS"
        }
        return "STAGE \(number)"
    }

    /// Skill IDs such as "how-the-internet-works" shown as readable words.
    private var skillsText: String {
        stage.skillIDs
            .map { $0.replacingOccurrences(of: "-", with: " ") }
            .joined(separator: " · ")
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
            skillIDs: ["swift", "git", "how-the-internet-works"],
            project: "Solve twenty small problems in Swift.",
            doneWhen: "You're comfortable with optionals and protocols.",
            weeks: "8–12"
        )
    )
    .padding()
    .background(CJColor.canvas)
}
