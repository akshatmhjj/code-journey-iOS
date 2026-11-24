import SwiftUI

/// One stage as a tall card: a large number, the name, the skills, the project and "done when".
/// Cards sit in a `StageDeck`, which lets you swipe between them.
struct StageCard: View {
    let number: Int
    let stage: Stage

    @Environment(ContentStore.self) private var content

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            HStack(alignment: .top) {
                Text("\(number)")
                    .font(.system(size: 72, weight: .heavy, design: .rounded))
                    .foregroundStyle(CJColor.accent)
                    .minimumScaleFactor(0.5)
                Spacer()
                if let weeks = stage.weeks {
                    CJChip(title: "\(weeks) weeks", tone: .accent)
                }
            }

            Text(stage.name)
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)

            Text(stage.summary)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)

            VStack(alignment: .leading, spacing: CJSpace.s) {
                label("Skills")
                CJChipWrap(chips: skillChips)
            }

            VStack(alignment: .leading, spacing: CJSpace.xxs) {
                label("Project")
                Text(stage.project)
                    .font(CJFont.body)
                    .foregroundStyle(CJColor.ink)
            }

            HStack(alignment: .top, spacing: CJSpace.s) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(CJColor.success)
                VStack(alignment: .leading, spacing: CJSpace.xxs) {
                    label("You're done when")
                    Text(stage.doneWhen)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)
                }
            }
        }
        .padding(CJSpace.xl)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                .fill(CJColor.surface)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                .strokeBorder(CJColor.hairline, lineWidth: 1)
        }
    }

    private var skillChips: [CJChip] {
        stage.skills.map { slug in
            CJChip(title: content.skill(slug: slug)?.title ?? slug)
        }
    }

    private func label(_ text: String) -> some View {
        Text(text.uppercased())
            .font(CJFont.caption)
            .tracking(1.2)
            .foregroundStyle(CJColor.inkSecondary)
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
