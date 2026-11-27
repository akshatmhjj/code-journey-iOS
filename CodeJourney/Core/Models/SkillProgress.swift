import Foundation
import SwiftData

/// What the person has done on one skill. Saved on the phone with SwiftData, so it survives a restart.
/// There is one record per skill, created the first time the person ticks something.
@Model
final class SkillProgress {
    /// The skill this record belongs to. Unique, so a skill never has two records.
    @Attribute(.unique) var skillSlug: String
    /// The checklist topics the person has ticked, by topic name.
    var checkedTopics: [String]
    /// When the person marked the skill done. Nil while it is not done.
    var completedAt: Date?

    init(skillSlug: String) {
        self.skillSlug = skillSlug
        self.checkedTopics = []
        self.completedAt = nil
    }

    var isDone: Bool { completedAt != nil }
}
