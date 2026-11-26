import SwiftUI
import SwiftData

/// The Compass quiz: eight questions, one per screen, then the three roles that suit the answers.
/// Each suggestion says why, in the person's own answers.
struct CompassScreen: View {
    /// Where the quiz is: the start, one question (by index), or the results.
    enum Step: Hashable {
        case intro
        case question(Int)
        case result
    }

    @Environment(ContentStore.self) private var content
    @Environment(\.modelContext) private var context
    @Query private var paths: [PathSelection]

    @State private var step: Step = .intro
    /// The option picked for each answered question, in order.
    @State private var answers: [Int] = []
    /// The option picked on the question on screen, not yet confirmed with Next.
    @State private var selected: Int?
    @State private var pendingRole: String?

    var body: some View {
        Group {
            switch step {
            case .intro:
                introView
            case .question(let index):
                questionView(index)
            case .result:
                resultView
            }
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Compass")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: selected)
    }

    // MARK: - Steps

    private var introView: some View {
        VStack(alignment: .leading, spacing: CJSpace.xl) {
            Spacer(minLength: 0)

            Image(systemName: "location.north.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(CJColor.accent)

            Text("Find roles that fit you")
                .font(CJFont.largeTitle)
                .foregroundStyle(CJColor.ink)

            Text("\(content.compass.count) questions. No right answers. We suggest three roles and tell you why each one fits.")
                .font(CJFont.body)
                .foregroundStyle(CJColor.inkSecondary)

            Spacer(minLength: 0)

            Button("Start") {
                answers = []
                selected = nil
                step = .question(0)
            }
            .buttonStyle(.cjPrimary)
            .disabled(content.compass.isEmpty)
        }
        .padding(CJLayout.sideMargin)
    }

    private func questionView(_ index: Int) -> some View {
        let question = content.compass[index]

        return VStack(alignment: .leading, spacing: CJSpace.l) {
            VStack(alignment: .leading, spacing: CJSpace.s) {
                Text("Question \(index + 1) of \(content.compass.count)")
                    .font(CJFont.caption)
                    .tracking(0.8)
                    .foregroundStyle(CJColor.inkSecondary)
                ProgressView(value: Double(index), total: Double(content.compass.count))
                    .tint(CJColor.accent)
            }

            Text(question.q)
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                VStack(spacing: CJSpace.s) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { optionIndex, option in
                        optionCard(option.label, isSelected: selected == optionIndex) {
                            selected = optionIndex
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)

            HStack(spacing: CJSpace.m) {
                Button("Back") {
                    goBack(from: index)
                }
                .buttonStyle(.cjSecondary)
                .disabled(index == 0)

                Button(index == content.compass.count - 1 ? "See my roles" : "Next") {
                    advance(from: index)
                }
                .buttonStyle(.cjPrimary)
                .disabled(selected == nil)
            }
        }
        .padding(CJLayout.sideMargin)
    }

    private func optionCard(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: CJSpace.m) {
                Text(label)
                    .font(CJFont.headline)
                    .foregroundStyle(CJColor.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? CJColor.accent : CJColor.inkSecondary)
            }
            .padding(CJSpace.l)
            .background(
                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                    .fill(isSelected ? CJColor.accentSoft : CJColor.surface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                    .strokeBorder(isSelected ? CJColor.accent : CJColor.hairline, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var resultView: some View {
        let matches = Array(CompassScoring.rank(questions: content.compass, answers: answers).prefix(3))

        return ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xl) {
                CJSectionHeader(eyebrow: "Your results", title: "Roles that fit you")

                ForEach(Array(matches.enumerated()), id: \.element.id) { index, match in
                    if let role = content.role(slug: match.slug) {
                        resultCard(rank: index, role: role, match: match)
                    }
                }

                Button("Start again") {
                    step = .intro
                }
                .buttonStyle(.cjSecondary)
            }
            .padding(CJLayout.sideMargin)
        }
        .scrollIndicators(.hidden)
        .confirmationDialog(
            "Switch your path to \(pendingTitle)?",
            isPresented: Binding(
                get: { pendingRole != nil },
                set: { if !$0 { pendingRole = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Switch path") {
                if let slug = pendingRole {
                    PathChooser.choose(roleSlug: slug, existing: paths, in: context)
                }
                pendingRole = nil
            }
            Button("Keep my current path", role: .cancel) {
                pendingRole = nil
            }
        } message: {
            Text("The skills you have finished are kept.")
        }
    }

    private func resultCard(rank: Int, role: Role, match: CompassMatch) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            Text(rankLabel(rank).uppercased())
                .font(CJFont.caption)
                .tracking(1.0)
                .foregroundStyle(rank == 0 ? CJColor.accent : CJColor.inkSecondary)

            Text(role.title)
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)

            VStack(alignment: .leading, spacing: CJSpace.xs) {
                ForEach(match.reasons, id: \.self) { reason in
                    HStack(alignment: .top, spacing: CJSpace.s) {
                        Text("•")
                            .foregroundStyle(CJColor.accent)
                        Text("Because you \(reason)")
                            .font(CJFont.body)
                            .foregroundStyle(CJColor.ink)
                    }
                }
            }

            HStack(spacing: CJSpace.m) {
                NavigationLink(value: role) {
                    Text("See the role")
                        .font(CJFont.headline)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: CJLayout.buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: CJRadius.button, style: .continuous)
                                .strokeBorder(CJColor.ink, lineWidth: 1.5)
                        )
                        .foregroundStyle(CJColor.ink)
                }
                .buttonStyle(.plain)

                if rank == 0 {
                    Button("Make my path") {
                        choose(role)
                    }
                    .buttonStyle(.cjPrimary)
                }
            }
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                .fill(rank == 0 ? CJColor.accentSoft : CJColor.surface)
        )
    }

    // MARK: - Actions

    private func advance(from index: Int) {
        guard let selected else { return }
        answers = Array(answers.prefix(index)) + [selected]

        if index + 1 < content.compass.count {
            self.selected = nil
            step = .question(index + 1)
        } else {
            step = .result
        }
    }

    private func goBack(from index: Int) {
        guard index > 0 else { return }
        selected = answers[index - 1]
        answers = Array(answers.prefix(index - 1))
        step = .question(index - 1)
    }

    /// Makes the role the path. Asks first when a different path already exists.
    private func choose(_ role: Role) {
        if let current = paths.first?.roleSlug, current != role.slug {
            pendingRole = role.slug
        } else {
            PathChooser.choose(roleSlug: role.slug, existing: paths, in: context)
        }
    }

    private var pendingTitle: String {
        guard let slug = pendingRole, let role = content.role(slug: slug) else { return "this role" }
        return role.title
    }

    private func rankLabel(_ rank: Int) -> String {
        switch rank {
        case 0: "Best fit"
        case 1: "Good fit"
        default: "Worth a look"
        }
    }
}

#Preview {
    NavigationStack {
        CompassScreen()
    }
    .environment(ContentStore())
    .modelContainer(for: [SkillProgress.self, PathSelection.self], inMemory: true)
}
