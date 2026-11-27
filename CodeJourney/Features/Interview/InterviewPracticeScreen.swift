import SwiftUI
import SwiftData

/// Practise one topic's questions, one at a time. Answer out loud, reveal the model answer, then mark it ready.
struct InterviewPracticeScreen: View {
    let topic: InterviewTopic

    @Environment(\.modelContext) private var context
    /// Every ready mark, from all topics. The table is small, so this is filtered in code, not in the query.
    @Query private var ready: [InterviewReady]

    @State private var index = 0
    @State private var revealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            VStack(alignment: .leading, spacing: CJSpace.xs) {
                Text("Question \(index + 1) of \(topic.questions.count) · \(readyCount) ready")
                    .font(CJFont.caption)
                    .tracking(0.8)
                    .foregroundStyle(CJColor.inkSecondary)
                ProgressView(value: Double(index + 1), total: Double(topic.questions.count))
                    .tint(CJColor.accent)
            }
            .padding(.horizontal, CJLayout.sideMargin)

            TabView(selection: $index) {
                ForEach(topic.questions.indices, id: \.self) { questionIndex in
                    questionPage(questionIndex)
                        .tag(questionIndex)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: index) {
                revealed = false
            }

            actions
                .padding(.horizontal, CJLayout.sideMargin)
                .padding(.bottom, CJSpace.m)
        }
        .padding(.top, CJSpace.m)
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: index)
        .sensoryFeedback(.success, trigger: readyCount)
    }

    // MARK: - Pages

    private func questionPage(_ questionIndex: Int) -> some View {
        let question = topic.questions[questionIndex]

        return ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.l) {
                CJCard {
                    Text("QUESTION")
                        .font(CJFont.caption)
                        .tracking(1.0)
                        .foregroundStyle(CJColor.inkSecondary)
                    Text(question.q)
                        .font(CJFont.title)
                        .foregroundStyle(CJColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if questionIndex == index && revealed {
                    CJCard {
                        Text("MODEL ANSWER")
                            .font(CJFont.caption)
                            .tracking(1.0)
                            .foregroundStyle(CJColor.inkSecondary)
                        Text(question.a)
                            .font(CJFont.body)
                            .foregroundStyle(CJColor.ink)
                    }
                } else if questionIndex == index {
                    Text("Answer out loud first. Then reveal the model answer.")
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }
            }
            .padding(.horizontal, CJLayout.sideMargin)
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var actions: some View {
        if revealed {
            HStack(spacing: CJSpace.m) {
                Button("Not yet") {
                    advance()
                }
                .buttonStyle(.cjSecondary)

                Button(isReady ? "Marked ready" : "Mark ready") {
                    toggleReady()
                    advance()
                }
                .buttonStyle(isReady ? .cjTinted : .cjPrimary)
            }
        } else {
            Button("Reveal answer") {
                revealed = true
            }
            .buttonStyle(.cjPrimary)
        }
    }

    private func advance() {
        if index + 1 < topic.questions.count {
            index += 1
        }
    }

    // MARK: - Ready state

    private var readyIDs: Set<String> {
        Set(ready.map(\.questionID))
    }

    private var readyCount: Int {
        topic.questions.indices.filter { readyIDs.contains(topic.questionID(at: $0)) }.count
    }

    private var isReady: Bool {
        readyIDs.contains(topic.questionID(at: index))
    }

    /// Marks the current question ready, or unmarks it. Unmarking deletes the record.
    private func toggleReady() {
        let id = topic.questionID(at: index)
        if let existing = ready.first(where: { $0.questionID == id }) {
            context.delete(existing)
        } else {
            context.insert(InterviewReady(questionID: id))
        }
    }
}

#Preview {
    NavigationStack {
        if let topic = ContentStore().interviewTopics.first {
            InterviewPracticeScreen(topic: topic)
        }
    }
    .environment(ContentStore())
    .modelContainer(for: [InterviewReady.self], inMemory: true)
}
