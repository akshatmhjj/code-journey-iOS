import Foundation

/// One block of a post: a heading, a paragraph, a bullet list or a code sample.
enum MarkdownBlock: Hashable {
    case heading(level: Int, text: String)
    case paragraph(String)
    case bullets([String])
    case code(String)
}

/// Splits the website's Markdown into blocks the app can draw. It handles the forms the posts use:
/// headings, paragraphs, bullet lists, fenced code and horizontal rules. Inline bold, links and code are
/// left to `AttributedString(markdown:)` when the block is drawn.
enum MarkdownBlocks {
    static func parse(_ body: String) -> [MarkdownBlock] {
        let lines = body.components(separatedBy: "\n")
        var blocks: [MarkdownBlock] = []
        var index = 0

        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)

            if line.isEmpty || line == "---" || line == "***" {
                index += 1
            } else if line.hasPrefix("```") {
                var code: [String] = []
                index += 1
                while index < lines.count, !lines[index].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    code.append(lines[index])
                    index += 1
                }
                index += 1 // skip the closing fence
                blocks.append(.code(code.joined(separator: "\n")))
            } else if let heading = heading(from: line) {
                blocks.append(heading)
                index += 1
            } else if isBullet(line) {
                var items: [String] = []
                while index < lines.count, isBullet(lines[index].trimmingCharacters(in: .whitespaces)) {
                    items.append(String(lines[index].trimmingCharacters(in: .whitespaces).dropFirst(2)))
                    index += 1
                }
                blocks.append(.bullets(items))
            } else {
                var paragraph: [String] = []
                while index < lines.count {
                    let next = lines[index].trimmingCharacters(in: .whitespaces)
                    if next.isEmpty || next.hasPrefix("```") || next == "---" || heading(from: next) != nil || isBullet(next) {
                        break
                    }
                    paragraph.append(next)
                    index += 1
                }
                blocks.append(.paragraph(paragraph.joined(separator: " ")))
            }
        }

        return blocks
    }

    private static func heading(from line: String) -> MarkdownBlock? {
        let level = line.prefix { $0 == "#" }.count
        guard (1...6).contains(level) else { return nil }
        let text = line.dropFirst(level).trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return nil }
        return .heading(level: level, text: text)
    }

    private static func isBullet(_ line: String) -> Bool {
        line.hasPrefix("- ") || line.hasPrefix("* ")
    }
}
