import SwiftUI

/// The "try it first" card: one hour, one real task, and honest signs about whether the role suits you.
/// It is filled with the accent colour, so it stands out from the rest of the page.
struct TasteTestCard: View {
    let test: Role.TasteTest

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.l) {
            HStack(alignment: .firstTextBaseline, spacing: CJSpace.xs) {
                Text("60")
                    .font(CJFont.number)
                Text("MINUTES")
                    .font(CJFont.caption)
                    .tracking(1.2)
            }

            Text(test.task)
                .font(CJFont.title)

            VStack(alignment: .leading, spacing: CJSpace.xxs) {
                Text("YOU'RE DONE WHEN")
                    .font(CJFont.caption)
                    .tracking(1.2)
                Text(test.doneWhen)
                    .font(CJFont.body)
            }

            VStack(spacing: CJSpace.s) {
                signBox(title: "You might enjoy it if", text: test.forYouIf)
                signBox(title: "Maybe not if", text: test.notForYouIf)
            }
        }
        .foregroundStyle(CJColor.onAccent)
        .padding(CJSpace.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                .fill(CJColor.accent)
        )
    }

    private func signBox(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.xxs) {
            Text(title.uppercased())
                .font(CJFont.caption)
                .tracking(1.0)
            Text(text)
                .font(CJFont.callout)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CJSpace.m)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.canvas.opacity(0.85))
        )
    }
}

#Preview {
    TasteTestCard(test: ContentStore().roles.first!.tasteTest!)
        .padding(CJSpace.l)
        .background(CJColor.canvas)
}
