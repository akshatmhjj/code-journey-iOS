import SwiftUI
import SwiftData

/// One skill: a short brief, an everyday comparison, a checklist, the best places to learn it,
/// and a button to mark it done. Ticks and "done" are saved on the phone.
struct SkillScreen: View {
    let skill: Skill

    @Environment(ContentStore.self) private var content
    @Environment(\.modelContext) private var context
    @Query private var records: [SkillProgress]

    init(skill: Skill) {
        self.skill = skill
        let slug = skill.slug
        _records = Query(filter: #Predicate<SkillProgress> { $0.skillSlug == slug })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xxl) {
                header
                briefCard
                if let analogy = skill.analogy {
                    analogyCard(analogy)
                }
                checklistSection
                resourcesSection
            }
            .padding(CJLayout.sideMargin)
            .padding(.bottom, CJSpace.xxxl)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(skill.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            doneBar
        }
        .sensoryFeedback(.success, trigger: isDone)
        .sensoryFeedback(.selection, trigger: checkedTopics.count)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            if let domain = domainName {
                Text(domain.uppercased())
                    .font(CJFont.caption)
                    .tracking(0.8)
                    .foregroundStyle(CJColor.accent)
            }

            Text(skill.title)
                .font(CJFont.largeTitle)
                .foregroundStyle(CJColor.ink)

            HStack(spacing: CJSpace.xs) {
                CJChip(title: levelText)
                if let hours = skill.hours {
                    CJChip(title: "About \(hours) hours")
                }
                if isDone {
                    CJChip(title: "Done", systemImage: "checkmark", tone: .success)
                }
            }
        }
    }

    private var briefCard: some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            label("The 60-second brief")
            Text(skill.brief)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    private func analogyCard(_ analogy: String) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            label("Think of it like this")
            Text(analogy)
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)

            if let whatItIsNot = skill.whatItIsNot {
                Text(whatItIsNot)
                    .font(CJFont.callout)
                    .foregroundStyle(CJColor.inkSecondary)
            }
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                .fill(CJColor.accentSoft)
        )
    }

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(
                eyebrow: "\(checkedTopics.count) of \(skill.learn.count) ticked",
                title: "Checklist"
            )

            ForEach(skill.learn, id: \.topic) { item in
                checklistRow(item)
            }
        }
    }

    private func checklistRow(_ item: Skill.Topic) -> some View {
        let isTicked = checkedTopics.contains(item.topic)

        return Button {
            toggleTopic(item.topic)
        } label: {
            HStack(alignment: .top, spacing: CJSpace.m) {
                Image(systemName: isTicked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isTicked ? CJColor.success : CJColor.inkSecondary)

                VStack(alignment: .leading, spacing: CJSpace.xxs) {
                    Text(item.topic)
                        .font(CJFont.headline)
                        .foregroundStyle(CJColor.ink)
                    Text(item.detail)
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(CJSpace.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                    .fill(CJColor.surface)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isTicked ? .isSelected : [])
        .accessibilityHint("Double tap to tick or untick")
    }

    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "Learn it")

            ForEach(skill.resources) { resource in
                Link(destination: resource.url) {
                    HStack(alignment: .center, spacing: CJSpace.m) {
                        VStack(alignment: .leading, spacing: CJSpace.xxs) {
                            Text(resource.title)
                                .font(CJFont.headline)
                                .foregroundStyle(CJColor.ink)
                            if let provider = resource.provider {
                                Text(provider)
                                    .font(CJFont.caption)
                                    .foregroundStyle(CJColor.inkSecondary)
                            }
                        }
                        Spacer(minLength: CJSpace.s)
                        CJChip(title: resource.cost.rawValue.capitalized, tone: resource.cost == .free ? .success : .neutral)
                    }
                    .padding(CJSpace.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                            .fill(CJColor.surface)
                    )
                }
            }
        }
    }

    private var doneBar: some View {
        VStack(spacing: CJSpace.s) {
            if let completedAt = record?.completedAt {
                Text("Done on \(completedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }

            Button {
                toggleDone()
            } label: {
                Text(isDone ? "Mark as not done" : "Mark skill done")
            }
            .buttonStyle(isDone ? .cjSecondary : .cjPrimary)
        }
        .padding(CJLayout.sideMargin)
        .frame(maxWidth: .infinity)
        .background(CJColor.canvas)
    }

    // MARK: - State

    private var checkedTopics: [String] {
        record?.checkedTopics ?? []
    }

    private var isDone: Bool {
        record?.isDone ?? false
    }

    private var domainName: String? {
        content.domains.first { $0.slug == skill.domain }?.name
    }

    private var levelText: String {
        skill.level.rawValue.capitalized
    }

    private var record: SkillProgress? {
        records.first
    }

    /// Returns the existing record, or creates one the first time the person changes something.
    private func recordForChange() -> SkillProgress {
        if let record {
            return record
        }
        let created = SkillProgress(skillSlug: skill.slug)
        context.insert(created)
        return created
    }

    private func toggleTopic(_ topic: String) {
        let progress = recordForChange()
        if let index = progress.checkedTopics.firstIndex(of: topic) {
            progress.checkedTopics.remove(at: index)
        } else {
            progress.checkedTopics.append(topic)
        }
    }

    private func toggleDone() {
        let progress = recordForChange()
        progress.completedAt = progress.isDone ? nil : Date()
    }

    private func label(_ text: String) -> some View {
        Text(text.uppercased())
            .font(CJFont.caption)
            .tracking(1.2)
            .foregroundStyle(CJColor.inkSecondary)
    }
}

#Preview {
    NavigationStack {
        if let skill = ContentStore().skills.first {
            SkillScreen(skill: skill)
        }
    }
    .environment(ContentStore())
    .modelContainer(for: SkillProgress.self, inMemory: true)
}
