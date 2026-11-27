import Foundation

/// Progress through one role's route, worked out from the skills the person has finished.
/// Pure Swift, with no SwiftUI or SwiftData, so it can be tested on its own.
enum PathProgress {
    /// One skill on the route, and where it stands.
    struct SkillStep: Identifiable, Hashable {
        let slug: String
        let state: CJStepRail.State

        var id: String { slug }
    }

    /// One stage on the route, with each of its skills.
    struct StageSummary: Identifiable {
        let number: Int
        let stage: Stage
        let steps: [SkillStep]

        var id: String { stage.id }
        var doneCount: Int { steps.filter { $0.state == .done }.count }
        var isComplete: Bool { !steps.isEmpty && doneCount == steps.count }
    }

    /// Every skill on the route, once each, in the order the stages teach them.
    static func skillSlugs(in role: Role) -> [String] {
        var seen = Set<String>()
        return role.stages.flatMap(\.skills).filter { seen.insert($0).inserted }
    }

    /// The first skill on the route that is not finished yet, or nil when everything is done.
    static func nextSkill(in role: Role, done: Set<String>) -> String? {
        skillSlugs(in: role).first { !done.contains($0) }
    }

    /// How many skills on the route are finished, out of how many there are.
    static func totals(for role: Role, done: Set<String>) -> (done: Int, total: Int) {
        let slugs = skillSlugs(in: role)
        return (slugs.filter { done.contains($0) }.count, slugs.count)
    }

    /// Each stage with its skills marked done, the next skill marked current, and the rest not started.
    static func stages(of role: Role, done: Set<String>) -> [StageSummary] {
        let next = nextSkill(in: role, done: done)

        return role.stages.enumerated().map { index, stage in
            let steps = stage.skills.map { slug -> SkillStep in
                let state: CJStepRail.State
                if done.contains(slug) {
                    state = .done
                } else if slug == next {
                    state = .current
                } else {
                    state = .next
                }
                return SkillStep(slug: slug, state: state)
            }
            return StageSummary(number: index + 1, stage: stage, steps: steps)
        }
    }
}
