import SwiftUI
import SwiftData

/// Paste a job post and see which Code Journey skills it asks for: what you have, what to learn, and which role it looks like.
/// The text is checked on this phone and is never uploaded or stored.
struct JobPostScreen: View {
    @Environment(ContentStore.self) private var content
    @Query private var progress: [SkillProgress]

    @State private var text = ""
    @State private var analysis: JobPostAnalysis?

    /// A post needs enough words for the checker to find more than one or two skills.
    private let minimumWords = 30

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xxl) {
                CJSectionHeader(eyebrow: "Checked on this phone", title: "Check a job post")

                privacyNote

                editor

                HStack(spacing: CJSpace.m) {
                    PasteButton(payloadType: String.self) { strings in
                        if let pasted = strings.first {
                            text = pasted
                            analysis = nil
                        }
                    }
                    Spacer(minLength: 0)
                    Text("\(wordCount) words")
                        .font(CJFont.caption)
                        .foregroundStyle(CJColor.inkSecondary)
                }

                if wordCount > 0 && wordCount < minimumWords {
                    Text("Paste the whole post, so the checker can find more skills.")
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }

                Button("Check this post") {
                    if let gap = content.gap {
                        analysis = JobPostAnalyser.analyse(gap, text: text)
                    }
                }
                .buttonStyle(.cjPrimary)
                .disabled(wordCount < minimumWords || content.gap == nil)

                if let analysis {
                    results(analysis)
                }
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Job post checker")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Input

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: CJSpace.s) {
            Image(systemName: "lock.fill")
                .foregroundStyle(CJColor.accent)
            Text("Checked on your phone. The post is never uploaded or stored.")
                .font(CJFont.callout)
                .foregroundStyle(CJColor.ink)
        }
        .padding(CJSpace.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.accentSoft)
        )
    }

    private var editor: some View {
        TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .font(CJFont.body)
            .foregroundStyle(CJColor.ink)
            .frame(minHeight: 200)
            .padding(CJSpace.s)
            .background(
                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                    .fill(CJColor.surface)
            )
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Paste the job post here")
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.inkSecondary)
                        .padding(CJSpace.m)
                        .allowsHitTesting(false)
                }
            }
            .onChange(of: text) {
                analysis = nil
            }
    }

    // MARK: - Results

    @ViewBuilder
    private func results(_ result: JobPostAnalysis) -> some View {
        if result.found.isEmpty {
            CJCard {
                Text("No Code Journey skills found")
                    .font(CJFont.title)
                    .foregroundStyle(CJColor.ink)
                Text("Try pasting the full post, including the requirements list.")
                    .font(CJFont.body)
                    .foregroundStyle(CJColor.inkSecondary)
            }
        } else {
            summaryCard(result)

            if !result.roles.isEmpty {
                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(title: "It looks like")
                    ForEach(result.roles) { fit in
                        roleLink(fit)
                    }
                }
            }

            if !haveSlugs(result).isEmpty {
                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(eyebrow: "\(haveSlugs(result).count) skills", title: "You have")
                    CJChipWrap(chips: haveSlugs(result).map { slug in
                        CJChip(title: skillTitle(slug), tone: .success)
                    })
                }
            }

            if !toLearnSlugs(result).isEmpty {
                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(eyebrow: "In learning order", title: "To learn")
                    ForEach(toLearnSlugs(result), id: \.self) { slug in
                        if let skill = content.skill(slug: slug) {
                            learnRow(skill)
                        }
                    }
                }
            }

            if !result.notCovered.isEmpty {
                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(eyebrow: "Not on Code Journey yet", title: "Also named")
                    CJChipWrap(chips: result.notCovered.map { CJChip(title: $0) })
                }
            }

            Text("Approximate. The checker can miss or misread skills, so read the post yourself too.")
                .font(CJFont.caption)
                .foregroundStyle(CJColor.inkSecondary)
        }
    }

    private func summaryCard(_ result: JobPostAnalysis) -> some View {
        let total = result.found.count
        let have = haveSlugs(result).count
        let fraction = total == 0 ? 0 : Double(have) / Double(total)

        return CJCard {
            HStack(spacing: CJSpace.l) {
                CJProgressRing(progress: fraction, size: 72, lineWidth: 7, tint: CJColor.success)
                VStack(alignment: .leading, spacing: CJSpace.xxs) {
                    Text("Found \(total) skills")
                        .font(CJFont.title)
                        .foregroundStyle(CJColor.ink)
                    Text("You have \(have), and \(total - have) to learn")
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func roleLink(_ fit: JobPostRoleFit) -> some View {
        Group {
            if let role = content.role(slug: fit.slug) {
                NavigationLink {
                    RoleDetailScreen(role: role)
                } label: {
                    HStack {
                        Text(fit.title)
                            .font(CJFont.headline)
                            .foregroundStyle(CJColor.ink)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(CJColor.inkSecondary)
                    }
                    .padding(CJSpace.m)
                    .background(
                        RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                            .fill(CJColor.surface)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func learnRow(_ skill: Skill) -> some View {
        NavigationLink {
            SkillScreen(skill: skill)
        } label: {
            HStack(alignment: .center, spacing: CJSpace.m) {
                VStack(alignment: .leading, spacing: CJSpace.xxs) {
                    Text(skill.title)
                        .font(CJFont.headline)
                        .foregroundStyle(CJColor.ink)
                    Text([skill.level.rawValue.capitalized, skill.hours.map { "about \($0) hours" }].compactMap { $0 }.joined(separator: " · "))
                        .font(CJFont.caption)
                        .foregroundStyle(CJColor.inkSecondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(CJColor.inkSecondary)
            }
            .padding(CJSpace.m)
            .background(
                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                    .fill(CJColor.surface)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Data

    private var doneSlugs: Set<String> {
        Set(progress.filter(\.isDone).map(\.skillSlug))
    }

    private func haveSlugs(_ result: JobPostAnalysis) -> [String] {
        result.found.map(\.slug).filter { doneSlugs.contains($0) }
    }

    /// Skills the post asks for that are not done yet, ordered so prerequisites come first.
    private func toLearnSlugs(_ result: JobPostAnalysis) -> [String] {
        guard let gap = content.gap else { return [] }
        let missing = result.found.map(\.slug).filter { !doneSlugs.contains($0) }
        let mentions = Dictionary(result.found.map { ($0.slug, $0.mentions) }, uniquingKeysWith: { first, _ in first })
        return JobPostAnalyser.learningOrder(gap, slugs: missing, mentions: mentions)
    }

    private func skillTitle(_ slug: String) -> String {
        content.skill(slug: slug)?.title ?? slug
    }

    private var wordCount: Int {
        text.split(whereSeparator: \.isWhitespace).count
    }
}

#Preview {
    NavigationStack {
        JobPostScreen()
    }
    .environment(ContentStore())
    .modelContainer(for: [SkillProgress.self, PathSelection.self], inMemory: true)
}
