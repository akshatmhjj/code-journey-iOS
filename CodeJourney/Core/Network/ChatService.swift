import Foundation

/// Sends a conversation to CJ AI and streams the answer back, one event at a time.
enum ChatService {
    enum ChatError: LocalizedError {
        case server(String)
        case unreadable

        var errorDescription: String? {
            switch self {
            case .server(let message): message
            case .unreadable: "CJ AI sent an answer the app could not read. Try again."
            }
        }
    }

    /// Streams the answer. The stream ends after `.done`, or throws if the request fails before any answer.
    static func stream(turns: [CJAPI.Turn], token: String? = nil) -> AsyncThrowingStream<ChatEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let request = try CJAPI.chatRequest(turns: turns, token: token)
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let http = response as? HTTPURLResponse else { throw ChatError.unreadable }
                    guard http.statusCode == 200 else {
                        // The route sends a readable message as JSON, such as "You've used your free questions".
                        var body = Data()
                        for try await byte in bytes { body.append(byte) }
                        struct Failure: Decodable { let error: String }
                        let message = (try? JSONDecoder().decode(Failure.self, from: body))?.error
                        throw ChatError.server(message ?? "CJ AI is unavailable right now. Try again shortly.")
                    }

                    var parser = SSEParser()
                    var finished = false
                    for try await line in bytes.lines {
                        if let event = parser.feed(line: line) {
                            continuation.yield(event)
                            if event == .done {
                                finished = true
                                break
                            }
                        }
                    }
                    if !finished, let last = parser.flush() {
                        continuation.yield(last)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
