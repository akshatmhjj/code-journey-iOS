import Foundation

/// Every screen that can be pushed onto a tab's navigation stack.
/// A new screen adds a case here. The role and skill screens arrive in later steps,
/// so nothing pushes these cases yet.
enum Route: Hashable {
    case role(id: String)
    case skill(id: String)
}
