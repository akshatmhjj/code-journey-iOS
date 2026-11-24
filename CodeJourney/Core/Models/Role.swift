import Foundation

/// A tech career route, such as iOS Engineer. Matches one entry in `roles.json`.
struct Role: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let summary: String
    let whereTheyWork: String
    let stages: [Stage]
}
