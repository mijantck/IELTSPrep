import SwiftUI
import AVFoundation
import UIKit

// MARK: - Smart Translator & Grammar Lab

struct SmartTranslatorView: View {
    @State private var inputText: String = ""
    @State private var translationResult: TranslationResult?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var savedTranslations: [TranslationResult] = []
    @State private var showSavedList = false
    @State private var selectedTab = 0

    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    headerCard

                    // Input Section
                    inputSection

                    // Translate Button
                    translateButton

                    // Loading
                    if isLoading {
                        loadingView
                    }

                    // Error
                    if let error = errorMessage {
                        errorView(error)
                    }

                    // Result
                    if let result = translationResult {
                        resultView(result)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .onTapGesture {
                // Dismiss keyboard when tapping outside
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("Grammar Lab")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSavedList = true }) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showSavedList) {
                SavedTranslationsView(translations: $savedTranslations)
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "globe")
                    .font(.title)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Translator")
                        .font(.headline)
                    Text("বাংলা → English with Grammar Analysis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
            }

            // Features Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FeatureTag(icon: "text.book.closed", text: "Grammar")
                    FeatureTag(icon: "clock", text: "Tenses")
                    FeatureTag(icon: "text.quote", text: "Examples")
                    FeatureTag(icon: "star", text: "IELTS")
                    FeatureTag(icon: "speaker.wave.2", text: "Audio")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "keyboard")
                    .foregroundColor(.blue)
                Text("বাংলায় লিখুন / Type in Bengali")
                    .font(.subheadline.bold())
            }

            TextEditor(text: $inputText)
                .frame(minHeight: 100)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )

            // Example suggestions
            VStack(alignment: .leading, spacing: 8) {
                Text("Examples:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ExampleChip(text: "আমি স্কুলে যাই") { inputText = "আমি স্কুলে যাই" }
                        ExampleChip(text: "সে বই পড়ছে") { inputText = "সে বই পড়ছে" }
                        ExampleChip(text: "আমরা খেলা করব") { inputText = "আমরা খেলা করব" }
                        ExampleChip(text: "তারা গতকাল এসেছিল") { inputText = "তারা গতকাল এসেছিল" }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    // MARK: - Translate Button

    private var translateButton: some View {
        Button(action: translateText) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                }
                Text(isLoading ? "Analyzing..." : "Translate & Analyze")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(inputText.isEmpty || isLoading)
        .opacity(inputText.isEmpty ? 0.6 : 1)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("AI analyzing your sentence...")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Grammar • Tenses • Examples")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Error View

    private func errorView(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Result View

    private func resultView(_ result: TranslationResult) -> some View {
        VStack(spacing: 16) {
            // Translation Card
            translationCard(result)

            // Tabs for different sections
            Picker("Section", selection: $selectedTab) {
                Text("Structure").tag(0)
                Text("Words").tag(1)
                Text("IELTS").tag(2)
            }
            .pickerStyle(.segmented)

            switch selectedTab {
            case 0:
                structureSection(result)
            case 1:
                wordsSection(result)
            case 2:
                ieltsSection(result)
            default:
                EmptyView()
            }

            // Action Buttons
            actionButtons(result)
        }
    }

    // MARK: - Translation Card

    private func translationCard(_ result: TranslationResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Original
            HStack {
                Text("🇧🇩")
                Text(result.original)
                    .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(10)

            Image(systemName: "arrow.down")
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)

            // Translation
            HStack {
                Text("🇬🇧")
                Text(result.translation)
                    .font(.body.bold())

                Spacer()

                Button(action: { speak(result.translation) }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Structure Section

    private func structureSection(_ result: TranslationResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Sentence Structure
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(icon: "text.alignleft", title: "Sentence Structure", color: .purple)

                ForEach(result.structure, id: \.role) { part in
                    HStack(spacing: 12) {
                        Text(part.role)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(partColor(part.role))
                            .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(part.english)
                                .font(.subheadline.bold())
                            Text(part.bangla)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)

            // Grammar Rules
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(icon: "book.fill", title: "Grammar Rules Used", color: .green)

                ForEach(result.grammarRules, id: \.rule) { grammar in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(grammar.rule)
                                .font(.subheadline.bold())
                        }

                        Text(grammar.explanation)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Formula: \(grammar.formula)")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    // MARK: - Words Section

    private func wordsSection(_ result: TranslationResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(result.wordAnalysis, id: \.word) { word in
                WordAnalysisCard(word: word, speak: speak)
            }
        }
    }

    // MARK: - IELTS Section

    private func ieltsSection(_ result: TranslationResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Band Comparison
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(icon: "star.fill", title: "IELTS Band Upgrade", color: .yellow)

                // Band 6
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Band 6")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(8)

                        Text("Basic")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(result.ielts.band6)
                        .font(.subheadline)

                    Button(action: { speak(result.ielts.band6) }) {
                        Label("Listen", systemImage: "speaker.wave.2")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)

                // Band 8
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Band 8")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(8)

                        Text("Advanced")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }

                    Text(result.ielts.band8)
                        .font(.subheadline)

                    Button(action: { speak(result.ielts.band8) }) {
                        Label("Listen", systemImage: "speaker.wave.2")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)

            // Synonyms
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(icon: "text.badge.plus", title: "Better Vocabulary", color: .teal)

                ForEach(result.synonyms, id: \.original) { syn in
                    HStack {
                        Text(syn.original)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(syn.alternatives, id: \.self) { alt in
                            Text(alt)
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.teal.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    // MARK: - Action Buttons

    private func actionButtons(_ result: TranslationResult) -> some View {
        HStack(spacing: 12) {
            Button(action: { saveTranslation(result) }) {
                Label("Save", systemImage: "bookmark")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
            }

            Button(action: { shareTranslation(result) }) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Helper Functions

    private func partColor(_ role: String) -> Color {
        switch role.lowercased() {
        case "subject": return .blue
        case "verb": return .red
        case "object": return .green
        case "time": return .purple
        case "place": return .orange
        default: return .gray
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        speechSynthesizer.speak(utterance)
    }

    private func saveTranslation(_ result: TranslationResult) {
        if !savedTranslations.contains(where: { $0.original == result.original }) {
            savedTranslations.append(result)
        }
    }

    private func shareTranslation(_ result: TranslationResult) {
        let text = """
        🇧🇩 \(result.original)
        🇬🇧 \(result.translation)

        📚 Grammar: \(result.grammarRules.first?.rule ?? "")
        ⭐ IELTS Band 8: \(result.ielts.band8)

        - IELTS Prep App
        """

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    // MARK: - Translation API

    private func translateText() {
        guard !inputText.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        translationResult = nil

        Task {
            do {
                let result = try await fetchTranslation(inputText)
                await MainActor.run {
                    translationResult = result
                    isLoading = false
                }
            } catch let error as NSError {
                await MainActor.run {
                    if error.domain == "API" && error.code == 401 {
                        errorMessage = "API key not configured. Go to Settings to add your Groq API key."
                    } else {
                        errorMessage = "Translation failed: \(error.localizedDescription)"
                    }
                    isLoading = false
                    print("Translation error: \(error)")
                }
            }
        }
    }

    private func fetchTranslation(_ text: String) async throws -> TranslationResult {
        let apiKey = IELTSAPIService.shared.groqAPIKey

        guard !apiKey.isEmpty else {
            throw NSError(domain: "API", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])
        }

        let prompt = """
        You are an expert English teacher and translator. Translate the following Bengali text to English and provide a comprehensive grammar analysis.

        Bengali Text: "\(text)"

        Respond in this exact JSON format:
        {
            "translation": "English translation here",
            "structure": [
                {"role": "Subject", "english": "I", "bangla": "আমি"},
                {"role": "Verb", "english": "went", "bangla": "গিয়েছিলাম"},
                {"role": "Place", "english": "to the market", "bangla": "বাজারে"},
                {"role": "Time", "english": "yesterday", "bangla": "গতকাল"}
            ],
            "grammarRules": [
                {
                    "rule": "Past Simple Tense",
                    "explanation": "Used for completed actions in the past",
                    "formula": "Subject + V2 (past form)"
                }
            ],
            "wordAnalysis": [
                {
                    "word": "went",
                    "bangla": "গিয়েছিলাম",
                    "partOfSpeech": "Verb",
                    "baseForm": "go",
                    "tenses": {
                        "past": {
                            "sentence": "I went to school yesterday",
                            "bangla": "আমি গতকাল স্কুলে গিয়েছিলাম",
                            "formula": "Subject + went + place + time"
                        },
                        "present": {
                            "sentence": "I go to school every day",
                            "bangla": "আমি প্রতিদিন স্কুলে যাই",
                            "formula": "Subject + go/goes + place + time"
                        },
                        "future": {
                            "sentence": "I will go to school tomorrow",
                            "bangla": "আমি আগামীকাল স্কুলে যাব",
                            "formula": "Subject + will + go + place + time"
                        }
                    },
                    "examples": [
                        "She went to the doctor last week",
                        "They go to gym regularly",
                        "We will go to Paris next year"
                    ]
                }
            ],
            "ielts": {
                "band6": "Simple version of the sentence",
                "band8": "Advanced version with better vocabulary and structure"
            },
            "synonyms": [
                {"original": "went", "alternatives": ["visited", "traveled", "headed"]}
            ]
        }

        Provide detailed analysis for ALL important words. Include 3 example sentences for each word.
        """

        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "llama-3.3-70b-versatile",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 4000
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        // Check HTTP status
        if let httpResponse = response as? HTTPURLResponse {
            print("API HTTP Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("API Error: \(errorBody)")
                throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API error: \(httpResponse.statusCode)"])
            }
        }

        // Parse response
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Check for API error in response
        if let error = json?["error"] as? [String: Any] {
            let errorMessage = error["message"] as? String ?? "Unknown API error"
            throw NSError(domain: "API", code: 500, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }

        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String ?? ""

        if content.isEmpty {
            throw NSError(domain: "API", code: 500, userInfo: [NSLocalizedDescriptionKey: "Empty response from API"])
        }

        // Extract JSON from response
        return try parseTranslationResponse(content, original: text)
    }

    private func parseTranslationResponse(_ content: String, original: String) throws -> TranslationResult {
        print("Raw API response: \(content.prefix(500))")

        // Find JSON in response - handle nested braces properly
        var jsonString = content
        if let startIndex = content.firstIndex(of: "{") {
            var braceCount = 0
            var endIndex = startIndex

            for i in content.indices[startIndex...] {
                if content[i] == "{" { braceCount += 1 }
                else if content[i] == "}" {
                    braceCount -= 1
                    if braceCount == 0 {
                        endIndex = i
                        break
                    }
                }
            }
            jsonString = String(content[startIndex...endIndex])
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Parse", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON data"])
        }

        let decoder = JSONDecoder()

        do {
            let result = try decoder.decode(TranslationResponse.self, from: jsonData)

            return TranslationResult(
                original: original,
                translation: result.translation,
                structure: result.structure,
                grammarRules: result.grammarRules,
                wordAnalysis: result.wordAnalysis,
                ielts: result.ielts,
                synonyms: result.synonyms
            )
        } catch {
            print("JSON decode error: \(error)")

            // Try manual parsing as fallback
            if let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                let translation = json["translation"] as? String ?? "Translation not available"

                return TranslationResult(
                    original: original,
                    translation: translation,
                    structure: [],
                    grammarRules: [GrammarRule(rule: "Analysis pending", explanation: "Please try again", formula: "-")],
                    wordAnalysis: [],
                    ielts: IELTSVersions(band6: translation, band8: translation),
                    synonyms: []
                )
            }

            throw NSError(domain: "Parse", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response: \(error.localizedDescription)"])
        }
    }
}

// MARK: - Data Models

struct TranslationResult: Identifiable, Codable {
    let id = UUID()
    let original: String
    let translation: String
    let structure: [SentencePart]
    let grammarRules: [GrammarRule]
    let wordAnalysis: [WordAnalysis]
    let ielts: IELTSVersions
    let synonyms: [SynonymSet]

    enum CodingKeys: String, CodingKey {
        case original, translation, structure, grammarRules, wordAnalysis, ielts, synonyms
    }
}

struct TranslationResponse: Codable {
    let translation: String
    let structure: [SentencePart]
    let grammarRules: [GrammarRule]
    let wordAnalysis: [WordAnalysis]
    let ielts: IELTSVersions
    let synonyms: [SynonymSet]
}

struct SentencePart: Codable {
    let role: String
    let english: String
    let bangla: String
}

struct GrammarRule: Codable {
    let rule: String
    let explanation: String
    let formula: String
}

struct WordAnalysis: Codable {
    let word: String
    let bangla: String
    let partOfSpeech: String
    let baseForm: String
    let tenses: TenseExamples
    let examples: [String]
}

struct TenseExamples: Codable {
    let past: TenseExample
    let present: TenseExample
    let future: TenseExample
}

struct TenseExample: Codable {
    let sentence: String
    let bangla: String
    let formula: String
}

struct IELTSVersions: Codable {
    let band6: String
    let band8: String
}

struct SynonymSet: Codable {
    let original: String
    let alternatives: [String]
}

// MARK: - Supporting Views

struct FeatureTag: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(12)
    }
}

struct ExampleChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(20)
        }
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
        }
    }
}

struct WordAnalysisCard: View {
    let word: WordAnalysis
    let speak: (String) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(word.word)
                                .font(.headline)

                            Text("(\(word.partOfSpeech))")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button(action: { speak(word.word) }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }

                        Text(word.bangla)
                            .font(.subheadline)
                            .foregroundColor(.orange)

                        Text("Base form: \(word.baseForm)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()

                // Tenses
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tense Examples")
                        .font(.subheadline.bold())
                        .foregroundColor(.purple)

                    // Past
                    TenseExampleRow(
                        tense: "PAST",
                        color: .red,
                        example: word.tenses.past,
                        speak: speak
                    )

                    // Present
                    TenseExampleRow(
                        tense: "PRESENT",
                        color: .green,
                        example: word.tenses.present,
                        speak: speak
                    )

                    // Future
                    TenseExampleRow(
                        tense: "FUTURE",
                        color: .blue,
                        example: word.tenses.future,
                        speak: speak
                    )
                }

                Divider()

                // More Examples
                VStack(alignment: .leading, spacing: 8) {
                    Text("More Examples")
                        .font(.subheadline.bold())
                        .foregroundColor(.teal)

                    ForEach(word.examples, id: \.self) { example in
                        HStack {
                            Text("•")
                                .foregroundColor(.teal)
                            Text(example)
                                .font(.caption)

                            Spacer()

                            Button(action: { speak(example) }) {
                                Image(systemName: "speaker.wave.1")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TenseExampleRow: View {
    let tense: String
    let color: Color
    let example: TenseExample
    let speak: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(tense)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(color)
                    .cornerRadius(6)

                Spacer()

                Button(action: { speak(example.sentence) }) {
                    Image(systemName: "speaker.wave.2")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Text(example.sentence)
                .font(.subheadline)

            Text(example.bangla)
                .font(.caption)
                .foregroundColor(.orange)

            Text("📝 \(example.formula)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(6)
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Saved Translations View

struct SavedTranslationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var translations: [TranslationResult]

    var body: some View {
        NavigationStack {
            List {
                if translations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No saved translations")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(translations) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.original)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(item.translation)
                                .font(.body.bold())
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        translations.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("Saved Translations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Grammar Lab Card (for Learn section)

struct GrammarLabCard: View {
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: "globe")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Grammar Lab")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }

                Text("বাংলা → English with grammar breakdown")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label("Translate", systemImage: "arrow.right")
                    Label("Tenses", systemImage: "clock")
                }
                .font(.caption2)
                .foregroundColor(.purple.opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

#Preview {
    SmartTranslatorView()
}
