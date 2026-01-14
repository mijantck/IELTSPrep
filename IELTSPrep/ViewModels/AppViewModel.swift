import Foundation
import SwiftUI
import SwiftData

@MainActor
class AppViewModel: ObservableObject {
    @Published var daysRemaining: Int = 0
    @Published var todaysTasks: [DailyTask] = []
    @Published var completedTasksCount: Int = 0
    @Published var overallProgress: Double = 0.0
    @Published var currentStreak: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let examDate = ExamConfig.examDate

    init() {
        calculateDaysRemaining()
    }

    func calculateDaysRemaining() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: examDate)
        daysRemaining = max(0, components.day ?? 0)
    }

    func generateDailyTasks(modelContext: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if tasks already exist for today
        let descriptor = FetchDescriptor<DailyTask>(
            predicate: #Predicate { task in
                task.date >= today
            }
        )

        do {
            let existingTasks = try modelContext.fetch(descriptor)
            if !existingTasks.isEmpty {
                todaysTasks = existingTasks
                updateProgress()
                return
            }
        } catch {
            print("Error fetching tasks: \(error)")
        }

        // Generate new tasks for today
        let tasks = [
            DailyTask(
                title: "Grammar Practice",
                description: "Complete grammar exercises using LanguageTool",
                category: "grammar",
                duration: 30,
                date: today
            ),
            DailyTask(
                title: "Learn 10 New Words",
                description: "Study IELTS vocabulary with examples",
                category: "vocabulary",
                duration: 20,
                date: today
            ),
            DailyTask(
                title: "Writing Task 2",
                description: "Write a 250-word essay on today's topic",
                category: "writing",
                duration: 45,
                date: today
            ),
            DailyTask(
                title: "Reading Practice",
                description: "Read and answer questions from a passage",
                category: "reading",
                duration: 30,
                date: today
            ),
            DailyTask(
                title: "Listening Exercise",
                description: "Listen to audio and practice note-taking",
                category: "listening",
                duration: 25,
                date: today
            )
        ]

        for task in tasks {
            modelContext.insert(task)
        }

        do {
            try modelContext.save()
            todaysTasks = tasks
        } catch {
            print("Error saving tasks: \(error)")
        }
    }

    func toggleTaskCompletion(task: DailyTask, modelContext: ModelContext) {
        task.isCompleted.toggle()
        do {
            try modelContext.save()
            updateProgress()
        } catch {
            print("Error updating task: \(error)")
        }
    }

    func updateProgress() {
        let total = todaysTasks.count
        let completed = todaysTasks.filter { $0.isCompleted }.count
        completedTasksCount = completed
        overallProgress = total > 0 ? Double(completed) / Double(total) : 0
    }

    func getMotivationalMessage() -> String {
        let messages = [
            "তুমি পারবে! Every small step counts! 💪",
            "Band 7 is achievable with consistent practice!",
            "Focus on your weaknesses today!",
            "\(daysRemaining) days left - Make each day count!",
            "Grammar + Vocabulary = Better Writing!",
            "Practice makes progress, not perfection!",
            "You're closer to your goal than yesterday!"
        ]
        return messages.randomElement() ?? messages[0]
    }

    func getCategoryIcon(for category: String) -> String {
        switch category {
        case "grammar": return "text.badge.checkmark"
        case "vocabulary": return "book.fill"
        case "writing": return "pencil.and.outline"
        case "reading": return "doc.text.fill"
        case "listening": return "headphones"
        case "speaking": return "mic.fill"
        default: return "star.fill"
        }
    }

    func getCategoryColor(for category: String) -> Color {
        switch category {
        case "grammar": return .blue
        case "vocabulary": return .purple
        case "writing": return .orange
        case "reading": return .green
        case "listening": return .pink
        case "speaking": return .red
        default: return .gray
        }
    }
}
