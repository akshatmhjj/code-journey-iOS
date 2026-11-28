import Foundation

/// One source the answer cites, numbered as the answer refers to it ([1], [2]...).
struct ChatSource: Codable, Hashable, Identifiable {
    let n: Int
    let title: String
    let heading: String?
    let url: String

    var id: Int { n }
}

/// One event from the chat stream.
enum ChatEvent: Equatable {
    /// The sources for this answer, sent before the text.
    case sources([ChatSource])
    /// A piece of the answer text, to add to what has arrived so far.
    case delta(String)
    /// The answer is complete.
    case done
    /// Something went wrong, with a message the person can read.
    case error(String)
}

/// Reads the server-sent events the chat route sends. Each event is an `event:` line followed by one or more
/// `data:` lines. Events are normally ended by a blank line, but the line reader used by URLSession drops blank
/// lines. So an event also ends when the next `event:` line starts, and `flush()` returns the last one at the end.
struct SSEParser {
    private var eventName: String?
    private var dataLines: [String] = []

    /// Feed one line at a time. Returns the event that the line completes, if any.
    mutating func feed(line: String) -> ChatEvent? {
        if line.isEmpty {
            return take()
        }
        if line.hasPrefix("event:") {
            let completed = take()
            eventName = String(line.dropFirst("event:".count)).trimmingCharacters(in: .whitespaces)
            return completed
        }
        if line.hasPrefix("data:") {
            dataLines.append(String(line.dropFirst("data:".count)).trimmingCharacters(in: .whitespaces))
        }
        return nil
    }

    /// Returns the last event once the stream has ended, if one is still waiting.
    mutating func flush() -> ChatEvent? {
        take()
    }

    private mutating func take() -> ChatEvent? {
        defer {
            eventName = nil
            dataLines = []
        }
        guard let name = eventName else { return nil }
        return ChatEvent.from(name: name, data: dataLines.joined(separator: "\n"))
    }
}

extension ChatEvent {
    /// Decodes one event. Unknown events and bad data are ignored rather than stopping the answer.
    static func from(name: String, data: String) -> ChatEvent? {
        let bytes = Data(data.utf8)
        switch name {
        case "sources":
            guard let sources = try? JSONDecoder().decode([ChatSource].self, from: bytes) else { return nil }
            return .sources(sources)
        case "delta":
            guard let text = try? JSONDecoder().decode(String.self, from: bytes) else { return nil }
            return .delta(text)
        case "done":
            return .done
        case "error":
            struct Failure: Decodable { let message: String }
            let message = (try? JSONDecoder().decode(Failure.self, from: bytes))?.message
            return .error(message ?? "CJ AI couldn't finish that answer. Try again.")
        default:
            return nil
        }
    }
}
