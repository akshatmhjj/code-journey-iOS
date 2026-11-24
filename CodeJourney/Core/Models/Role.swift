import Foundation

/// A tech career route, such as iOS Engineer. Matches one entry in `content.json`.
struct Role: Codable, Hashable, Identifiable {
    /// Which skills are must-have, should-have and nice-to-have, as skill slugs.
    struct SkillPriorities: Codable, Hashable {
        let must: [String]
        let should: [String]
        let nice: [String]
    }

    struct Interview: Codable, Hashable {
        let rounds: [String]
        let practice: [Resource]
    }

    /// A market fact with the source it came from. The source is optional.
    struct MarketNote: Codable, Hashable {
        struct Source: Codable, Hashable {
            let title: String
            let url: URL
        }

        let text: String
        let source: Source?
    }

    /// A small, real task to try before committing to the role. About an hour, free tools.
    struct TasteTest: Codable, Hashable {
        let task: String
        let doneWhen: String
        let forYouIf: String
        let notForYouIf: String
    }

    let slug: String
    let title: String
    let aliases: [String]
    /// The slug of the domain this role belongs to.
    let domain: String?
    let summary: String
    let whereTheyWork: String
    let dayInLife: [String]
    let stages: [Stage]
    let skills: SkillPriorities
    let tools: [String]
    let interview: Interview
    let aiImpact: String
    let market: [MarketNote]
    /// Slugs of roles that share a lot of skills with this one.
    let adjacent: [String]
    /// The 60-minute taste test. Every role has one, so this is only nil if the content is stale.
    let tasteTest: TasteTest?
    /// When the role was last checked, as "YYYY-MM-DD".
    let updated: String

    var id: String { slug }
}
