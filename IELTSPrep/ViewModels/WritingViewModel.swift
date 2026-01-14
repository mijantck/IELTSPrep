import Foundation
import SwiftUI
import SwiftData

@MainActor
class WritingViewModel: ObservableObject {
    @Published var currentTopic: String = ""
    @Published var userEssay: String = ""
    @Published var grammarErrors: [GrammarMatch] = []
    @Published var feedback: String = ""
    @Published var estimatedBand: Double = 0.0
    @Published var isChecking: Bool = false
    @Published var wordCount: Int = 0
    @Published var showResults: Bool = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    init() {
        generateNewTopic()
    }

    func generateNewTopic() {
        currentTopic = WritingTopics.randomTopic()
        resetEssay()
    }

    func resetEssay() {
        userEssay = ""
        grammarErrors = []
        feedback = ""
        estimatedBand = 0.0
        wordCount = 0
        showResults = false
        errorMessage = nil
    }

    func updateWordCount() {
        wordCount = userEssay.split(separator: " ").filter { !$0.isEmpty }.count
    }

    func checkEssay() async {
        guard !userEssay.isEmpty else {
            errorMessage = "Please write something first!"
            return
        }

        isChecking = true
        errorMessage = nil

        do {
            // Check grammar with LanguageTool API (FREE)
            grammarErrors = try await apiService.checkGrammar(text: userEssay)

            // Get feedback based on analysis
            let result = apiService.getWritingFeedback(essay: userEssay, grammarErrors: grammarErrors)
            feedback = result.feedback
            estimatedBand = result.estimatedBand

            showResults = true
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }

        isChecking = false
    }

    func saveProgress(modelContext: ModelContext) {
        let practice = WritingPractice(topic: currentTopic, taskType: "task2")
        practice.userEssay = userEssay
        practice.grammarErrors = grammarErrors.map { $0.message }
        practice.feedback = feedback
        practice.estimatedBand = estimatedBand

        modelContext.insert(practice)

        do {
            try modelContext.save()
        } catch {
            print("Error saving writing practice: \(error)")
        }
    }

    func getErrorHighlights() -> [(range: Range<String.Index>, message: String)] {
        var highlights: [(Range<String.Index>, String)] = []

        for error in grammarErrors {
            let start = userEssay.index(userEssay.startIndex, offsetBy: min(error.offset, userEssay.count - 1), limitedBy: userEssay.endIndex) ?? userEssay.startIndex
            let end = userEssay.index(start, offsetBy: min(error.length, userEssay.count - error.offset), limitedBy: userEssay.endIndex) ?? start

            if start < end {
                highlights.append((start..<end, error.message))
            }
        }

        return highlights
    }
}
