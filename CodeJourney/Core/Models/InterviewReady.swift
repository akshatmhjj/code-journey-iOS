import Foundation
import SwiftData

/// A practice question the person has marked as ready. Saved on the phone with SwiftData.
/// A record exists only while the question is marked ready, so unmarking deletes it.
@Model
final class InterviewReady {
    /// The question's identity, such as "dbms:3". Unique, so it can only be marked once.
    @Attribute(.unique) var questionID: String
    /// When the person marked it ready.
    var readyAt: Date

    init(questionID: String, readyAt: Date = .now) {
        self.questionID = questionID
        self.readyAt = readyAt
    }
}
