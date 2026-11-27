import Foundation

/// One interview topic, such as Databases or Data Structures and Algorithms.
struct InterviewTopic: Codable, Hashable, Identifiable {
    struct Concept: Codable, Hashable {
        let term: String
        let def: String
        /// A short line to remember the concept by. Optional.
        let hook: String?
    }

    struct Question: Codable, Hashable {
        let q: String
        let a: String
    }

    let slug: String
    let title: String
    let brief: String
    /// How to say the answer out loud in an interview.
    let say: String
    let concepts: [Concept]
    let questions: [Question]
    /// Common mistakes to avoid when answering.
    let traps: [String]
    /// When the topic was last checked, as "YYYY-MM-DD".
    let checked: String

    var id: String { slug }

    /// A question's identity across launches, such as "dbms:3". Stable as long as the content keeps its order.
    func questionID(at index: Int) -> String {
        "\(slug):\(index)"
    }
}
