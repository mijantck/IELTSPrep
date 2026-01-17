import Foundation
import SwiftData

// MARK: - Exam Configuration
struct ExamConfig {
    // Shared UserDefaults for Widget access
    private static let sharedDefaults = UserDefaults(suiteName: "group.com.ielts.IELTSPrep") ?? UserDefaults.standard

    // User configurable exam date - stored in both standard and shared UserDefaults
    static var examDate: Date {
        get {
            // Try shared defaults first (for widget compatibility)
            if let savedDate = sharedDefaults.object(forKey: "examDate") as? Date {
                return savedDate
            }
            // Fallback to standard defaults
            if let savedDate = UserDefaults.standard.object(forKey: "examDate") as? Date {
                return savedDate
            }
            // Default: 3 months from now
            return Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        }
        set {
            // Save to both for compatibility
            UserDefaults.standard.set(newValue, forKey: "examDate")
            sharedDefaults.set(newValue, forKey: "examDate")
        }
    }

    static var targetBand: Double {
        get {
            let shared = sharedDefaults.double(forKey: "targetBand")
            if !shared.isZero { return shared }
            let standard = UserDefaults.standard.double(forKey: "targetBand")
            return standard.isZero ? 7.0 : standard
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "targetBand")
            sharedDefaults.set(newValue, forKey: "targetBand")
        }
    }

    static let currentLevel: Int = 3
}

// MARK: - Daily Task Model
@Model
final class DailyTask {
    var id: UUID
    var title: String
    var taskDescription: String
    var category: String // listening, reading, writing, speaking, grammar, vocabulary
    var duration: Int // minutes
    var isCompleted: Bool
    var date: Date
    var createdAt: Date

    init(title: String, description: String, category: String, duration: Int, date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.taskDescription = description
        self.category = category
        self.duration = duration
        self.isCompleted = false
        self.date = date
        self.createdAt = Date()
    }
}

// MARK: - Vocabulary Word Model
@Model
final class VocabularyWord {
    var id: UUID
    var word: String
    var meaning: String
    var example: String
    var partOfSpeech: String
    var isLearned: Bool
    var reviewCount: Int
    var nextReviewDate: Date
    var addedAt: Date

    init(word: String, meaning: String, example: String, partOfSpeech: String) {
        self.id = UUID()
        self.word = word
        self.meaning = meaning
        self.example = example
        self.partOfSpeech = partOfSpeech
        self.isLearned = false
        self.reviewCount = 0
        self.nextReviewDate = Date()
        self.addedAt = Date()
    }
}

// MARK: - Writing Practice Model
@Model
final class WritingPractice {
    var id: UUID
    var topic: String
    var taskType: String // task1, task2
    var userEssay: String
    var grammarErrors: [String]
    var feedback: String
    var estimatedBand: Double
    var createdAt: Date

    init(topic: String, taskType: String) {
        self.id = UUID()
        self.topic = topic
        self.taskType = taskType
        self.userEssay = ""
        self.grammarErrors = []
        self.feedback = ""
        self.estimatedBand = 0.0
        self.createdAt = Date()
    }
}

// MARK: - API Response Models
struct LanguageToolResponse: Codable {
    let matches: [GrammarMatch]
}

struct GrammarMatch: Codable, Identifiable {
    var id: UUID { UUID() }
    let message: String
    let shortMessage: String?
    let replacements: [Replacement]
    let offset: Int
    let length: Int
    let rule: Rule

    struct Replacement: Codable {
        let value: String
    }

    struct Rule: Codable {
        let id: String
        let description: String
        let category: Category
    }

    struct Category: Codable {
        let id: String
        let name: String
    }
}

struct DatamuseWord: Codable, Identifiable {
    var id: UUID { UUID() }
    let word: String
    let score: Int?
    let defs: [String]?
    let tags: [String]?
}

// MARK: - IELTS Writing Topics
struct WritingTopics {
    static let task2Topics = [
        "Some people believe that technology has made our lives too complex. To what extent do you agree or disagree?",
        "The increase in mobile phone use in recent years has transformed the way we live. What are the positive and negative effects of this trend?",
        "Some people think that governments should spend money on railways rather than roads. To what extent do you agree or disagree?",
        "In many countries, plastic shopping bags are the main source of rubbish. They should be banned. Do you agree or disagree?",
        "Some people believe that children should be taught how to manage money at school. Do you agree or disagree?",
        "Many people believe that social networking sites have had a huge negative impact on society. To what extent do you agree?",
        "Some people think that the best way to reduce crime is to give longer prison sentences. Others believe there are better ways. Discuss both views.",
        "Climate change is a major global problem. What are the causes and what solutions can you suggest?",
        "Some people believe that unpaid community service should be a compulsory part of high school. Do you agree or disagree?",
        "In some countries, young people are encouraged to work or travel for a year between finishing school and starting university. Discuss the advantages and disadvantages."
    ]

    static func randomTopic() -> String {
        task2Topics.randomElement() ?? task2Topics[0]
    }
}
