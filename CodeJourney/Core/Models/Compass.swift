import Foundation

/// One question in the Compass quiz, with the answers the person can pick from.
struct CompassQuestion: Codable, Hashable, Identifiable {
    let id: String
    let q: String
    let options: [CompassOption]
}

/// One answer. `weights` says how strongly it points to each role.
/// `why` completes the sentence "Because you…" under a suggested role.
struct CompassOption: Codable, Hashable {
    let label: String
    let why: String
    let weights: [RoleWeight]
}

/// How strongly one answer points to one role. Kept as a list, so the order from the content file is kept.
struct RoleWeight: Codable, Hashable {
    let role: String
    let weight: Int
}
