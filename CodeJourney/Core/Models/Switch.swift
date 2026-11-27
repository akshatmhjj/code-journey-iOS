import Foundation

/// A job people already do, and what it gives them for tech roles.
/// `strengths` are things they already do well. `skills` are tech skills the job often gives them a head start on.
struct SwitchJob: Codable, Hashable, Identifiable {
    let slug: String
    let title: String
    let summary: String
    let strengths: [String]
    let skills: [String]

    var id: String { slug }
}
