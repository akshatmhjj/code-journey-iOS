import Foundation

/// One stage of a role's route, such as Foundations or Core.
struct Stage: Identifiable, Codable, Hashable {
    let name: String
    let summary: String
    /// IDs of the skills this stage teaches. Skill details come in a later step.
    let skillIDs: [String]
    let project: String
    let doneWhen: String
    /// How long the stage usually takes, for example "8–12". Some stages have no estimate.
    let weeks: String?

    /// Stage names are unique within a role, so the name doubles as the ID.
    var id: String { name }
}
