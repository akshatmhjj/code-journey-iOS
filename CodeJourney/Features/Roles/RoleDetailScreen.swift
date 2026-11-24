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
        // Uses the real bundled content, so the preview shows real data.
        if let role = ContentStore().roles.first {
            RoleDetailScreen(role: role)
        }
    }
}
