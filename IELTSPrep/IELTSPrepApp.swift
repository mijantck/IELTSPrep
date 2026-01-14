import SwiftUI
import SwiftData

@main
struct IELTSPrepApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DailyTask.self, VocabularyWord.self, WritingPractice.self])
    }
}
