import SwiftUI

/// Pay by role, for India and the US. Every figure comes from a public source, and each role
/// links to the page it came from. Each bar shows the average. A lighter band shows the
/// 10th to 90th percentile, where the source gives one.
struct PayScreen: View {
    enum Market: String, CaseIterable, Identifiable {
        case india = "India"
        case us = "US"

        var id: String { rawValue }
    }

    /// One role's figures, shaped the same way for both markets.
    struct Row: Identifiable {
        let id: String
        let name: String
        /// The average (India) or median (US), in the bar's units.
        let value: Double
        /// The text shown beside the bar, such as "₹6.65 L" or "$135,980".
        let valueText: String
        /// The 10th and 90th percentile. Only India has them.
        let low: Double?
        let high: Double?
        let detail: String
        let exact: Bool
        let sourceTitle: String
        let sourceURL: URL
        let sourceDate: String?
        let closestTitle: String
    }

    @Environment(ContentStore.self) private var content
    @State private var market: Market = .india

    private static let isoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xxl) {
                CJSectionHeader(eyebrow: checkedLabel, title: "What the work pays")

                Picker("Market", selection: $market) {
                    ForEach(Market.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                if rows.isEmpty {
                    CJCard {
                        Text("No published figure for this market yet.")
                            .font(CJFont.body)
                            .foregroundStyle(CJColor.inkSecondary)
                    }
                } else {
                    barCard
                    sourceList
                }

                footnote
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Pay by role")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Bars

    private var barCard: some View {
        VStack(alignment: .leading, spacing: CJSpace.l) {
            Text(market == .india ? "Average, with the 10th to 90th percentile shaded" : "Median pay")
                .font(CJFont.caption)
                .tracking(0.6)
                .foregroundStyle(CJColor.inkSecondary)

            ForEach(rows) { row in
                PayBar(row: row, scale: scale)
            }
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    // MARK: - Sources

    private var sourceList: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            CJSectionHeader(title: "Where each figure comes from")

            ForEach(rows) { row in
                VStack(alignment: .leading, spacing: CJSpace.s) {
                    Text(row.name)
                        .font(CJFont.headline)
                        .foregroundStyle(CJColor.ink)

                    Text(row.detail)
                        .font(CJFont.callout)
                        .foregroundStyle(CJColor.inkSecondary)

                    if !row.exact {
                        Text("Closest title on the source: \(row.closestTitle)")
                            .font(CJFont.caption)
                            .foregroundStyle(CJColor.warning)
                    }

                    CJSourceChip(name: row.sourceTitle, url: row.sourceURL, date: row.sourceDate.map(displayDate))
                }
                .padding(CJSpace.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                        .fill(CJColor.surface)
                )
            }
        }
    }

    private var footnote: some View {
        VStack(alignment: .leading, spacing: CJSpace.xs) {
            if market == .india {
                Text("PayScale rounds its top band, so treat the 90th percentile as about. Figures are self-reported salaries.")
            } else {
                Text("US figures are the Bureau of Labor Statistics median for May 2025. Several roles share one BLS job title, so they show the same figure.")
            }
            Text("\(missingCount) roles have no published figure for this market yet.")
        }
        .font(CJFont.caption)
        .foregroundStyle(CJColor.inkSecondary)
    }

    // MARK: - Data

    private var checkedLabel: String {
        if let checked = content.payChecked {
            return "Checked \(displayDate(checked))"
        }
        return "Public sources"
    }

    /// The largest figure on screen, so every bar is drawn on the same scale.
    private var scale: Double {
        rows.map { $0.high ?? $0.value }.max() ?? 1
    }

    private var rows: [Row] {
        content.roles.compactMap { role -> Row? in
            guard let pay = role.pay else { return nil }

            switch market {
            case .india:
                guard let india = pay.india else { return nil }
                let detail = "10th to 90th percentile ₹\(format(india.p10)) L to about ₹\(format(india.p90)) L · \(india.profiles) profiles"
                return Row(
                    id: role.slug,
                    name: role.title,
                    value: india.avg,
                    valueText: "₹\(format(india.avg)) L",
                    low: india.p10,
                    high: india.p90,
                    detail: detail,
                    exact: india.exact,
                    sourceTitle: "PayScale",
                    sourceURL: india.url,
                    sourceDate: india.updated,
                    closestTitle: india.title
                )

            case .us:
                guard let us = pay.us else { return nil }
                let median = us.median.formatted(.currency(code: "USD").precision(.fractionLength(0)))
                let detail = "\(format(us.growth))% projected job growth, 2025 to 2035"
                return Row(
                    id: role.slug,
                    name: role.title,
                    value: Double(us.median) / 1000,
                    valueText: median,
                    low: nil,
                    high: nil,
                    detail: detail,
                    exact: us.exact,
                    sourceTitle: "US Bureau of Labor Statistics",
                    sourceURL: us.url,
                    sourceDate: nil,
                    closestTitle: us.title
                )
            }
        }
        .sorted { $0.value > $1.value }
    }

    private var missingCount: Int {
        content.roles.filter { role in
            switch market {
            case .india: role.pay?.india == nil
            case .us: role.pay?.us == nil
            }
        }.count
    }

    private func format(_ number: Double) -> String {
        number.formatted(.number.precision(.fractionLength(0...2)))
    }

    /// "2026-11-02" becomes "2 Nov 2026". Falls back to the raw text if it is not a date.
    private func displayDate(_ iso: String) -> String {
        guard let date = Self.isoDate.date(from: iso) else { return iso }
        return date.formatted(.dateTime.day().month(.abbreviated).year())
    }
}

/// One role's bar: its name and value on top, and the bar below.
/// The light band behind the bar shows the range. The bar grows in when the screen opens.
private struct PayBar: View {
    let row: PayScreen.Row
    let scale: Double

    @State private var grown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: CJSpace.xs) {
            HStack(alignment: .firstTextBaseline, spacing: CJSpace.s) {
                Text(row.name)
                    .font(CJFont.headline)
                    .foregroundStyle(CJColor.ink)
                Spacer(minLength: CJSpace.s)
                Text(row.valueText)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(CJColor.ink)
            }

            GeometryReader { geometry in
                let width = geometry.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CJColor.surfaceRaised)

                    if let low = row.low, let high = row.high {
                        Capsule()
                            .fill(CJColor.accent.opacity(0.3))
                            .frame(width: width * (high - low) / scale)
                            .offset(x: width * low / scale)
                    }

                    Capsule()
                        .fill(CJColor.accent)
                        .frame(width: width * (grown ? row.value : 0) / scale)
                }
            }
            .frame(height: 12)
        }
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.7)) {
                grown = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(row.name)
        .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        if let low = row.low, let high = row.high {
            return "\(row.valueText), range \(low) to \(high)"
        }
        return row.valueText
    }
}

#Preview {
    NavigationStack {
        PayScreen()
    }
    .environment(ContentStore())
}
