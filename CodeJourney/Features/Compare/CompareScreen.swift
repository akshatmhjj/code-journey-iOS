import SwiftUI

/// Compare two roles side by side: how long to be job-ready, the pay, and which skills they share.
struct CompareScreen: View {
    @Environment(ContentStore.self) private var content

    @State private var firstSlug = ""
    @State private var secondSlug = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xxl) {
                CJSectionHeader(eyebrow: "Side by side", title: "Compare two roles")

                VStack(spacing: CJSpace.s) {
                    rolePicker("Role A", selection: $firstSlug)
                    rolePicker("Role B", selection: $secondSlug)
                }

                if let first, let second, first.slug != second.slug {
                    comparison(first, second)
                } else {
                    CJCard {
                        Text("Pick two different roles to compare.")
                            .font(CJFont.body)
                            .foregroundStyle(CJColor.inkSecondary)
                    }
                }
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if firstSlug.isEmpty {
                firstSlug = content.roles.first?.slug ?? ""
            }
            if secondSlug.isEmpty {
                secondSlug = content.roles.dropFirst().first?.slug ?? ""
            }
        }
    }

    // MARK: - Pieces

    private func rolePicker(_ label: String, selection: Binding<String>) -> some View {
        HStack {
            Text(label.uppercased())
                .font(CJFont.caption)
                .tracking(1.0)
                .foregroundStyle(CJColor.inkSecondary)
            Spacer()
            Picker(label, selection: selection) {
                ForEach(content.roles) { role in
                    Text(role.title).tag(role.slug)
                }
            }
            .pickerStyle(.menu)
            .tint(CJColor.accent)
        }
        .padding(CJSpace.m)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    private func comparison(_ a: Role, _ b: Role) -> some View {
        let result = CompareLogic.compare(a, b)

        return VStack(alignment: .leading, spacing: CJSpace.xl) {
            metricsCard(a, b)

            skillSection("Shared skills", slugs: result.shared, tone: .success)
            skillSection("Only \(a.title)", slugs: result.onlyFirst, tone: .neutral)
            skillSection("Only \(b.title)", slugs: result.onlySecond, tone: .neutral)

            Text("Pay figures come from PayScale and the US Bureau of Labor Statistics. Open each role to see its sources.")
                .font(CJFont.caption)
                .foregroundStyle(CJColor.inkSecondary)
        }
    }

    private func metricsCard(_ a: Role, _ b: Role) -> some View {
        Grid(alignment: .leading, horizontalSpacing: CJSpace.l, verticalSpacing: CJSpace.m) {
            GridRow {
                Text("")
                Text(a.title)
                    .font(CJFont.headline)
                    .foregroundStyle(CJColor.accent)
                Text(b.title)
                    .font(CJFont.headline)
                    .foregroundStyle(CJColor.accent)
            }

            metricRow("Job-ready in", CompareLogic.jobReady(of: a), CompareLogic.jobReady(of: b))
            metricRow("Stages", "\(a.stages.count)", "\(b.stages.count)")
            metricRow("Skills on the route", "\(CompareLogic.route(of: a).count)", "\(CompareLogic.route(of: b).count)")
            metricRow("Interview rounds", "\(a.interview.rounds.count)", "\(b.interview.rounds.count)")
            metricRow("India average", indiaText(a), indiaText(b))
            metricRow("US median", usText(a), usText(b))
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    private func metricRow(_ label: String, _ left: String, _ right: String) -> some View {
        GridRow {
            Text(label)
                .font(CJFont.callout)
                .foregroundStyle(CJColor.inkSecondary)
            Text(left)
                .font(CJFont.headline)
                .foregroundStyle(CJColor.ink)
            Text(right)
                .font(CJFont.headline)
                .foregroundStyle(CJColor.ink)
        }
    }

    @ViewBuilder
    private func skillSection(_ title: String, slugs: [String], tone: CJChip.Tone) -> some View {
        if !slugs.isEmpty {
            VStack(alignment: .leading, spacing: CJSpace.s) {
                Text(title.uppercased())
                    .font(CJFont.caption)
                    .tracking(1.0)
                    .foregroundStyle(CJColor.inkSecondary)
                CJChipWrap(chips: slugs.map { slug in
                    CJChip(title: content.skill(slug: slug)?.title ?? slug, tone: tone)
                })
            }
        }
    }

    // MARK: - Data

    private var first: Role? {
        content.role(slug: firstSlug)
    }

    private var second: Role? {
        content.role(slug: secondSlug)
    }

    private func indiaText(_ role: Role) -> String {
        guard let india = role.pay?.india else { return "No figure" }
        return "₹\(india.avg.formatted(.number.precision(.fractionLength(0...2)))) L"
    }

    private func usText(_ role: Role) -> String {
        guard let us = role.pay?.us else { return "No figure" }
        return us.median.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
}

#Preview {
    NavigationStack {
        CompareScreen()
    }
    .environment(ContentStore())
}
