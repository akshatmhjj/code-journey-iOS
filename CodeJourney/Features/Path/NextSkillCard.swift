import SwiftUI

/// The "up next" card: the next skill on the path, with one button to open it.
/// Used on Today and on Path, so both screens lead to the same place.
struct NextSkillCard: View {
    let skill: Skill
    let stageName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            Text(eyebrow)
                .font(CJFont.caption)
                .tracking(1.2)
                .foregroundStyle(CJColor.accent)

            Text(skill.title)
                .font(CJFont.largeTitle)
                .foregroundStyle(CJColor.ink)

            Text(skill.brief)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)
                .lineLimit(3)

            NavigationLink(value: skill) {
                HStack {
                    Text("Continue")
                        .font(CJFont.headline)
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(CJColor.onAccent)
                .padding(.horizontal, CJSpace.l)
                .frame(maxWidth: .infinity, minHeight: CJLayout.buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: CJRadius.button, style: .continuous)
                        .fill(CJColor.accent)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                .fill(CJColor.accentSoft)
        )
    }

    private var eyebrow: String {
        if let stageName {
            return "UP NEXT · \(stageName.uppercased())"
        }
        return "UP NEXT"
    }
}

#Preview {
    NavigationStack {
        if let skill = ContentStore().skills.first {
            NextSkillCard(skill: skill, stageName: "Foundations")
                .padding(CJSpace.l)
        }
    }
    .environment(ContentStore())
}
