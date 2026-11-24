import Foundation

/// One thing to learn, such as Git or JavaScript. A stage lists the skills it teaches.
struct Skill: Codable, Hashable, Identifiable {
    enum Level: String, Codable {
        case beginner, intermediate, advanced
    }

    /// One topic inside a skill, with a short explanation.
    struct Topic: Codable, Hashable {
        let topic: String
        let detail: String
    }

    let slug: String
    let title: String
    let domain: String
    let level: Level
    /// Time to learn, such as "10–20". Optional.
    let hours: String?
    /// The 60-second brief shown at the top of the skill page.
    let brief: String
    let prereqs: [String]
    let learn: [Topic]
    let resources: [Resource]
    /// An everyday comparison, shown under the brief. Optional until every skill has one.
    let analogy: String?
    /// The most common confusion, in one sentence.
    let whatItIsNot: String?
    /// When the content was last checked, as "YYYY-MM-DD".
    let checked: String

    var id: String { slug }
}
