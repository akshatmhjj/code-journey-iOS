import SwiftUI

/// Shows one role: what it is, where people work in it, and its stages in order.
struct RoleDetailScreen: View {
    let role: Role

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xl) {
                VStack(alignment: .leading, spacing: CJSpace.s) {
                    Text(role.summary)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)

                    Text("WHERE THEY WORK")
                        .font(CJFont.caption)
                        .tracking(1.2)
                        .foregroundStyle(CJColor.ink)

                    Text(role.whereTheyWork)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.inkSecondary)
                }

                ForEach(Array(role.stages.enumerated()), id: \.element.id) { index, stage in
                    StageCard(number: index + 1, stage: stage)
                }
            }
            .padding(CJSpace.xl)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(role.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RoleDetailScreen(role: previewRole)
    }
}

private let previewRole = Role(
    id: "ios-engineer",
    title: "iOS Engineer",
    summary: "Native apps for iPhone and iPad.",
    whereTheyWork: "Consumer apps and fintech.",
    stages: [
        Stage(
            name: "Foundations",
            summary: "Swift, Git and networking basics.",
            skillIDs: ["swift", "git"],
            project: "Solve twenty small problems in Swift.",
            doneWhen: "You're comfortable with optionals and protocols.",
            weeks: "8–12"
        )
    ]
)
