import SwiftUI

/// Chips in a grid that wraps onto a new line when there is no room left on the current one.
struct CJChipWrap: View {
    let chips: [CJChip]

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 120), spacing: CJSpace.xs, alignment: .leading)],
            alignment: .leading,
            spacing: CJSpace.xs
        ) {
            ForEach(chips.indices, id: \.self) { index in
                chips[index]
            }
        }
    }
}

#Preview {
    CJChipWrap(chips: [
        CJChip(title: "Git", tone: .accent),
        CJChip(title: "Command line"),
        CJChip(title: "How the internet works"),
        CJChip(title: "Swift")
    ])
    .padding(CJSpace.l)
    .background(CJColor.canvas)
}
