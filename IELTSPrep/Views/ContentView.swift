import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            FocusModeView()
                .tabItem {
                    Label("Focus", systemImage: "brain.head.profile")
                }

            MockTestView()
                .tabItem {
                    Label("Tests", systemImage: "doc.text.fill")
                }

            LessonsView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.blue)
        .onAppear {
            viewModel.generateDailyTasks(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailyTask.self, VocabularyWord.self, WritingPractice.self], inMemory: true)
}
