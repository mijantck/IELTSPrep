import Foundation
import SwiftUI
import SwiftData

@MainActor
class VocabularyViewModel: ObservableObject {
    @Published var dailyWords: [VocabularyWord] = []
    @Published var currentWordIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var showMeaning: Bool = false
    @Published var learnedCount: Int = 0
    @Published var quizMode: Bool = false
    @Published var quizScore: Int = 0
    @Published var quizTotal: Int = 0
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    var currentWord: VocabularyWord? {
        guard currentWordIndex < dailyWords.count else { return nil }
        return dailyWords[currentWordIndex]
    }

    var progress: Double {
        guard !dailyWords.isEmpty else { return 0 }
        return Double(currentWordIndex) / Double(dailyWords.count)
    }

    func loadDailyWords(modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil

        do {
            // First try to fetch from local storage
            let descriptor = FetchDescriptor<VocabularyWord>(
                predicate: #Predicate { word in
                    !word.isLearned
                },
                sortBy: [SortDescriptor(\.addedAt)]
            )

            var words = try modelContext.fetch(descriptor)

            // If no words in storage, fetch from API service
            if words.isEmpty {
                let fetchedWords = try await apiService.fetchIELTSVocabulary()
                for word in fetchedWords {
                    modelContext.insert(word)
                }
                try modelContext.save()
                words = fetchedWords
            }

            // Take 10 words for today
            dailyWords = Array(words.prefix(10))
            currentWordIndex = 0
            learnedCount = 0

        } catch {
            errorMessage = "Failed to load vocabulary. Please try again."
        }

        isLoading = false
    }

    func nextWord() {
        showMeaning = false
        if currentWordIndex < dailyWords.count - 1 {
            currentWordIndex += 1
        }
    }

    func previousWord() {
        showMeaning = false
        if currentWordIndex > 0 {
            currentWordIndex -= 1
        }
    }

    func markAsLearned(modelContext: ModelContext) {
        guard let word = currentWord else { return }
        word.isLearned = true
        word.reviewCount += 1
        word.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

        do {
            try modelContext.save()
            learnedCount += 1
            nextWord()
        } catch {
            print("Error marking word as learned: \(error)")
        }
    }

    func toggleMeaning() {
        showMeaning.toggle()
    }

    // Quiz functionality
    func startQuiz() {
        quizMode = true
        quizScore = 0
        quizTotal = 0
        dailyWords.shuffle()
        currentWordIndex = 0
    }

    func submitQuizAnswer(isCorrect: Bool) {
        quizTotal += 1
        if isCorrect {
            quizScore += 1
        }
        if currentWordIndex < dailyWords.count - 1 {
            currentWordIndex += 1
        } else {
            quizMode = false
        }
    }

    func endQuiz() {
        quizMode = false
        currentWordIndex = 0
    }

    func getRandomOptions(for word: VocabularyWord) -> [String] {
        var options = [word.meaning]
        let otherWords = dailyWords.filter { $0.word != word.word }

        for otherWord in otherWords.shuffled().prefix(3) {
            options.append(otherWord.meaning)
        }

        return options.shuffled()
    }
}
