import SwiftUI
import SwiftData

@main struct MyApp: App {
    /// Loaded once, when the app starts. Every screen reads it from the environment.
    @State private var content = ContentStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(content)
        }
        .modelContainer(for: [SkillProgress.self, PathSelection.self, InterviewReady.self, GlossaryKnown.self])
    }
}
