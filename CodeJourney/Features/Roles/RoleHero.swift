import SwiftUI

/// The top of the role page: a climb drawn across the screen, then the role's name.
/// Each camp on the climb is one stage of the route.
struct RoleHero: View {
    let role: Role
    let domainName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            ClimbGraphic(stageCount: role.stages.count)
                .frame(height: 190)
                .accessibilityHidden(true)

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

/// A line that climbs from the bottom left to the top right, with a numbered camp for each stage.
/// The line draws itself when the page opens. Reduce Motion shows it at once.
struct ClimbGraphic: View {
    let stageCount: Int

    @State private var progress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            let points = camps(in: geometry.size)

            ZStack {
                ClimbLine(points: points)
                    .trim(from: 0, to: progress)
                    .stroke(
                        CJColor.accent,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                    )

                ForEach(points.indices, id: \.self) { index in
                    camp(number: index + 1, isFirst: index == 0)
                        .position(points[index])
                        .opacity(progress >= fraction(for: index) ? 1 : 0.25)
                }
            }
            .onAppear {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 1.4)) {
                    progress = 1
                }
            }
        }
    }

    private func camp(number: Int, isFirst: Bool) -> some View {
        Circle()
            .fill(isFirst ? CJColor.accent : CJColor.canvas)
            .overlay {
                Circle().strokeBorder(CJColor.accent, lineWidth: 3)
            }
            .overlay {
                Text("\(number)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isFirst ? CJColor.onAccent : CJColor.accent)
            }
            .frame(width: 34, height: 34)
    }

    /// Where each camp sits, spread from the bottom left to the top right with room at the edges.
    private func camps(in size: CGSize) -> [CGPoint] {
        let inset: CGFloat = 24
        guard stageCount > 1 else {
            return stageCount == 1 ? [CGPoint(x: size.width / 2, y: size.height / 2)] : []
        }
        return (0..<stageCount).map { index in
            let t = CGFloat(index) / CGFloat(stageCount - 1)
            let x = inset + t * (size.width - 2 * inset)
            let y = (size.height - inset) - t * (size.height - 2 * inset)
            return CGPoint(x: x, y: y)
        }
    }

    /// How far along the line a camp is, from 0 to 1, so it lights up as the line reaches it.
    private func fraction(for index: Int) -> Double {
        Double(index) / Double(max(stageCount - 1, 1))
    }
}

/// The straight segments that join the camps, as a shape that `trim` can draw partway.
struct ClimbLine: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
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
