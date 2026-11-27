import Foundation

/// A skill found in a job post, with how often it was named and where it first appears.
struct JobPostFound: Identifiable, Hashable {
    let slug: String
    let mentions: Int
    /// Where the skill first appears in the text, as a character offset.
    let first: Int

    var id: String { slug }
}

/// A role that the job post looks like, with how well the skills fit.
struct JobPostRoleFit: Identifiable, Hashable {
    let slug: String
    let title: String
    let shared: Int
    let fit: Double

    var id: String { slug }
}

struct JobPostAnalysis {
    let found: [JobPostFound]
    /// Technologies the post names that Code Journey does not teach yet.
    let notCovered: [String]
    let roles: [JobPostRoleFit]
}

/// Finds Code Journey skills in pasted text. A port of the website's `gap.ts`, so the same post
/// gives the same skills on the site and in the app. Runs on the phone; the text is never sent anywhere.
enum JobPostAnalyser {
    private struct Matcher {
        let key: String
        let isOther: Bool
        let regex: NSRegularExpression
    }

    private struct Span {
        let key: String
        let isOther: Bool
        let start: Int
        let end: Int
    }

    static func analyse(_ data: JobGapData, text: String) -> JobPostAnalysis {
        let spans = matchSpans(in: text, data: data)
        let kept = keepLongest(spans)

        // Count each skill, in the order the skills first appear.
        var order: [String] = []
        var mentions: [String: Int] = [:]
        var first: [String: Int] = [:]
        var others = Set<String>()

        for span in kept {
            if span.isOther {
                others.insert(span.key)
                continue
            }
            if mentions[span.key] == nil {
                order.append(span.key)
                mentions[span.key] = 0
                first[span.key] = span.start
            }
            mentions[span.key, default: 0] += 1
            first[span.key] = min(first[span.key] ?? span.start, span.start)
        }

        let found = order
            .enumerated()
            .map { index, slug in (index, JobPostFound(slug: slug, mentions: mentions[slug] ?? 0, first: first[slug] ?? 0)) }
            .sorted { a, b in
                if a.1.first != b.1.first { return a.1.first < b.1.first }
                return a.0 < b.0
            }
            .map(\.1)

        let roles = rankRoles(data: data, found: found, text: text)

        return JobPostAnalysis(found: found, notCovered: others.sorted(), roles: roles)
    }

    /// Order skills to learn: the ones that need nothing first, then the ones the post names most.
    static func learningOrder(_ data: JobGapData, slugs: [String], mentions: [String: Int]) -> [String] {
        let bySlug = Dictionary(data.skills.map { ($0.slug, $0) }, uniquingKeysWith: { first, _ in first })
        var cache: [String: Int] = [:]

        func depth(_ slug: String, _ seen: inout Set<String>) -> Int {
            if let known = cache[slug] { return known }
            if seen.contains(slug) { return 0 }
            seen.insert(slug)
            let prereqs = bySlug[slug]?.prereqs ?? []
            let value = prereqs.isEmpty ? 0 : 1 + prereqs.map { depth($0, &seen) }.max()!
            cache[slug] = value
            return value
        }

        return slugs.sorted { a, b in
            var seenA = Set<String>()
            var seenB = Set<String>()
            let depthA = depth(a, &seenA)
            let depthB = depth(b, &seenB)
            if depthA != depthB { return depthA < depthB }
            let mentionsA = mentions[a] ?? 0
            let mentionsB = mentions[b] ?? 0
            if mentionsA != mentionsB { return mentionsA > mentionsB }
            return a < b
        }
    }

    // MARK: - Matching

    private static func matchSpans(in text: String, data: JobGapData) -> [Span] {
        let matchers = compile(data)
        let whole = NSRange(text.startIndex..., in: text)
        var spans: [Span] = []

        for matcher in matchers {
            for match in matcher.regex.matches(in: text, range: whole) {
                spans.append(Span(
                    key: matcher.key,
                    isOther: matcher.isOther,
                    start: match.range.location,
                    end: match.range.location + match.range.length
                ))
            }
        }
        return spans
    }

