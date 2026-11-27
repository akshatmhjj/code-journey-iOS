import SwiftUI

/// A vertical list of steps joined by a line, such as the skills in a stage.
/// Each step shows its state with a marker, not only with colour.
struct CJStepRail: View {
    enum State {
        case done
        case current
        case next
        case locked

        /// Read aloud by VoiceOver after the step's title.
        var spokenName: String {
            switch self {
            case .done: "Done"
            case .current: "Up next"
            case .next: "Not started"
            case .locked: "Locked"
            }
        }
    }

    struct Item: Identifiable {
        let id: String
        let title: String
        var detail: String?
        var state: State
    }

    let items: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                row(for: item, isLast: index == items.count - 1)
            }
        }
    }

    private func row(for item: Item, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: CJSpace.m) {
            VStack(spacing: 0) {
                marker(for: item.state)
                if !isLast {
                    Rectangle()
                        .fill(item.state == .done ? CJColor.success : CJColor.hairline)
                        .frame(width: 3)
                        .frame(maxHeight: .infinity)
                }
            }

            VStack(alignment: .leading, spacing: CJSpace.xxs) {
                Text(item.title)
                    .font(CJFont.headline)
                    .foregroundStyle(item.state == .locked ? CJColor.inkSecondary : CJColor.ink)
                if let detail = item.detail {
                    Text(detail)
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }
            }
            .padding(.top, CJSpace.xxs)
            .padding(.bottom, isLast ? 0 : CJSpace.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue(item.state.spokenName)
    }

    @ViewBuilder
    private func marker(for state: State) -> some View {
        switch state {
        case .done:
            Circle()
                .fill(CJColor.success)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CJColor.onAccent)
                }
                .frame(width: 28, height: 28)
        case .current:
            Circle()
                .fill(CJColor.canvas)
                .overlay {
                    Circle().strokeBorder(CJColor.accent, lineWidth: 3)
                }
                .overlay {
                    Circle().fill(CJColor.accent).frame(width: 10, height: 10)
                }
                .frame(width: 28, height: 28)
        case .next:
            Circle()
                .fill(CJColor.canvas)
                .overlay {
                    Circle().strokeBorder(CJColor.inkSecondary, lineWidth: 2)
                }
                .frame(width: 28, height: 28)
        case .locked:
            Circle()
                .fill(CJColor.surfaceRaised)
                .overlay {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(CJColor.inkSecondary)
                }
                .frame(width: 28, height: 28)
        }
    }
}

#Preview("Light") {
    railPreview
}

#Preview("Dark") {
    railPreview
        .preferredColorScheme(.dark)
}

private var railPreview: some View {
    CJStepRail(items: [
        .init(id: "html", title: "HTML", detail: "Done", state: .done),
        .init(id: "js", title: "JavaScript", detail: "Up next, 2 of 4 checks", state: .current),
        .init(id: "git", title: "Git", detail: "About 8 hours", state: .next),
        .init(id: "react", title: "React", detail: "Opens after Foundations", state: .locked)
    ])
    .padding(CJSpace.l)
    .background(CJColor.canvas)
}
