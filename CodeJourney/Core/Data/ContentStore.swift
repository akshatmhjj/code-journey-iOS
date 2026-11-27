import Foundation
import Observation

/// Holds all the bundled content and answers questions about it.
/// It loads `content.json` once, when the app starts. Screens read it from the environment.
@Observable
final class ContentStore {
    private(set) var domains: [Domain] = []
    private(set) var roles: [Role] = []
    private(set) var skills: [Skill] = []
    private(set) var resources: [Resource] = []
    private(set) var compass: [CompassQuestion] = []
    /// When the pay figures were last checked against their sources. Nil if unknown.
    private(set) var payChecked: String?
    private(set) var switchJobs: [SwitchJob] = []
    private(set) var gap: JobGapData?
    private(set) var interviewTopics: [InterviewTopic] = []
    /// A message to show if the content could not be loaded. Nil when everything loaded.
    private(set) var loadError: String?

    private var skillsBySlug: [String: Skill] = [:]
    private var rolesBySlug: [String: Role] = [:]

    init(bundle: Bundle = .main) {
        do {
            let file = try Self.loadFile(from: bundle)
            domains = file.domains
            roles = file.roles
            skills = file.skills
            resources = file.resources
            compass = file.compass
            payChecked = file.payChecked
            switchJobs = file.switchJobs
            gap = file.gap
            interviewTopics = file.interview
            skillsBySlug = Dictionary(uniqueKeysWithValues: file.skills.map { ($0.slug, $0) })
            rolesBySlug = Dictionary(uniqueKeysWithValues: file.roles.map { ($0.slug, $0) })
        } catch {
            loadError = "The learning content could not be loaded. \(error.localizedDescription)"
        }
    }

    func role(slug: String) -> Role? {
        rolesBySlug[slug]
    }

    func skill(slug: String) -> Skill? {
        skillsBySlug[slug]
    }

    private static func loadFile(from bundle: Bundle) throws -> ContentFile {
        guard let url = bundle.url(forResource: "content", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ContentFile.self, from: data)
    }
}
