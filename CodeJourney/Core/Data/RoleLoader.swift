import Foundation

/// Loads the bundled role data from `roles.json`.
enum RoleLoader {
    enum LoadError: LocalizedError {
        case fileNotFound

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "The roles data file is missing from the app."
            }
        }
    }

    static func loadRoles(from bundle: Bundle = .main) throws -> [Role] {
        guard let url = bundle.url(forResource: "roles", withExtension: "json") else {
            throw LoadError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Role].self, from: data)
    }
}
