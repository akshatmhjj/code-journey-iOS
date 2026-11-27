import Foundation

/// A link to learn from: official docs, a course, a book, practice and so on.
struct Resource: Codable, Hashable, Identifiable {
    /// What kind of resource it is. The raw values match the website's content.
    enum Kind: String, Codable, CaseIterable {
        case docs, book, course, video, interactive, practice, tool, article, community
    }

    enum Cost: String, Codable {
        case free, freemium, paid
    }

    let title: String
    let url: URL
    let provider: String?
    let type: Kind
    let cost: Cost
    let official: Bool?
    let note: String?
    /// The skills that link to this resource. Set only in the shared list of all resources.
    let skills: [String]?

    /// A URL is unique for each resource, so it doubles as the ID.
    var id: String { url.absoluteString }
}
