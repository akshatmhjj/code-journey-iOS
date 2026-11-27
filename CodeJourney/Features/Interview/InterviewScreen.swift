import SwiftUI
import SwiftData

/// Interview prep: the five topics, with how many questions you have marked ready in each.
struct InterviewScreen: View {
    @Environment(ContentStore.self) private var content
    @Query private var ready: [InterviewReady]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xl) {
                CJSectionHeader(
                    eyebrow: "\(content.interviewTopics.count) topics · \(totalQuestions) questions",
                    title: "Interview prep"
                )

                methodCard

                VStack(spacing: CJSpace.m) {
                    ForEach(content.interviewTopics) { topic in
                        NavigationLink {
                            InterviewTopicScreen(topic: topic)
                        } label: {
                            topicCard(topic)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text("Your ticks stay on this phone.")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Interview prep")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var methodCard: some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            Text("HOW TO PRACTISE")
                .font(CJFont.caption)
                .tracking(1.0)
                .foregroundStyle(CJColor.inkSecondary)
            Text("Read the 60-second version. Answer out loud before you reveal. Compare with the model answer. Mark it ready when you could say it in an interview.")
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.accentSoft)
        )
    }

    private func topicCard(_ topic: InterviewTopic) -> some View {
        let readyCount = readyCount(for: topic)
        let fraction = topic.questions.isEmpty ? 0 : Double(readyCount) / Double(topic.questions.count)

        return HStack(alignment: .center, spacing: CJSpace.m) {
            VStack(alignment: .leading, spacing: CJSpace.xxs) {
                Text(topic.title)
                    .font(CJFont.title)
                    .foregroundStyle(CJColor.ink)
                    .multilineTextAlignment(.leading)
                Text("\(readyCount) of \(topic.questions.count) ready")
                    .font(CJFont.callout)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            Spacer(minLength: 0)
            CJProgressRing(progress: fraction, size: 52, lineWidth: 6, tint: CJColor.success)
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    private var totalQuestions: Int {
        content.interviewTopics.reduce(0) { $0 + $1.questions.count }
    }

    private func readyCount(for topic: InterviewTopic) -> Int {
        let ids = Set(ready.map(\.questionID))
        return topic.questions.indices.filter { ids.contains(topic.questionID(at: $0)) }.count
    }
}

/// One topic: the 60-second version, how to say it, the concepts, the traps, and a way into the questions.
struct InterviewTopicScreen: View {
    let topic: InterviewTopic

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xl) {
                CJSectionHeader(eyebrow: "The 60-second version", title: topic.title)

                Text(topic.brief)
                    .font(CJFont.body)
                    .foregroundStyle(CJColor.ink)

                sayCard

                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(eyebrow: "\(topic.concepts.count) concepts", title: "Know these")
                    ForEach(topic.concepts, id: \.term) { concept in
                        conceptCard(concept)
                    }
                }

                if !topic.traps.isEmpty {
                    trapsCard
                }

                NavigationLink {
                    InterviewPracticeScreen(topic: topic)
                } label: {
                    Text("Practise \(topic.questions.count) questions")
                        .font(CJFont.headline)
                        .foregroundStyle(CJColor.onAccent)
                        .frame(maxWidth: .infinity, minHeight: CJLayout.buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: CJRadius.button, style: .continuous)
                                .fill(CJColor.accent)
                        )
                }
                .buttonStyle(.plain)

                Text("Checked \(topic.checked)")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sayCard: some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            Text("HOW TO SAY IT")
                .font(CJFont.caption)
                .tracking(1.0)
                .foregroundStyle(CJColor.inkSecondary)
            Text(topic.say)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                .fill(CJColor.accentSoft)
        )
    }

    private func conceptCard(_ concept: InterviewTopic.Concept) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            Text(concept.term)
                .font(CJFont.headline)
                .foregroundStyle(CJColor.ink)
            Text(concept.def)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)
            if let hook = concept.hook {
                Text(hook)
                    .font(CJFont.callout)
                    .foregroundStyle(CJColor.accent)
            }
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    private var trapsCard: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            Text("TRAPS TO AVOID")
                .font(CJFont.caption)
                .tracking(1.0)
                .foregroundStyle(CJColor.inkSecondary)
            ForEach(topic.traps, id: \.self) { trap in
                HStack(alignment: .top, spacing: CJSpace.s) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(CJColor.warning)
                    Text(trap)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)
                }
            }
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }
}

#Preview {
    NavigationStack {
        InterviewScreen()
    }
    .environment(ContentStore())
    .modelContainer(for: [InterviewReady.self], inMemory: true)
}
