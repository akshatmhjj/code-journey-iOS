import Foundation
import SwiftData

/// A plain-English definition of one term, such as API or Git.
struct GlossaryTerm: Codable, Hashable, Identifiable {
    let term: String
    let slug: String
    let category: String
    let definition: String

    var id: String { slug }

    /// The letter the term is listed under. Terms that do not start with a letter go under "#".
    var letter: String {
        guard let first = term.uppercased().first, first.isLetter else { return "#" }
        return String(first)
    }
}

/// A flashcard term the person has marked as known. Saved on the phone with SwiftData.
@Model
final class GlossaryKnown {
    @Attribute(.unique) var termSlug: String
    var knownAt: Date

    init(termSlug: String, knownAt: Date = .now) {
        self.termSlug = termSlug
        self.knownAt = knownAt
    }
}
