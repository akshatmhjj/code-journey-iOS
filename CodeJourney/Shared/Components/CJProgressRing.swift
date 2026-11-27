import SwiftUI

/// A circle that fills as you progress, with the percentage in the middle.
struct CJProgressRing: View {
    /// From 0 to 1. Values outside that range are clamped.
    let progress: Double
    var size: CGFloat = 56
    var lineWidth: CGFloat = 6
    var tint: Color = CJColor.accent

    private var clamped: Double {
        min(max(progress, 0), 1)
    }

    private var percent: Int {
        Int((clamped * 100).rounded())
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(CJColor.surfaceRaised, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clamped)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(percent)%")
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(CJColor.ink)
        }
        .frame(width: size, height: size)
        .animation(.snappy, value: clamped)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(percent) percent")
    }
}

#Preview("Light") {
    ringPreview
}

#Preview("Dark") {
    ringPreview
        .preferredColorScheme(.dark)
}

private var ringPreview: some View {
    HStack(spacing: CJSpace.l) {
        CJProgressRing(progress: 0)
        CJProgressRing(progress: 0.5)
        CJProgressRing(progress: 1, tint: CJColor.success)
    }
    .padding(CJSpace.l)
    .background(CJColor.canvas)
}
