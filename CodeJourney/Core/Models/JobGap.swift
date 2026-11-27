import Foundation

/// The data the job post checker matches against. Built by the website's own function
/// (`buildGapData`), so the app and the site recognise the same skills.
struct JobGapData: Codable, Hashable {
    let skills: [GapSkill]
    /// Words and phrases that mean each skill. A leading "=" means the match is case-sensitive.
    let matchers: [SkillMatchers]
    /// Technologies Code Journey does not teach yet, so the checker can say so.
    let notCovered: [NotCovered]
    let roles: [GapRole]
}

struct GapSkill: Codable, Hashable {
    let slug: String
    let title: String
    let level: String
    let hours: String?
    let prereqs: [String]
    let resource: GapResource?
}

struct GapResource: Codable, Hashable {
    let title: String
    let url: URL
    let official: Bool?
}

struct SkillMatchers: Codable, Hashable {
    let slug: String
    let phrases: [String]
}

struct NotCovered: Codable, Hashable {
    let name: String
    let phrases: [String]
}

/// A role the checker can suggest, with its names and the skills on its route.
struct GapRole: Codable, Hashable {
    let slug: String
    let title: String
    let names: [String]
    let route: [String]
}
