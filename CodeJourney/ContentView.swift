import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            CJColor.canvas
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("CODE JOURNEY")
                    .font(CJFont.label())
                    .tracking(1.2)
                    .foregroundStyle(CJColor.ink)

                Text("The map of tech careers.")
                    .font(CJFont.display(34))
                    .foregroundStyle(CJColor.ink)

                Text("Pick a role. See every skill it takes, in the order you need them.")
                    .font(CJFont.body())
                    .foregroundStyle(CJColor.muted)

                Circle()
                    .fill(CJColor.accent)
                    .frame(width: 14, height: 14)
                    .padding(.top, 8)
            }
            .padding(24)
        }
    }
}

#Preview("Light") {
    ContentView()
}

#Preview("Dark") {
    ContentView()
        .preferredColorScheme(.dark)
}
