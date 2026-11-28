import SwiftUI

/// Ask CJ: ask about roles and skills. Answers come only from Code Journey's pages, with the sources listed.
struct AskScreen: View {
    @State private var model = AskModel()
    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    private let suggestions = [
        "Do I need DSA for frontend?",
        "What should I learn after Git?",
        "Frontend or backend first?"
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: CJSpace.m) {
                        if model.messages.isEmpty {
                            intro
                        }
                        ForEach(model.messages) { message in
                            bubble(message)
                                .id(message.id)
                        }
                    }
                    .padding(CJLayout.sideMargin)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: model.messages.last?.text) {
                    if let last = model.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            inputBar
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Ask CJ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New") {
                    model.reset()
                }
                .disabled(model.messages.isEmpty)
            }
        }
    }

    // MARK: - Pieces

    private var intro: some View {
        VStack(alignment: .leading, spacing: CJSpace.l) {
            VStack(alignment: .leading, spacing: CJSpace.s) {
                Text("Answers come only from Code Journey's pages, with the sources listed.")
                    .font(CJFont.body)
                    .foregroundStyle(CJColor.ink)
                Text("Guests get three free questions a day.")
                    .font(CJFont.callout)
                    .foregroundStyle(CJColor.inkSecondary)
            }

            VStack(alignment: .leading, spacing: CJSpace.s) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        model.send(suggestion)
                    } label: {
                        Text(suggestion)
                            .font(CJFont.headline)
                            .foregroundStyle(CJColor.ink)
                            .padding(CJSpace.m)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                                    .fill(CJColor.surface)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func bubble(_ message: ChatMessage) -> some View {
        switch message.role {
        case .user:
            Text(message.text)
                .font(CJFont.body)
                .foregroundStyle(CJColor.onAccent)
                .padding(CJSpace.m)
                .background(
                    RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                        .fill(CJColor.accent)
                )
                .frame(maxWidth: .infinity, alignment: .trailing)

        case .assistant:
            VStack(alignment: .leading, spacing: CJSpace.s) {
                if message.text.isEmpty && message.isStreaming {
                    ProgressView()
                        .tint(CJColor.accent)
                } else {
                    Text(answerText(message.text))
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)
                }

                if let problem = message.problem {
                    Text(problem)
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.critical)
                }

                if !message.sources.isEmpty && !message.isStreaming {
                    VStack(alignment: .leading, spacing: CJSpace.xs) {
                        Text("SOURCES")
                            .font(CJFont.caption)
                            .tracking(1.0)
                            .foregroundStyle(CJColor.inkSecondary)
                        ForEach(message.sources) { source in
                            sourceLink(source)
                        }
                    }
                    .padding(.top, CJSpace.xs)
                }
            }
            .padding(CJSpace.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                    .fill(CJColor.surface)
            )
        }
    }

    @ViewBuilder
    private func sourceLink(_ source: ChatSource) -> some View {
        if let url = CJAPI.absoluteURL(source.url) {
            Link(destination: url) {
                HStack(spacing: CJSpace.s) {
                    Text("[\(source.n)]")
                        .font(CJFont.caption.weight(.bold))
                    Text(source.heading.map { "\(source.title) · \($0)" } ?? source.title)
                        .font(CJFont.callout)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                }
                .foregroundStyle(CJColor.accent)
            }
        }
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: CJSpace.s) {
            TextField("Ask about a role or skill", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .focused($inputFocused)
                .font(CJFont.body)
                .padding(CJSpace.m)
                .background(
                    RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                        .fill(CJColor.surface)
                )

            Button {
                let question = draft
                draft = ""
                inputFocused = false
                model.send(question)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(CJColor.accent)
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || model.isSending)
            .accessibilityLabel("Send question")
        }
        .padding(CJSpace.m)
        .background(CJColor.canvas)
    }

    /// The answer as text. Bold, italics and links are read from the Markdown the model writes.
    private func answerText(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
}

#Preview {
    NavigationStack {
        AskScreen()
    }
}
