import Foundation

/// Roles that belong under one domain heading on the Explore screen.
struct DomainGroup: Identifiable {
    /// Nil for roles whose domain is not in the content, shown under "Other".
    let domain: Domain?
    let roles: [Role]

    var id: String { domain?.slug ?? "other" }
    var title: String { domain?.name ?? "Other" }
}

/// Pure logic for searching and grouping roles. No SwiftUI here, so it is easy to test.
enum RoleSearch {
    /// True when every word in the query appears in the role's title, aliases or summary.
    /// Case and accents are ignored, so "data" matches "Dáta" and "DATA".
    static func matches(_ role: Role, query: String) -> Bool {
        let words = normalised(query).split(separator: " ").map(String.init)
        guard !words.isEmpty else { return true }

        let text = normalised(([role.title, role.summary] + role.aliases).joined(separator: " "))
        return words.allSatisfy { text.contains($0) }
    }

    /// The roles that match the query, grouped by domain in the order the domains are listed.
    /// Domains with no matching roles are left out.
    static func groups(roles: [Role], domains: [Domain], query: String) -> [DomainGroup] {
        let matching = roles.filter { matches($0, query: query) }
        let knownSlugs = Set(domains.map(\.slug))

        var groups: [DomainGroup] = domains.compactMap { domain in
            let inDomain = matching.filter { $0.domain == domain.slug }
            return inDomain.isEmpty ? nil : DomainGroup(domain: domain, roles: inDomain)
        }

        let other = matching.filter { role in
            guard let slug = role.domain else { return true }
            return !knownSlugs.contains(slug)
        }
        if !other.isEmpty {
            groups.append(DomainGroup(domain: nil, roles: other))
        }
        return groups
    }

    /// Lower case, no accents, and extra spaces removed, so comparisons are fair.
    private static func normalised(_ text: String) -> String {
        text
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}
