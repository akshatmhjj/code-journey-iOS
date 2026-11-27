import Foundation

/// A blog post or guide from the website. The body is Markdown, shown with `MarkdownBlocks`.
struct BlogPost: Codable, Hashable, Identifiable {
    let slug: String
    let title: String
    /// Publication date, as "YYYY-MM-DD".
    let date: String
    let tag: String
    let excerpt: String
    let readTime: String
    let body: String

    var id: String { slug }
}
