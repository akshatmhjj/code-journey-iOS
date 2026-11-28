import Foundation
import Observation

/// One message in the Ask CJ conversation, as the screen shows it.
struct ChatMessage: Identifiable, Hashable {
    enum Role: String {
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    var text: String
    var sources: [ChatSource] = []
    /// True while the answer is still arriving.
    var isStreaming = false
    /// A message to show under the answer if it could not be finished.
    var problem: String?
}

/// Holds the Ask CJ conversation and streams each answer into it.
@Observable
final class AskModel {
    /// How many earlier messages are sent with each question. The server keeps the last 12 anyway.
    private let historyLimit = 12

    private(set) var messages: [ChatMessage] = []
    private(set) var isSending = false

    private var task: Task<Void, Never>?

    /// Sends a question and streams the answer into the conversation.
    func send(_ question: String) {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        messages.append(ChatMessage(role: .user, text: trimmed))
        messages.append(ChatMessage(role: .assistant, text: "", isStreaming: true))
        let answerIndex = messages.count - 1
        let turns = conversation(excludingAnswerAt: answerIndex)

        isSending = true
        task = Task {
            do {
                for try await event in ChatService.stream(turns: turns) {
                    apply(event, to: answerIndex)
                }
                finish(answerIndex, problem: nil)
            } catch {
                finish(answerIndex, problem: error.localizedDescription)
            }
        }
    }

    /// Starts a new conversation and stops any answer still arriving.
    func reset() {
        task?.cancel()
        task = nil
        messages = []
        isSending = false
    }

    // MARK: - Private

    /// The conversation so far, as the server expects it. The empty answer being written is left out.
    private func conversation(excludingAnswerAt index: Int) -> [CJAPI.Turn] {
        messages
            .enumerated()
            .filter { $0.offset != index && !$0.element.text.isEmpty }
            .map { CJAPI.Turn(role: $0.element.role.rawValue, content: $0.element.text) }
            .suffix(historyLimit)
    }

    private func apply(_ event: ChatEvent, to index: Int) {
        guard messages.indices.contains(index) else { return }
        switch event {
        case .sources(let sources):
            messages[index].sources = sources
        case .delta(let text):
            messages[index].text += text
        case .done:
            messages[index].isStreaming = false
        case .error(let message):
            messages[index].problem = message
        }
    }

    private func finish(_ index: Int, problem: String?) {
        guard messages.indices.contains(index) else { return }
        messages[index].isStreaming = false
        if let problem {
            messages[index].problem = problem
        } else if messages[index].text.isEmpty && messages[index].problem == nil {
            // The stream ended without any text. Say so, rather than leave an empty bubble.
            messages[index].problem = "No answer came back. Try asking again."
        }
        isSending = false
    }
}
