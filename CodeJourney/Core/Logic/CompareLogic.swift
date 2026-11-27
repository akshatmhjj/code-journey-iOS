import Foundation

/// How two roles differ, skill by skill.
struct Comparison {
    /// Skills both roles need.
    let shared: [String]
    /// Skills only the first role needs.
    let onlyFirst: [String]
    /// Skills only the second role needs.
    let onlySecond: [String]
}

/// Compares two roles. Pure logic, following the website's rules.
enum CompareLogic {
    /// Every skill a role touches: its stages first, then its must, should and nice-to-have skills.
    static func route(of role: Role) -> [String] {
        var seen = Set<String>()
        let all = role.stages.flatMap(\.skills)
            + role.skills.must + role.skills.should + role.skills.nice
        return all.filter { seen.insert($0).inserted }
    }

    static func compare(_ first: Role, _ second: Role) -> Comparison {
        let firstRoute = route(of: first)
        let secondRoute = route(of: second)
        let firstSet = Set(firstRoute)
        let secondSet = Set(secondRoute)

        return Comparison(
            shared: firstRoute.filter { secondSet.contains($0) },
            onlyFirst: firstRoute.filter { !secondSet.contains($0) },
            onlySecond: secondRoute.filter { !firstSet.contains($0) }
        )
    }

    /// The time to be job-ready: the first three stages added up, turned into months.
    /// Returns "Varies" when no stage gives a time.
    static func jobReady(of role: Role) -> String {
        let pattern = try? NSRegularExpression(pattern: #"(\d+)\D+(\d+)"#)
        var low = 0
        var high = 0

        for stage in role.stages.prefix(3) {
            guard let weeks = stage.weeks,
                  let pattern,
                  let match = pattern.firstMatch(in: weeks, range: NSRange(weeks.startIndex..., in: weeks)),
                  let lowRange = Range(match.range(at: 1), in: weeks),
                  let highRange = Range(match.range(at: 2), in: weeks),
                  let lowValue = Int(weeks[lowRange]),
                  let highValue = Int(weeks[highRange])
            else { continue }
            low += lowValue
            high += highValue
        }

        guard high > 0 else { return "Varies" }
        let lowMonths = Int((Double(low) / 4.3).rounded())
        let highMonths = Int((Double(high) / 4.3).rounded())
        return "\(lowMonths)–\(highMonths) months"
    }
}
