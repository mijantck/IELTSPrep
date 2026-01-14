import Foundation

// MARK: - API Service (Free APIs)
class APIService {
    static let shared = APIService()
    private init() {}

    // MARK: - LanguageTool API (FREE - Grammar Check)
    func checkGrammar(text: String) async throws -> [GrammarMatch] {
        let urlString = "https://api.languagetool.org/v2/check"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = "text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&language=en-US"
        request.httpBody = parameters.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }

        let result = try JSONDecoder().decode(LanguageToolResponse.self, from: data)
        return result.matches
    }

    // MARK: - Datamuse API (FREE - Vocabulary)
    func getRelatedWords(word: String) async throws -> [DatamuseWord] {
        let urlString = "https://api.datamuse.com/words?ml=\(word)&md=dp&max=10"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([DatamuseWord].self, from: data)
    }

    // MARK: - Get IELTS Vocabulary (Common words)
    func fetchIELTSVocabulary() async throws -> [VocabularyWord] {
        // Common IELTS academic vocabulary
        let ieltsWords = [
            ("abundant", "existing in large quantities", "Natural resources are abundant in this region.", "adjective"),
            ("accumulate", "to gather or collect over time", "Students accumulate knowledge through years of study.", "verb"),
            ("acknowledge", "to accept or admit the truth", "Scientists acknowledge the impact of climate change.", "verb"),
            ("adapt", "to adjust to new conditions", "Species must adapt to survive in changing environments.", "verb"),
            ("adequate", "enough or sufficient", "The funding was adequate for the research project.", "adjective"),
            ("advocate", "to publicly support", "Many groups advocate for environmental protection.", "verb"),
            ("affect", "to have an influence on", "Social media can affect mental health.", "verb"),
            ("allocate", "to distribute for a purpose", "Governments allocate resources to education.", "verb"),
            ("alternative", "another choice or option", "Solar power is an alternative to fossil fuels.", "noun"),
            ("analyze", "to examine in detail", "Researchers analyze data to draw conclusions.", "verb"),
            ("approach", "a way of dealing with something", "A new approach to learning was implemented.", "noun"),
            ("appropriate", "suitable for a purpose", "Formal language is appropriate in academic writing.", "adjective"),
            ("assess", "to evaluate or estimate", "Teachers assess student progress regularly.", "verb"),
            ("assume", "to suppose without proof", "We cannot assume that the trend will continue.", "verb"),
            ("attitude", "a way of thinking or feeling", "A positive attitude helps in learning.", "noun"),
            ("benefit", "an advantage or profit", "Exercise has many health benefits.", "noun"),
            ("challenge", "a difficult task", "Climate change is a global challenge.", "noun"),
            ("circumstance", "a condition or situation", "Economic circumstances affect education access.", "noun"),
            ("complex", "consisting of many parts", "The human brain is a complex organ.", "adjective"),
            ("component", "a part of a larger whole", "Trust is a key component of relationships.", "noun"),
            ("concept", "an abstract idea", "The concept of democracy varies globally.", "noun"),
            ("conclude", "to bring to an end", "The study concluded that exercise improves health.", "verb"),
            ("consequence", "a result or effect", "Pollution has severe consequences for health.", "noun"),
            ("considerable", "notably large", "There has been considerable progress in technology.", "adjective"),
            ("consistent", "unchanging; reliable", "Consistent effort leads to improvement.", "adjective"),
            ("contribute", "to give or add", "Everyone can contribute to environmental protection.", "verb"),
            ("controversy", "prolonged public disagreement", "The policy sparked controversy among experts.", "noun"),
            ("crucial", "of great importance", "Education is crucial for development.", "adjective"),
            ("demonstrate", "to show clearly", "The experiment demonstrates the theory.", "verb"),
            ("derive", "to obtain from a source", "Many medicines derive from natural plants.", "verb")
        ]

        return ieltsWords.map { VocabularyWord(word: $0.0, meaning: $0.1, example: $0.2, partOfSpeech: $0.3) }
    }

    // MARK: - Simple Writing Feedback (Rule-based - FREE)
    func getWritingFeedback(essay: String, grammarErrors: [GrammarMatch]) -> (feedback: String, estimatedBand: Double) {
        let wordCount = essay.split(separator: " ").count
        let sentenceCount = essay.components(separatedBy: CharacterSet(charactersIn: ".!?")).filter { !$0.isEmpty }.count
        let paragraphCount = essay.components(separatedBy: "\n\n").filter { !$0.isEmpty }.count
        let errorCount = grammarErrors.count

        var feedback = ""
        var bandScore: Double = 5.0

        // Word count analysis
        if wordCount < 150 {
            feedback += "⚠️ Word count too low (\(wordCount) words). Aim for 250+ words for Task 2.\n\n"
            bandScore -= 1.0
        } else if wordCount >= 250 && wordCount <= 300 {
            feedback += "✅ Good word count (\(wordCount) words).\n\n"
            bandScore += 0.5
        } else if wordCount > 300 {
            feedback += "✅ Excellent word count (\(wordCount) words).\n\n"
            bandScore += 0.5
        }

        // Structure analysis
        if paragraphCount < 4 {
            feedback += "⚠️ Essay structure needs improvement. Use 4-5 paragraphs: Introduction, 2-3 Body paragraphs, Conclusion.\n\n"
            bandScore -= 0.5
        } else {
            feedback += "✅ Good paragraph structure (\(paragraphCount) paragraphs).\n\n"
            bandScore += 0.5
        }

        // Grammar errors
        if errorCount == 0 {
            feedback += "✅ No grammar errors detected!\n\n"
            bandScore += 1.0
        } else if errorCount <= 3 {
            feedback += "⚠️ Minor grammar issues (\(errorCount) errors). Review and fix them.\n\n"
        } else if errorCount <= 7 {
            feedback += "⚠️ Several grammar errors (\(errorCount) errors). Focus on grammar practice.\n\n"
            bandScore -= 0.5
        } else {
            feedback += "❌ Many grammar errors (\(errorCount) errors). Grammar needs significant improvement.\n\n"
            bandScore -= 1.0
        }

        // Average sentence length
        let avgSentenceLength = wordCount / max(sentenceCount, 1)
        if avgSentenceLength < 10 {
            feedback += "💡 Tip: Your sentences are too short. Try using complex sentences.\n\n"
        } else if avgSentenceLength > 25 {
            feedback += "💡 Tip: Some sentences may be too long. Break them into smaller sentences.\n\n"
        } else {
            feedback += "✅ Good sentence variety.\n\n"
            bandScore += 0.5
        }

        // Clamp band score
        bandScore = max(4.0, min(8.0, bandScore))

        // Band score interpretation
        feedback += "📊 Estimated Band Score: \(String(format: "%.1f", bandScore))\n\n"

        if bandScore < 5.5 {
            feedback += "Focus Areas:\n• Grammar fundamentals\n• Vocabulary expansion\n• Essay structure"
        } else if bandScore < 6.5 {
            feedback += "Focus Areas:\n• Complex sentences\n• Topic-specific vocabulary\n• Coherence and cohesion"
        } else {
            feedback += "Keep practicing! You're on track for Band 7+.\n• Focus on academic vocabulary\n• Practice varied sentence structures"
        }

        return (feedback, bandScore)
    }
}

// MARK: - API Errors
enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed

    var message: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .requestFailed: return "Request failed. Check internet connection."
        case .decodingFailed: return "Failed to process response"
        }
    }
}
