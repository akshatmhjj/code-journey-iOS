import Foundation
import SwiftData

/// Makes a role the person's path. Used from the role page and from the Compass result.
enum PathChooser {
    /// Replaces any existing path with this role. Skill progress stays where it is.
    static func choose(roleSlug: String, existing: [PathSelection], in context: ModelContext) {
        for path in existing {
            context.delete(path)
        }
        context.insert(PathSelection(roleSlug: roleSlug))
    }
}
