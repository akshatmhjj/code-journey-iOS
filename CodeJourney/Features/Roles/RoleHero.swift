import SwiftUI

/// The top of the role page: a mountain scene with the route winding up to the peak,
/// then the role's name and summary underneath.
struct RoleHero: View {
    let role: Role
    let domainName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.l) {
            RoleIllustration(stageCount: role.stages.count)
                .frame(height: 300)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: CJSpace.s) {
                if let domainName {
                    Text(domainName.uppercased())
                        .font(CJFont.caption)
                        .tracking(0.8)
                        .foregroundStyle(CJColor.accent)
                }

                Text(role.title)
                    .font(CJFont.largeTitle)
                    .foregroundStyle(CJColor.ink)

                if !role.aliases.isEmpty {
                    Text("Also called \(role.aliases.joined(separator: ", "))")
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)
                }

                Text(role.summary)
                    .font(CJFont.body)
                    .foregroundStyle(CJColor.ink)
            }
        }
    }
}

/// The scene: two mountain ranges, a sun, a winding route and one camp per stage.
/// Everything is drawn in the theme's foreground colour, so it works in light and dark mode.
struct RoleIllustration: View {
    let stageCount: Int

    @State private var progress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let backRange: [CGPoint] = [
        CGPoint(x: 0, y: 0.62), CGPoint(x: 0.22, y: 0.38), CGPoint(x: 0.45, y: 0.52),
        CGPoint(x: 0.70, y: 0.22), CGPoint(x: 0.90, y: 0.44), CGPoint(x: 1, y: 0.36)
    ]

    private let frontRange: [CGPoint] = [
        CGPoint(x: 0, y: 0.82), CGPoint(x: 0.20, y: 0.66), CGPoint(x: 0.42, y: 0.80),
        CGPoint(x: 0.62, y: 0.60), CGPoint(x: 0.84, y: 0.78), CGPoint(x: 1, y: 0.70)
    ]

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let camps = Self.campPositions(count: stageCount)
            let absolute = camps.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }

            ZStack {
                LinearGradient(
                    colors: [CJColor.accent, CJColor.accent.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(CJColor.onAccent.opacity(0.18))
                    .frame(width: size.width * 0.34)
                    .position(x: size.width * 0.8, y: size.height * 0.2)

                MountainShape(peaks: backRange)
                    .fill(CJColor.onAccent.opacity(0.16))

                MountainShape(peaks: frontRange)
                    .fill(CJColor.onAccent.opacity(0.26))

                RouteShape(camps: camps)
                    .trim(from: 0, to: progress)
                    .stroke(
                        CJColor.onAccent,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [1, 9])
                    )

                ForEach(absolute.indices, id: \.self) { index in
                    camp(number: index + 1)
                        .position(absolute[index])
                        .opacity(progress >= Self.fraction(for: index, of: stageCount) ? 1 : 0)
                }

                if let peak = absolute.last {
                    Image(systemName: "flag.fill")
                        .font(.title3)
                        .foregroundStyle(CJColor.onAccent)
                        .position(x: peak.x, y: peak.y - 36)
                        .opacity(progress >= 1 ? 1 : 0)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous))
            .onAppear {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 1.6)) {
                    progress = 1
                }
            }
        }
    }

    private func camp(number: Int) -> some View {
        Circle()
            .fill(CJColor.canvas)
            .overlay {
                Text("\(number)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CJColor.accent)
            }
            .frame(width: 30, height: 30)
            .shadow(color: CJColor.ink.opacity(0.2), radius: 4, y: 2)
    }

    /// Camp positions as fractions of the scene, from the bottom left up to the top right.
    static func campPositions(count: Int) -> [CGPoint] {
        guard count > 1 else {
            return count == 1 ? [CGPoint(x: 0.5, y: 0.5)] : []
        }
        return (0..<count).map { index in
            let t = CGFloat(index) / CGFloat(count - 1)
            let x = 0.14 + 0.72 * t
            let y = 0.84 - 0.58 * t - 0.05 * sin(t * .pi)
            return CGPoint(x: x, y: y)
        }
    }

    /// Where a camp sits along the route, from 0 to 1, so it appears as the line reaches it.
    static func fraction(for index: Int, of count: Int) -> Double {
        Double(index) / Double(max(count - 1, 1))
    }
}

/// A mountain range: a filled outline through the given peaks, down to the bottom edge.
/// Points are fractions of the shape's size, so the shape scales with its container.
struct MountainShape: Shape {
    let peaks: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        for peak in peaks {
            path.addLine(to: CGPoint(x: rect.minX + peak.x * rect.width, y: rect.minY + peak.y * rect.height))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// The route: smooth arcs that join the camps, so the climb looks like a trail, not a straight line.
/// Camps are fractions of the shape's size.
struct RouteShape: Shape {
    let camps: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = camps.map { CGPoint(x: rect.minX + $0.x * rect.width, y: rect.minY + $0.y * rect.height) }
        guard let first = points.first else { return path }

        path.move(to: first)
        for index in 1..<points.count {
            let from = points[index - 1]
            let to = points[index]
            let control = CGPoint(x: (from.x + to.x) / 2, y: min(from.y, to.y) - rect.height * 0.08)
            path.addQuadCurve(to: to, control: control)
        }
        return path
    }
}

#Preview {
    RoleHero(
        role: ContentStore().roles.first!,
        domainName: "Mobile"
    )
    .padding(CJSpace.l)
    .background(CJColor.canvas)
}
