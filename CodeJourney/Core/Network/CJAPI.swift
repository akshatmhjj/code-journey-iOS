import Foundation

/// Where the app talks to the website's API. Change `baseURL` in one place if the site moves.
enum CJAPI {
    static let baseURL = URL(string: "https://www.codejourney.space")!

    /// One message in the conversation, as the chat route expects it.
    struct Turn: Codable {
        let role: String
        let content: String
    }

    /// The chat request. `token` is the signed-in user's session; nil means a guest.
    /// Guests get a few free questions a day, counted by the server.
    static func chatRequest(turns: [Turn], token: String?) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: "api/chat"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(Body(messages: turns))
        request.timeoutInterval = 60
        return request
    }

    private struct Body: Encodable {
        let messages: [Turn]
    }

    /// Turns an absolute link or a site path such as "/skills/git" into a full address.
    static func absoluteURL(_ link: String) -> URL? {
        if let url = URL(string: link), url.scheme != nil {
            return url
        }
        return URL(string: link, relativeTo: baseURL)?.absoluteURL
    }
}
