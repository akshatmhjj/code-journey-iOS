import Foundation

/// A field of tech, such as Web, Mobile or Data. Roles belong to one domain.
struct Domain: Codable, Hashable, Identifiable {
    let slug: String
    let name: String
    let tagline: String

    var id: String { slug }
}
