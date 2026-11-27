import SwiftUI

/// The route as a deck of cards you swipe through, one stage at a time.
/// The card snaps into place, a small dot shows where you are, and a light tap marks each change.
struct StageDeck: View {
    let stages: [Stage]

    @State private var focusedStage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: CJSpace.m) {
                    ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                        StageCard(number: index + 1, stage: stage)
                            .containerRelativeFrame(.horizontal) { length, _ in
                                length * 0.84
                            }
                            .scrollTransition(axis: .horizontal) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.92)
                                    .opacity(phase.isIdentity ? 1 : 0.55)
                            }
                            .id(stage.id)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, CJLayout.sideMargin, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $focusedStage)
            .scrollIndicators(.hidden)
            .sensoryFeedback(.selection, trigger: focusedStage)

            pageDots
                .padding(.horizontal, CJLayout.sideMargin)
        }
        .onAppear {
            focusedStage = stages.first?.id
        }
    }

    private var pageDots: some View {
        HStack(spacing: CJSpace.xs) {
            ForEach(stages) { stage in
                Capsule()
                    .fill(stage.id == focusedStage ? CJColor.accent : CJColor.hairline)
                    .frame(width: stage.id == focusedStage ? 22 : 8, height: 8)
            }
        }
        .animation(.snappy, value: focusedStage)
        .accessibilityHidden(true)
    }
}

#Preview {
    StageDeck(stages: ContentStore().roles.first!.stages)
        .padding(.vertical)
        .background(CJColor.canvas)
        .environment(ContentStore())
}
