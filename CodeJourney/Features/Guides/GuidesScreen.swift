import SwiftUI

/// Guides and blog posts from the website, newest first. Tap one to read it.
struct GuidesScreen: View {
    @Environment(ContentStore.self) private var content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.m) {
                CJSectionHeader(eyebrow: "\(content.blogPosts.count) posts", title: "Guides and blog")

                ForEach(content.blogPosts) { post in
                    NavigationLink {
                        BlogPostScreen(post: post)
                    } label: {
                        postCard(post)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Guides")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func postCard(_ post: BlogPost) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            HStack(spacing: CJSpace.s) {
                CJChip(title: post.tag, tone: .accent)
                Text("\(post.readTime) read")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }

            Text(post.title)
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)
                .multilineTextAlignment(.leading)

            Text(post.excerpt)
                .font(CJFont.callout)
                .foregroundStyle(CJColor.inkSecondary)
                .lineLimit(3)
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }
}

/// One post, drawn block by block: headings, paragraphs, lists and code.
struct BlogPostScreen: View {
    let post: BlogPost

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.l) {
                Text("\(post.tag.uppercased()) · \(post.readTime) READ")
                    .font(CJFont.caption)
                    .tracking(0.8)
                    .foregroundStyle(CJColor.accent)

                Text(post.title)
                    .font(CJFont.largeTitle)
                    .foregroundStyle(CJColor.ink)

                ForEach(Array(MarkdownBlocks.parse(post.body).enumerated()), id: \.offset) { _, block in
                    blockView(block)
                }

                Text("Published \(post.date)")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func blockView(_ block: MarkdownBlock) -> some View {
        switch block {
        case .heading(let level, let text):
            Text(text)
                .font(level <= 2 ? CJFont.title : CJFont.headline)
                .foregroundStyle(CJColor.ink)
                .padding(.top, CJSpace.s)

        case .paragraph(let text):
            Text(inline(text))
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)

        case .bullets(let items):
            VStack(alignment: .leading, spacing: CJSpace.s) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: CJSpace.s) {
                        Text("•")
                            .foregroundStyle(CJColor.accent)
                        Text(inline(item))
                            .font(CJFont.body)
                            .foregroundStyle(CJColor.ink)
                    }
                }
            }

        case .code(let text):
            ScrollView(.horizontal) {
                Text(text)
                    .font(CJFont.code)
                    .foregroundStyle(CJColor.ink)
                    .padding(CJSpace.m)
            }
            .background(
                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                    .fill(CJColor.surfaceRaised)
            )
        }
    }

    /// Bold, italic, links and inline code. Falls back to plain text if the Markdown is not valid.
    private func inline(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
}

#Preview {
    NavigationStack {
        GuidesScreen()
    }
    .environment(ContentStore())
}
