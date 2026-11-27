import SwiftUI
import SwiftData

/// The glossary: every term in plain English, grouped by letter, with search and a way into flashcards.
struct GlossaryScreen: View {
    @Environment(ContentStore.self) private var content
    @State private var query = ""

    var body: some View {
        Group {
            if filteredSections.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List {
                    ForEach(filteredSections, id: \.letter) { group in
                        Section {
                            ForEach(group.terms) { term in
                                NavigationLink {
                                    GlossaryTermScreen(term: term)
                                } label: {
                                    VStack(alignment: .leading, spacing: CJSpace.xxs) {
                                        Text(term.term)
                                            .font(CJFont.headline)
                                            .foregroundStyle(CJColor.ink)
                                        Text(term.definition)
                                            .font(CJFont.callout)
                                            .foregroundStyle(CJColor.inkSecondary)
                                            .lineLimit(2)
                                    }
                                    .padding(.vertical, CJSpace.xxs)
                                }
                                .listRowBackground(CJColor.surface)
                            }
                        } header: {
                            Text(group.letter)
                                .font(CJFont.caption)
                                .tracking(0.6)
                                .foregroundStyle(CJColor.inkSecondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Glossary")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Search terms")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    FlashcardsScreen()
                } label: {
                    Label("Practise", systemImage: "rectangle.stack")
                }
            }
        }
    }

    private struct LetterGroup: Identifiable {
        let letter: String
        let terms: [GlossaryTerm]
        var id: String { letter }
    }

    /// The terms that match the search, grouped by their first letter, in alphabetical order.
    private var filteredSections: [LetterGroup] {
        let matching = content.glossaryTerms.filter { matches($0) }
        let grouped = Dictionary(grouping: matching, by: \.letter)
        return grouped.keys.sorted().map { letter in
            LetterGroup(letter: letter, terms: grouped[letter] ?? [])
        }
    }

    /// Every word in the search must appear in the term or its definition. Case and accents are ignored.
    private func matches(_ term: GlossaryTerm) -> Bool {
        let words = query
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: \.isWhitespace)
        guard !words.isEmpty else { return true }
        let text = (term.term + " " + term.definition)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
        return words.allSatisfy { text.contains($0) }
    }
}

/// One term on its own: the name, its category and the full definition.
struct GlossaryTermScreen: View {
    let term: GlossaryTerm

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.l) {
                Text(term.category.uppercased())
                    .font(CJFont.caption)
                    .tracking(0.8)
                    .foregroundStyle(CJColor.accent)

                Text(term.term)
                    .font(CJFont.largeTitle)
                    .foregroundStyle(CJColor.ink)

                Text(term.definition)
                    .font(CJFont.body)
                    .foregroundStyle(CJColor.ink)
                    .padding(CJSpace.l)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                            .fill(CJColor.surface)
                    )
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(term.term)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GlossaryScreen()
    }
    .environment(ContentStore())
    .modelContainer(for: [GlossaryKnown.self], inMemory: true)
}
