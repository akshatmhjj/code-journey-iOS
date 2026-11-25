import Foundation
import SwiftData

/// The role the person is working towards. Only one path exists at a time.
/// Choosing a new path deletes the old record, so the skill progress stays and counts only where it overlaps.
@Model
final class PathSelection {
    /// The slug of the chosen role, such as "ios-engineer".
    @Attribute(.unique) var roleSlug: String
    /// When the person chose this path.
    var startedAt: Date

    init(roleSlug: String, startedAt: Date = .now) {
        self.roleSlug = roleSlug
        self.startedAt = startedAt
    }
}
