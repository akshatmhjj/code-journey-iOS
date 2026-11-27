import Foundation

/// The system design content from the website: learning paths, their articles, and the glossary.
struct SystemDesignContent: Codable, Hashable {
    let paths: [SystemDesignPath]
    let terms: [SystemDesignTerm]
}

/// One learning path, such as System Design Fundamentals. Articles are read in order.
struct SystemDesignPath: Codable, Hashable, Identifiable {
    let title: String
    let slug: String
    let order: Int
    let level: String
    let purpose: String
    let assumes: String
    let outcome: String
    let articles: [SystemDesignArticle]
    let checks: [SystemDesignCheck]

    var id: String { slug }
}

/// One article in a path: a summary, the key points, and the original source.
struct SystemDesignArticle: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let topic: String
    /// Publication date, as "YYYY-MM-DD".
    let date: String
    let level: String
    let source: URL
    let why: String
    let summary: String
    let points: [String]
    /// The glossary ids this article uses.
    let terms: [String]
    /// The ids of articles to read first.
    let needs: [String]
}

/// A self-check question at the end of a path, with its answer.
struct SystemDesignCheck: Codable, Hashable {
    let q: String
    let a: String
}

/// One glossary term for system design.
struct SystemDesignTerm: Codable, Hashable, Identifiable {
    let id: String
    let term: String
    let def: String
}
