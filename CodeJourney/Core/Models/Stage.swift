import Foundation

/// One stage of a role's route, such as Foundations or Core.
struct Stage: Codable, Hashable, Identifiable {
    let name: String
    let summary: String
    /// The slugs of the skills this stage teaches, such as "git" or "how-the-internet-works".
    let skills: [String]
    let project: String
    let doneWhen: String
    /// How long the stage usually takes, for example "8–12". Some stages have no estimate.
    let weeks: String?

    /// Stage names are unique within a role, so the name doubles as the ID.
    var id: String { name }
}
