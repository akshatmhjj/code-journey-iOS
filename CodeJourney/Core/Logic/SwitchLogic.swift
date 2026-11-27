import Foundation

/// A tech role that a starting job bridges to, with the skills the person may already have.
struct Bridge: Identifiable, Hashable {
    let slug: String
    let title: String
    /// Skills on the role's route that the job often gives already, in route order.
    let have: [String]
    /// Everything else on the route, in route order.
    let toLearn: [String]
    /// The first stage that still has something to learn, or nil if nothing is left.
    let startAt: String?
    /// The share of the route the job covers, from 0 to 1.
    let share: Double

    var id: String { slug }
}

/// Finds the tech roles closest to a starting job. Follows the website's rules exactly.
enum SwitchLogic {
    /// The roles that share at least one skill with the job, closest first.
    /// Closest means the fewest skills still to learn, then the biggest share, then the title.
    static func bridges(for job: SwitchJob, roles: [Role], limit: Int = 3) -> [Bridge] {
        let mine = Set(job.skills)

        let bridges = roles.map { role -> Bridge in
            let route = PathProgress.skillSlugs(in: role)
            let have = route.filter { mine.contains($0) }
            let toLearn = route.filter { !mine.contains($0) }
            let startAt = role.stages.first { stage in
                stage.skills.contains { !mine.contains($0) }
            }?.name
            let share = route.isEmpty ? 0 : Double(have.count) / Double(route.count)

            return Bridge(slug: role.slug, title: role.title, have: have, toLearn: toLearn, startAt: startAt, share: share)
        }

        let withSomething = bridges.filter { !$0.have.isEmpty }

        return Array(
            withSomething
                .enumerated()
                .sorted { a, b in
                    if a.element.toLearn.count != b.element.toLearn.count {
                        return a.element.toLearn.count < b.element.toLearn.count
                    }
                    if a.element.share != b.element.share {
                        return a.element.share > b.element.share
                    }
                    if a.element.title != b.element.title {
                        return a.element.title.localizedCompare(b.element.title) == .orderedAscending
                    }
                    return a.offset < b.offset
                }
                .map(\.element)
                .prefix(limit)
        )
    }
}
