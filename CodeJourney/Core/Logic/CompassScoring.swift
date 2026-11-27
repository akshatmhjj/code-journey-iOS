import Foundation

/// A role the quiz suggests, with the answers that pointed to it.
struct CompassMatch: Identifiable, Hashable {
    let slug: String
    let score: Int
    /// The highest score this role could get from the questions. Used so that roles
    /// which appear in many answers do not win on volume alone.
    let maxScore: Int
    /// Up to three reasons, strongest first. Each one completes "Because you…".
    let reasons: [String]

    var id: String { slug }
}

/// Turns the answers to the Compass quiz into a ranked list of roles.
/// It follows the website's rules step for step, so both show the same roles in the same order,
/// including the order of exact ties.
enum CompassScoring {
    /// Ranks every role the questions can suggest. `answers[i]` is the option index picked for `questions[i]`.
    /// Roles are ranked by score divided by the square root of their maximum, then by match percentage.
    /// Any remaining tie keeps the order in which the roles first appear in the quiz.
    static func rank(questions: [CompassQuestion], answers: [Int]) -> [CompassMatch] {
        let (order, maxima) = maxScores(for: questions)

        var scores: [String: Int] = [:]
        var pulls: [String: [(share: Double, weight: Int, why: String)]] = [:]

        for (index, question) in questions.enumerated() where index < answers.count {
            let answer = answers[index]
            guard question.options.indices.contains(answer) else { continue }
            let option = question.options[answer]
            let total = option.weights.reduce(0) { $0 + $1.weight }

            for entry in option.weights {
                scores[entry.role, default: 0] += entry.weight
                // How much of this answer's pull goes to this role. An answer that points mostly at one role says more about it.
                let share = total > 0 ? Double(entry.weight) / Double(total) : 0
                pulls[entry.role, default: []].append((share, entry.weight, option.why))
            }
        }

        let matches = order.map { role in
            let strongest = (pulls[role] ?? [])
                .enumerated()
                .sorted { a, b in
                    if a.element.share != b.element.share { return a.element.share > b.element.share }
                    if a.element.weight != b.element.weight { return a.element.weight > b.element.weight }
                    return a.offset < b.offset
                }
                .prefix(3)
                .map(\.element.why)

            return CompassMatch(
                slug: role,
                score: scores[role] ?? 0,
                maxScore: maxima[role] ?? 0,
                reasons: Array(strongest)
            )
        }

        // Sort, keeping the original order for exact ties.
        return matches.enumerated()
            .sorted { a, b in
                let aValue = rankValue(a.element)
                let bValue = rankValue(b.element)
                if aValue != bValue { return aValue > bValue }

                let aPercent = percent(a.element)
                let bPercent = percent(b.element)
                if aPercent != bPercent { return aPercent > bPercent }

                return a.offset < b.offset
            }
            .map(\.element)
    }

    /// The most each role can earn across all questions, counting only its best option per question.
    /// Also returns the roles in the order they first appear, which is how ties are broken.
    static func maxScores(for questions: [CompassQuestion]) -> (order: [String], maxima: [String: Int]) {
        var order: [String] = []
        var maxima: [String: Int] = [:]

        for question in questions {
            var best: [String: Int] = [:]
            var bestOrder: [String] = []

            for option in question.options {
                for entry in option.weights {
                    if let current = best[entry.role] {
                        best[entry.role] = max(current, entry.weight)
                    } else {
                        best[entry.role] = entry.weight
                        bestOrder.append(entry.role)
                    }
                }
            }

            for role in bestOrder {
                if maxima[role] == nil {
                    order.append(role)
                    maxima[role] = 0
                }
                maxima[role, default: 0] += best[role] ?? 0
            }
        }

        return (order, maxima)
    }

    private static func rankValue(_ match: CompassMatch) -> Double {
        Double(match.score) / sqrt(Double(max(match.maxScore, 1)))
    }

    private static func percent(_ match: CompassMatch) -> Int {
        Int((Double(match.score) / Double(max(match.maxScore, 1)) * 100).rounded())
    }
}
