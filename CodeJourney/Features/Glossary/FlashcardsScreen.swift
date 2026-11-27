import SwiftUI
import SwiftData

/// Flashcards for the glossary. Tap the card to flip it from the term to its definition,
/// then mark it as known or still learning. Known terms are saved on the phone.
struct FlashcardsScreen: View {
    @Environment(ContentStore.self) private var content
    @Environment(\.modelContext) private var context
    @Query private var known: [GlossaryKnown]

    @State private var onlyUnknown = false
    @State private var index = 0
    @State private var flipped = false

    var body: some View {
        VStack(spacing: CJSpace.l) {
            HStack {
                ProgressView(value: Double(min(index + 1, max(deck.count, 1))), total: Double(max(deck.count, 1)))
                    .tint(CJColor.accent)
                Text(progressText)
                    .font(CJFont.caption)
                    .monospacedDigit()
                    .foregroundStyle(CJColor.inkSecondary)
            }

            Toggle("Only terms I don't know yet", isOn: $onlyUnknown)
                .font(CJFont.callout)
                .tint(CJColor.accent)
                .onChange(of: onlyUnknown) {
                    index = 0
                    flipped = false
                }

            if let card = currentCard {
                flashcard(card)
                actions(for: card)
            } else {
                CJCard {
                    Text("Nothing left to practise")
                        .font(CJFont.title)
                        .foregroundStyle(CJColor.ink)
                    Text("You have marked every term as known. Turn off the filter to go through them all again.")
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.inkSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(CJLayout.sideMargin)
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: index)
    }

    // MARK: - Card

    private func flashcard(_ term: GlossaryTerm) -> some View {
        Button {
            withAnimation(.snappy) {
                flipped.toggle()
            }
        } label: {
            VStack(spacing: CJSpace.l) {
                Text(flipped ? "DEFINITION" : "TERM")
                    .font(CJFont.caption)
                    .tracking(1.0)
                    .foregroundStyle(CJColor.inkSecondary)

                if flipped {
                    Text(term.definition)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)
                        .multilineTextAlignment(.center)
                } else {
                    Text(term.term)
                        .font(CJFont.largeTitle)
                        .foregroundStyle(CJColor.ink)
                        .multilineTextAlignment(.center)
                }

                Text(flipped ? "Tap to see the term" : "Tap to see the definition")
                    .font(CJFont.caption)
                    .foregroundStyle(CJColor.inkSecondary)
            }
            .padding(CJSpace.xl)
            .frame(maxWidth: .infinity, minHeight: 360)
            .background(
                RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                    .fill(CJColor.surface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                    .strokeBorder(CJColor.hairline, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Double tap to flip the card")
    }

    private func actions(for term: GlossaryTerm) -> some View {
        HStack(spacing: CJSpace.m) {
            Button("Still learning") {
                next()
            }
            .buttonStyle(.cjSecondary)

            Button(isKnown(term) ? "Known" : "I know this") {
                markKnown(term)
                next()
            }
            .buttonStyle(.cjPrimary)
        }
    }

    // MARK: - Deck

    /// The terms in the deck: all of them, or only the ones not yet known.
    private var deck: [GlossaryTerm] {
        onlyUnknown ? content.glossaryTerms.filter { !isKnown($0) } : content.glossaryTerms
    }

    private var currentCard: GlossaryTerm? {
        deck.indices.contains(index) ? deck[index] : nil
    }

    private var progressText: String {
        guard !deck.isEmpty else { return "0 of 0" }
        return "\(min(index + 1, deck.count)) of \(deck.count)"
    }

    private var knownSlugs: Set<String> {
        Set(known.map(\.termSlug))
    }

    private func isKnown(_ term: GlossaryTerm) -> Bool {
        knownSlugs.contains(term.slug)
    }

    private func next() {
        flipped = false
        if index + 1 < deck.count {
            index += 1
        } else {
            index = 0
        }
    }

    /// Marks the term known. A term that is already known is left alone.
    private func markKnown(_ term: GlossaryTerm) {
        guard !isKnown(term) else { return }
        context.insert(GlossaryKnown(termSlug: term.slug))
    }
}

#Preview {
    NavigationStack {
        FlashcardsScreen()
    }
    .environment(ContentStore())
    .modelContainer(for: [GlossaryKnown.self], inMemory: true)
}
