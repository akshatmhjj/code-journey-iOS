import SwiftUI

/// System design: the learning paths in order, and the glossary.
struct SystemDesignScreen: View {
    @Environment(ContentStore.self) private var content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xl) {
                CJSectionHeader(eyebrow: "\(paths.count) paths", title: "System design")

                VStack(spacing: CJSpace.m) {
                    ForEach(paths) { path in
                        NavigationLink {
                            SystemDesignPathScreen(path: path)
                        } label: {
                            pathCard(path)
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink {
                    SystemDesignGlossaryScreen()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: CJSpace.xxs) {
                            Text("Glossary")
                                .font(CJFont.title)
                                .foregroundStyle(CJColor.ink)
                            Text("\(terms.count) terms for design interviews")
                                .font(CJFont.callout)
                                .foregroundStyle(CJColor.inkSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(CJColor.inkSecondary)
                    }
                    .padding(CJSpace.l)
                    .background(
                        RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                            .fill(CJColor.surface)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("System design")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var paths: [SystemDesignPath] {
        content.systemDesign?.paths ?? []
    }

    private var terms: [SystemDesignTerm] {
        content.systemDesign?.terms ?? []
    }

    private func pathCard(_ path: SystemDesignPath) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            HStack(spacing: CJSpace.s) {
                CJChip(title: path.level.capitalized, tone: .accent)
                Text("\(path.articles.count) articles")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            Text(path.title)
                .font(CJFont.title)
                .foregroundStyle(CJColor.ink)
            Text(path.outcome)
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

/// One path: what it is for, the articles in reading order, and the self-check questions.
struct SystemDesignPathScreen: View {
    let path: SystemDesignPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xl) {
                CJSectionHeader(eyebrow: path.level.capitalized, title: path.title)

                infoCard(title: "Who it is for", text: path.assumes)
                infoCard(title: "What it covers", text: path.purpose)
                infoCard(title: "You can after this", text: path.outcome)

                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(eyebrow: "In reading order", title: "Articles")
                    ForEach(path.articles) { article in
                        NavigationLink {
                            SystemDesignArticleScreen(article: article)
                        } label: {
                            articleCard(article)
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(eyebrow: "Check yourself", title: "Questions")
                    ForEach(Array(path.checks.enumerated()), id: \.offset) { _, check in
                        DisclosureGroup {
                            Text(check.a)
                                .font(CJFont.body)
                                .foregroundStyle(CJColor.ink)
                                .padding(.top, CJSpace.s)
                        } label: {
                            Text(check.q)
                                .font(CJFont.headline)
                                .foregroundStyle(CJColor.ink)
                        }
                        .padding(CJSpace.l)
                        .background(
                            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                                .fill(CJColor.surface)
                        )
                    }
                }
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(path.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoCard(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            Text(title.uppercased())
                .font(CJFont.caption)
                .tracking(1.0)
                .foregroundStyle(CJColor.inkSecondary)
            Text(text)
                .font(CJFont.body)
                .foregroundStyle(CJColor.ink)
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    private func articleCard(_ article: SystemDesignArticle) -> some View {
        VStack(alignment: .leading, spacing: CJSpace.s) {
            HStack(spacing: CJSpace.s) {
                CJChip(title: article.topic)
                Text(article.level.capitalized)
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            Text(article.title)
                .font(CJFont.headline)
                .foregroundStyle(CJColor.ink)
            Text(article.why)
                .font(CJFont.callout)
                .foregroundStyle(CJColor.inkSecondary)
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }
}

/// One article: its summary, the key points, what to read first, and the original source.
struct SystemDesignArticleScreen: View {
    let article: SystemDesignArticle

    @Environment(ContentStore.self) private var content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xl) {
                VStack(alignment: .leading, spacing: CJSpace.s) {
                    Text("\(article.topic.uppercased()) · \(article.level.uppercased())")
                        .font(CJFont.caption)
                        .tracking(0.8)
                        .foregroundStyle(CJColor.accent)
                    Text(article.title)
                        .font(CJFont.largeTitle)
                        .foregroundStyle(CJColor.ink)
                    Text(article.why)
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }

                Text(article.summary)
                    .font(CJFont.body)
                    .foregroundStyle(CJColor.ink)

                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(title: "Key points")
                    ForEach(article.points, id: \.self) { point in
                        HStack(alignment: .top, spacing: CJSpace.s) {
                            Text("•")
                                .foregroundStyle(CJColor.accent)
                            Text(point)
                                .font(CJFont.body)
                                .foregroundStyle(CJColor.ink)
                        }
                    }
                }

                if !article.needs.isEmpty {
                    VStack(alignment: .leading, spacing: CJSpace.s) {
                        Text("READ FIRST")
                            .font(CJFont.caption)
                            .tracking(1.0)
                            .foregroundStyle(CJColor.inkSecondary)
                        ForEach(article.needs, id: \.self) { id in
                            Text(content.systemDesignArticle(id: id)?.title ?? id)
                                .font(CJFont.callout)
                                .foregroundStyle(CJColor.ink)
                        }
                    }
                }

                Link(destination: article.source) {
                    HStack {
                        Text("Read the original")
                            .font(CJFont.headline)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .foregroundStyle(CJColor.onAccent)
                    .padding(.horizontal, CJSpace.l)
                    .frame(minHeight: CJLayout.buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: CJRadius.button, style: .continuous)
                            .fill(CJColor.accent)
                    )
                }

                Text("Published \(article.date)")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// The system design glossary, searchable.
struct SystemDesignGlossaryScreen: View {
    @Environment(ContentStore.self) private var content
    @State private var query = ""

    var body: some View {
        List {
            ForEach(filtered) { term in
                VStack(alignment: .leading, spacing: CJSpace.xxs) {
                    Text(term.term)
                        .font(CJFont.headline)
                        .foregroundStyle(CJColor.ink)
                    Text(term.def)
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }
                .padding(.vertical, CJSpace.xxs)
                .listRowBackground(CJColor.surface)
            }
        }
        .scrollContentBackground(.hidden)
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Design glossary")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Search terms")
    }

    private var filtered: [SystemDesignTerm] {
        let all = content.systemDesign?.terms ?? []
        let words = query
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: \.isWhitespace)
        guard !words.isEmpty else { return all }
        return all.filter { term in
            let text = (term.term + " " + term.def)
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            return words.allSatisfy { text.contains($0) }
        }
    }
}

#Preview {
    NavigationStack {
        SystemDesignScreen()
    }
    .environment(ContentStore())
}
