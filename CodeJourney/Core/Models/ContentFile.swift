import Foundation

/// The whole of `content.json`, the file the build script writes from the website's content.
/// Only the app's decoder uses this type. Screens use `ContentStore` instead.
struct ContentFile: Codable {
    let version: Int
    let generatedAt: String
    let domains: [Domain]
    let roles: [Role]
    let skills: [Skill]
    let resources: [Resource]
}