    /// Longest match wins: "React Native" should not also count as React.
    /// A match is dropped only when it sits strictly inside a longer match for a different skill.
    private static func keepLongest(_ spans: [Span]) -> [Span] {
        let sorted = spans
            .enumerated()
            .sorted { a, b in
                let lengthA = a.element.end - a.element.start
                let lengthB = b.element.end - b.element.start
                if lengthA != lengthB { return lengthA > lengthB }
                return a.offset < b.offset
            }
            .map(\.element)

        var kept: [Span] = []
        for span in sorted {
            let inside = kept.contains { other in
                other.key != span.key
                    && other.start <= span.start
                    && other.end >= span.end
                    && (other.end - other.start) > (span.end - span.start)
            }
            if !inside {
                kept.append(span)
            }
        }
        return kept
    }

    private static func compile(_ data: JobGapData) -> [Matcher] {
        var matchers: [Matcher] = []
        for entry in data.matchers {
            for phrase in entry.phrases {
                if let matcher = makeMatcher(key: entry.slug, isOther: false, phrase: phrase) {
                    matchers.append(matcher)
                }
            }
        }
        for entry in data.notCovered {
            for phrase in entry.phrases {
                if let matcher = makeMatcher(key: entry.name, isOther: true, phrase: phrase) {
                    matchers.append(matcher)
                }
            }
        }
        return matchers
    }

    private static func makeMatcher(key: String, isOther: Bool, phrase: String) -> Matcher? {
        let sensitive = phrase.hasPrefix("=")
        let core = sensitive ? String(phrase.dropFirst()) : phrase
        // Whole words only: no letter, digit, + or # on either side, so "sql" misses "mysql" and "c" misses "c#".
        // A leading "." is blocked too, so "js" does not fire inside "node.js". An optional plural is allowed.
        let pattern = "(?<![A-Za-z0-9+#.])\(pattern(for: core))(?:s|es)?(?![A-Za-z0-9+#])"
        let options: NSRegularExpression.Options = sensitive ? [] : [.caseInsensitive]
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        return Matcher(key: key, isOther: isOther, regex: regex)
    }

    /// Turns a phrase into a regex: special characters escaped, and any run of spaces matching any spacing.
    private static func pattern(for phrase: String) -> String {
        phrase
            .split(whereSeparator: \.isWhitespace)
            .map { NSRegularExpression.escapedPattern(for: String($0)) }
            .joined(separator: "\\s+")
    }

    // MARK: - Roles

    private static func rankRoles(data: JobGapData, found: [JobPostFound], text: String) -> [JobPostRoleFit] {
        let foundSet = Set(found.map(\.slug))
        let lower = text.lowercased()

        let scored = data.roles.map { role -> JobPostRoleFit in
            let shared = role.route.filter { foundSet.contains($0) }.count
            let named = role.names.contains { name in
                let pattern = "(?<![a-z])\(self.pattern(for: name.lowercased()))(?![a-z])"
                guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
                return regex.firstMatch(in: lower, range: NSRange(lower.startIndex..., in: lower)) != nil
            }
            let overlap = found.isEmpty || role.route.isEmpty
                ? 0
                : Double(shared) / sqrt(Double(found.count) * Double(role.route.count))
            let fit = overlap + (named ? 0.25 : 0)
            return JobPostRoleFit(slug: role.slug, title: role.title, shared: shared, fit: fit)
        }

        return scored
            .enumerated()
            .filter { $0.element.shared >= 2 }
            .sorted { a, b in
                if a.element.fit != b.element.fit { return a.element.fit > b.element.fit }
                return a.offset < b.offset
            }
            .prefix(3)
            .map(\.element)
    }
}
