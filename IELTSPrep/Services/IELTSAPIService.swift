import Foundation
import AVFoundation

// MARK: - IELTS API Service
// All content powered by Groq AI - Fresh, Cambridge-style IELTS content
// Daily Topic System: All sections (Reading, Writing, Speaking, Vocabulary) are connected

class IELTSAPIService: ObservableObject {
    static let shared = IELTSAPIService()

    // MARK: - API Key (Set via Settings or Environment)
    @Published var groqAPIKey: String = ""

    var isGroqConfigured: Bool { !groqAPIKey.isEmpty }

    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Daily Topic System
    @Published var dailyTopic: String = "Environment and Climate Change"
    @Published var dailyVocabulary: [VocabularyItem] = []

    let availableTopics = [
        "Environment and Climate Change",
        "Technology and Innovation",
        "Education and Learning",
        "Health and Lifestyle",
        "Work and Career",
        "Travel and Culture",
        "Society and Social Issues",
        "Media and Communication",
        "Science and Research",
        "Cities and Urban Life"
    ]

    // MARK: - Data Models

    struct VocabularyItem: Identifiable {
        let id = UUID()
        let word: String
        let bangla: String
        let definition: String
        let example: String
        let partOfSpeech: String
        let synonyms: [String]
    }

    struct ReadingPassage: Identifiable {
        let id = UUID()
        let title: String
        let content: String
        let difficulty: String
        let topic: String
        let questions: [ReadingQuestion]
        let vocabulary: [String]
    }

    struct ReadingQuestion: Identifiable {
        let id = UUID()
        let question: String
        let options: [String]
        let correctAnswer: Int
        let explanation: String
    }

    struct WritingTask: Identifiable {
        let id = UUID()
        let taskType: Int
        let topic: String
        let category: String
        let instructions: String
        let sampleEssay: String
        let keyVocabulary: [String]
        let tips: [String]
        let banglaTips: String
    }

    struct SpeakingSet: Identifiable {
        let id = UUID()
        let topic: String
        let part1Questions: [String]
        let part2CueCard: CueCard
        let part3Questions: [String]
        let sampleAnswers: [String: String]
        let vocabulary: [String]
    }

    struct CueCard {
        let mainTopic: String
        let bulletPoints: [String]
        let thinkTime: String
        let speakTime: String
    }

    struct ListeningExercise: Identifiable {
        let id = UUID()
        let title: String
        let section: Int
        let transcript: String
        let questions: [ListeningQuestion]
        let topic: String
    }

    struct ListeningQuestion: Identifiable {
        let id = UUID()
        let question: String
        let answer: String
        let questionType: String
    }

    struct GrammarLesson: Identifiable {
        let id = UUID()
        let topic: String
        let explanation: String
        let banglaExplanation: String
        let examples: [String]
        let exercises: [GrammarExercise]
    }

    struct GrammarExercise: Identifiable {
        let id = UUID()
        let question: String
        let options: [String]
        let correctAnswer: Int
        let explanation: String
    }

    // MARK: - Cambridge Mock Test Models

    struct CambridgeReadingTestContent {
        let passages: [CambridgeReadingPassage]
    }

    struct CambridgeReadingPassage: Identifiable {
        let id = UUID()
        let title: String
        let paragraphs: [String]
        let questions: [CambridgeReadingQuestion]
        let questionRange: String
    }

    struct CambridgeReadingQuestion: Identifiable {
        let id = UUID()
        let number: Int
        let text: String
        let type: CambridgeQuestionType
        let options: [String]?
        let answer: String

        enum CambridgeQuestionType: String {
            case multipleChoice = "mcq"
            case trueFalseNotGiven = "tfng"
            case yesNoNotGiven = "ynng"
            case matchingHeadings = "match_head"
            case matchingInformation = "match_info"
            case sentenceCompletion = "sentence"
            case summaryCompletion = "summary"
            case fillInBlank = "fill"
            case shortAnswer = "short"
        }
    }

    struct CambridgeListeningTestContent {
        let sections: [CambridgeListeningSection]
    }

    struct CambridgeListeningSection {
        let context: String
        let transcript: String
        let questions: [CambridgeListeningQuestion]
    }

    struct CambridgeListeningQuestion {
        let text: String
        let answer: String
        let type: String
    }

    struct CambridgeWritingTestContent {
        let task1: CambridgeWritingTask
        let task2: CambridgeWritingTask
    }

    struct CambridgeWritingTask {
        let instruction: String
        let prompt: String
        let sampleAnswer: String?
    }

    struct CambridgeSpeakingTestContent {
        let part1: CambridgeSpeakingPart
        let part2: CambridgeSpeakingPart2
        let part3: CambridgeSpeakingPart
    }

    struct CambridgeSpeakingPart {
        let instruction: String
        let questions: [String]
    }

    struct CambridgeSpeakingPart2 {
        let topic: String
        let bulletPoints: [String]
        let followUp: String
    }

    // MARK: - Groq AI Core Function

    // Custom URLSession that disables HTTP/3 to avoid QUIC issues
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Accept": "application/json"]
        // Disable HTTP/3 to avoid QUIC protocol issues in simulator
        if #available(iOS 15.0, *) {
            config.multipathServiceType = .none
        }
        return URLSession(configuration: config)
    }()

    func callGroqAI(prompt: String, systemPrompt: String = "You are an expert IELTS tutor. Always respond with valid JSON only. Do NOT wrap JSON in markdown code blocks. Return raw JSON directly.", maxTokens: Int = 3000, requireJSON: Bool = true) async -> String? {
        guard !groqAPIKey.isEmpty else {
            print("Groq API key is empty")
            return nil
        }

        // Retry up to 3 times
        for attempt in 1...3 {
            print("Groq AI attempt \(attempt)...")

            if let result = await makeGroqRequest(prompt: prompt, systemPrompt: systemPrompt, maxTokens: maxTokens, requireJSON: requireJSON) {
                return result
            }

            // Wait before retry (exponential backoff)
            if attempt < 3 {
                print("Retrying in \(attempt) seconds...")
                try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
            }
        }

        print("All Groq AI attempts failed")
        return nil
    }

    private func makeGroqRequest(prompt: String, systemPrompt: String, maxTokens: Int, requireJSON: Bool) async -> String? {
        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.assumesHTTP3Capable = false
        request.setValue("Bearer \(groqAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": maxTokens
        ]

        // Only add JSON format requirement if needed
        if requireJSON {
            body["response_format"] = ["type": "json_object"]
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await urlSession.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Groq API Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("Non-200 response: \(String(data: data, encoding: .utf8) ?? "no body")")
                    return nil
                }
            }

            let groqResponse = try JSONDecoder().decode(GroqResponse.self, from: data)
            let content = groqResponse.choices.first?.message.content
            print("Groq AI Response: \(content?.prefix(100) ?? "nil")...")
            return content
        } catch {
            print("Groq request error: \(error.localizedDescription)")
            return nil
        }
    }

    struct GroqResponse: Codable {
        let choices: [GroqChoice]
    }

    struct GroqChoice: Codable {
        let message: GroqMessage
    }

    struct GroqMessage: Codable {
        let content: String
    }

    // MARK: - Generate Daily Vocabulary (Based on Topic)

    func generateDailyVocabulary(topic: String) async -> [VocabularyItem] {
        let prompt = """
        Generate 15 important IELTS vocabulary words related to "\(topic)".

        Return JSON array:
        [
            {
                "word": "sustainable",
                "bangla": "টেকসই",
                "definition": "able to continue over a long time",
                "example": "We need sustainable development to protect our planet.",
                "partOfSpeech": "adjective",
                "synonyms": ["maintainable", "viable", "enduring"]
            }
        ]

        Make sure words are:
        - Band 7+ level vocabulary
        - Commonly used in IELTS exams
        - Related to \(topic)
        - Include accurate Bangla translations
        """

        guard let response = await callGroqAI(prompt: prompt) else { return [] }

        if let data = extractJSON(from: response)?.data(using: .utf8),
           let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return items.compactMap { item in
                guard let word = item["word"] as? String,
                      let bangla = item["bangla"] as? String,
                      let definition = item["definition"] as? String,
                      let example = item["example"] as? String,
                      let partOfSpeech = item["partOfSpeech"] as? String,
                      let synonyms = item["synonyms"] as? [String] else { return nil }

                return VocabularyItem(
                    word: word,
                    bangla: bangla,
                    definition: definition,
                    example: example,
                    partOfSpeech: partOfSpeech,
                    synonyms: synonyms
                )
            }
        }
        return []
    }

    // MARK: - Generate Reading Passage with Questions

    func generateReadingPassage(topic: String) async -> ReadingPassage? {
        let prompt = """
        Generate an IELTS Academic Reading passage about "\(topic)".

        Return JSON:
        {
            "title": "The Impact of...",
            "content": "Full passage here (400-500 words, academic style, multiple paragraphs)...",
            "difficulty": "Medium",
            "vocabulary": ["word1", "word2", "word3", "word4", "word5"],
            "questions": [
                {
                    "question": "According to the passage, what is...?",
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correctAnswer": 0,
                    "explanation": "The answer is A because..."
                },
                {
                    "question": "The author suggests that...",
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correctAnswer": 2,
                    "explanation": "In paragraph 3, the author states..."
                },
                {
                    "question": "What can be inferred from paragraph 2?",
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correctAnswer": 1,
                    "explanation": "This inference is supported by..."
                },
                {
                    "question": "The word 'sustainable' in line X most nearly means...",
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correctAnswer": 3,
                    "explanation": "In this context, sustainable means..."
                },
                {
                    "question": "Which statement best summarizes the main idea?",
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correctAnswer": 0,
                    "explanation": "The main argument of the passage is..."
                }
            ]
        }

        Requirements:
        - Cambridge IELTS style
        - Academic vocabulary
        - 5 varied question types (main idea, detail, inference, vocabulary, summary)
        - Clear explanations for each answer
        """

        print("generateReadingPassage: Calling Groq AI for topic: \(topic)")
        guard let response = await callGroqAI(prompt: prompt, maxTokens: 4000) else {
            print("generateReadingPassage: No response from Groq AI")
            return nil
        }
        print("generateReadingPassage: Got response, extracting JSON...")

        guard let jsonString = extractJSON(from: response),
              let data = jsonString.data(using: .utf8) else {
            print("generateReadingPassage: Failed to extract JSON string")
            return nil
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("generateReadingPassage: Failed to parse JSON")
            return nil
        }

        print("generateReadingPassage: JSON parsed successfully, title: \(json["title"] ?? "no title")")

        let questions: [ReadingQuestion] = (json["questions"] as? [[String: Any]] ?? []).compactMap { q in
            guard let question = q["question"] as? String,
                  let options = q["options"] as? [String],
                  let correctAnswer = q["correctAnswer"] as? Int,
                  let explanation = q["explanation"] as? String else { return nil }

            return ReadingQuestion(
                question: question,
                options: options,
                correctAnswer: correctAnswer,
                explanation: explanation
            )
        }

        print("generateReadingPassage: Created \(questions.count) questions")

        return ReadingPassage(
            title: json["title"] as? String ?? "Reading Passage",
            content: json["content"] as? String ?? "",
            difficulty: json["difficulty"] as? String ?? "Medium",
            topic: topic,
            questions: questions,
            vocabulary: json["vocabulary"] as? [String] ?? []
        )
    }

    // MARK: - Generate Writing Task

    func generateWritingTask(topic: String, taskType: Int) async -> WritingTask? {
        let taskDescription = taskType == 1
            ? "Task 1 (describe a graph/chart/process)"
            : "Task 2 (essay question - opinion/discussion/problem-solution)"

        let prompt = """
        Generate an IELTS Writing \(taskDescription) about "\(topic)".

        Return JSON:
        {
            "taskType": \(taskType),
            "topic": "The full question/prompt here...",
            "category": "\(topic)",
            "instructions": "You should spend about \(taskType == 1 ? "20" : "40") minutes on this task...",
            "sampleEssay": "Full band 8 sample answer here (250+ words for Task 2, 150+ for Task 1)...",
            "keyVocabulary": ["word1", "word2", "word3", "word4", "word5"],
            "tips": ["Tip 1", "Tip 2", "Tip 3"],
            "banglaTips": "বাংলায় কিছু টিপস লেখো যেমন: প্রথমে introduction লেখো, তারপর..."
        }

        Requirements:
        - Cambridge IELTS style question
        - Band 8+ sample answer
        - Practical tips for students
        - Include Bangla tips for Bengali students
        """

        guard let response = await callGroqAI(prompt: prompt, maxTokens: 3500) else { return nil }

        if let data = extractJSON(from: response)?.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            return WritingTask(
                taskType: json["taskType"] as? Int ?? taskType,
                topic: json["topic"] as? String ?? "",
                category: json["category"] as? String ?? topic,
                instructions: json["instructions"] as? String ?? "",
                sampleEssay: json["sampleEssay"] as? String ?? "",
                keyVocabulary: json["keyVocabulary"] as? [String] ?? [],
                tips: json["tips"] as? [String] ?? [],
                banglaTips: json["banglaTips"] as? String ?? ""
            )
        }
        return nil
    }

    // MARK: - Generate Speaking Set

    func generateSpeakingSet(topic: String) async -> SpeakingSet? {
        let prompt = """
        Generate a complete IELTS Speaking test set about "\(topic)".

        Return JSON:
        {
            "topic": "\(topic)",
            "part1Questions": [
                "Do you like...?",
                "How often do you...?",
                "Did you... when you were a child?",
                "Do you think... is important?"
            ],
            "part2CueCard": {
                "mainTopic": "Describe a...",
                "bulletPoints": ["What it is", "When/where you...", "Why you...", "How you felt about it"],
                "thinkTime": "1 minute",
                "speakTime": "1-2 minutes"
            },
            "part3Questions": [
                "What do you think about...?",
                "How has... changed in recent years?",
                "Do you think... will change in the future?",
                "What are the advantages and disadvantages of...?"
            ],
            "sampleAnswers": {
                "part1_1": "Yes, I really enjoy... because...",
                "part2": "I'd like to talk about... This happened when... The reason I chose this is...",
                "part3_1": "In my opinion, ... I think this because..."
            },
            "vocabulary": ["useful word 1", "useful word 2", "useful phrase 1"]
        }

        Requirements:
        - Natural, conversational questions
        - Band 7+ sample answers
        - Relevant vocabulary for this topic
        """

        guard let response = await callGroqAI(prompt: prompt, maxTokens: 3000) else { return nil }

        if let data = extractJSON(from: response)?.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            var cueCard = CueCard(mainTopic: "", bulletPoints: [], thinkTime: "1 minute", speakTime: "1-2 minutes")
            if let cc = json["part2CueCard"] as? [String: Any] {
                cueCard = CueCard(
                    mainTopic: cc["mainTopic"] as? String ?? "",
                    bulletPoints: cc["bulletPoints"] as? [String] ?? [],
                    thinkTime: cc["thinkTime"] as? String ?? "1 minute",
                    speakTime: cc["speakTime"] as? String ?? "1-2 minutes"
                )
            }

            return SpeakingSet(
                topic: json["topic"] as? String ?? topic,
                part1Questions: json["part1Questions"] as? [String] ?? [],
                part2CueCard: cueCard,
                part3Questions: json["part3Questions"] as? [String] ?? [],
                sampleAnswers: json["sampleAnswers"] as? [String: String] ?? [:],
                vocabulary: json["vocabulary"] as? [String] ?? []
            )
        }
        return nil
    }

    // MARK: - Generate Listening Exercise

    func generateListeningExercise(topic: String, section: Int) async -> ListeningExercise? {
        let sectionDescription: String
        switch section {
        case 1: sectionDescription = "Section 1: A conversation between two people in an everyday social context (e.g., booking, inquiry)"
        case 2: sectionDescription = "Section 2: A monologue in an everyday social context (e.g., speech, tour guide)"
        case 3: sectionDescription = "Section 3: A conversation between up to four people in an educational context"
        case 4: sectionDescription = "Section 4: A university lecture or talk on an academic subject"
        default: sectionDescription = "Section 2"
        }

        let prompt = """
        Generate an IELTS Listening exercise for \(sectionDescription) about "\(topic)".

        Return JSON:
        {
            "title": "Title of the listening",
            "section": \(section),
            "transcript": "Full transcript here with natural dialogue/speech (300-400 words)...",
            "questions": [
                {"question": "What is the...?", "answer": "the answer", "questionType": "fill-blank"},
                {"question": "How many...?", "answer": "15", "questionType": "fill-blank"},
                {"question": "When will the...?", "answer": "next Monday", "questionType": "fill-blank"},
                {"question": "What does the speaker suggest about...?", "answer": "detailed answer", "questionType": "short-answer"},
                {"question": "Complete: The main reason is ___", "answer": "cost reduction", "questionType": "fill-blank"}
            ]
        }

        Requirements:
        - Realistic dialogue/monologue
        - Clear answers that can be heard in the transcript
        - Mix of question types
        - 5-8 questions
        """

        guard let response = await callGroqAI(prompt: prompt, maxTokens: 3000) else { return nil }

        if let data = extractJSON(from: response)?.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            let questions: [ListeningQuestion] = (json["questions"] as? [[String: Any]] ?? []).compactMap { q in
                guard let question = q["question"] as? String,
                      let answer = q["answer"] as? String,
                      let questionType = q["questionType"] as? String else { return nil }

                return ListeningQuestion(question: question, answer: answer, questionType: questionType)
            }

            return ListeningExercise(
                title: json["title"] as? String ?? "Listening Exercise",
                section: json["section"] as? Int ?? section,
                transcript: json["transcript"] as? String ?? "",
                questions: questions,
                topic: topic
            )
        }
        return nil
    }

    // MARK: - Generate Grammar Lesson

    func generateGrammarLesson(topic: String) async -> GrammarLesson? {
        let grammarTopics = [
            "Conditional Sentences (If clauses)",
            "Passive Voice",
            "Relative Clauses",
            "Articles (a, an, the)",
            "Linking Words and Transitions",
            "Reported Speech",
            "Comparatives and Superlatives",
            "Modal Verbs",
            "Perfect Tenses",
            "Gerunds and Infinitives"
        ]

        let selectedGrammar = grammarTopics.randomElement() ?? "Conditional Sentences"

        let prompt = """
        Generate an IELTS Grammar lesson about "\(selectedGrammar)" with examples related to "\(topic)".

        Return JSON:
        {
            "topic": "\(selectedGrammar)",
            "explanation": "Clear English explanation of the grammar rule...",
            "banglaExplanation": "বাংলায় ব্যাখ্যা করো যেন বাংলাদেশি ছাত্ররা সহজে বুঝতে পারে...",
            "examples": [
                "Example sentence 1 about \(topic)",
                "Example sentence 2 about \(topic)",
                "Example sentence 3 about \(topic)"
            ],
            "exercises": [
                {
                    "question": "If the government ____ (invest) more in renewable energy, pollution would decrease.",
                    "options": ["invest", "invested", "will invest", "had invested"],
                    "correctAnswer": 1,
                    "explanation": "Second conditional uses past simple in the if-clause."
                },
                {
                    "question": "Question 2...",
                    "options": ["A", "B", "C", "D"],
                    "correctAnswer": 0,
                    "explanation": "Explanation..."
                },
                {
                    "question": "Question 3...",
                    "options": ["A", "B", "C", "D"],
                    "correctAnswer": 2,
                    "explanation": "Explanation..."
                }
            ]
        }

        Requirements:
        - Clear, simple explanations
        - Bangla explanation for Bengali students
        - Examples related to the current topic (\(topic))
        - 3-5 practice exercises
        """

        guard let response = await callGroqAI(prompt: prompt, maxTokens: 2500) else { return nil }

        if let data = extractJSON(from: response)?.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            let exercises: [GrammarExercise] = (json["exercises"] as? [[String: Any]] ?? []).compactMap { e in
                guard let question = e["question"] as? String,
                      let options = e["options"] as? [String],
                      let correctAnswer = e["correctAnswer"] as? Int,
                      let explanation = e["explanation"] as? String else { return nil }

                return GrammarExercise(
                    question: question,
                    options: options,
                    correctAnswer: correctAnswer,
                    explanation: explanation
                )
            }

            return GrammarLesson(
                topic: json["topic"] as? String ?? selectedGrammar,
                explanation: json["explanation"] as? String ?? "",
                banglaExplanation: json["banglaExplanation"] as? String ?? "",
                examples: json["examples"] as? [String] ?? [],
                exercises: exercises
            )
        }
        return nil
    }

    // MARK: - Essay Feedback

    struct EssayFeedback {
        let bandScore: Double
        let taskAchievement: String
        let coherenceCohesion: String
        let lexicalResource: String
        let grammaticalRange: String
        let strengths: [String]
        let improvements: [String]
        let banglaSummary: String
    }

    func getEssayFeedback(essay: String, topic: String) async -> EssayFeedback? {
        let prompt = """
        You are an IELTS examiner. Evaluate this essay:

        Topic: \(topic)
        Essay: \(essay)

        Return JSON:
        {
            "bandScore": 6.5,
            "taskAchievement": "feedback...",
            "coherenceCohesion": "feedback...",
            "lexicalResource": "feedback...",
            "grammaticalRange": "feedback...",
            "strengths": ["strength1", "strength2"],
            "improvements": ["improvement1", "improvement2"],
            "banglaSummary": "বাংলায় সংক্ষিপ্ত মন্তব্য..."
        }
        """

        guard let response = await callGroqAI(prompt: prompt) else { return nil }

        if let data = extractJSON(from: response)?.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            return EssayFeedback(
                bandScore: json["bandScore"] as? Double ?? 0,
                taskAchievement: json["taskAchievement"] as? String ?? "",
                coherenceCohesion: json["coherenceCohesion"] as? String ?? "",
                lexicalResource: json["lexicalResource"] as? String ?? "",
                grammaticalRange: json["grammaticalRange"] as? String ?? "",
                strengths: json["strengths"] as? [String] ?? [],
                improvements: json["improvements"] as? [String] ?? [],
                banglaSummary: json["banglaSummary"] as? String ?? ""
            )
        }
        return nil
    }

    // MARK: - Word Explanation

    func explainWord(word: String, context: String = "") async -> String? {
        let prompt = """
        Explain the word "\(word)"\(context.isEmpty ? "" : " in this context: \"\(context)\"")

        Provide:
        1. বাংলা অর্থ (Bangla meaning)
        2. English definition
        3. Part of speech
        4. Example sentence
        5. Synonyms
        6. How to use in IELTS Writing/Speaking

        Keep it helpful for IELTS preparation. Format nicely with clear sections.
        """

        return await callGroqAI(
            prompt: prompt,
            systemPrompt: "You are an English vocabulary teacher helping Bengali students prepare for IELTS. Mix English and Bangla in your explanations. Respond in plain text with clear formatting.",
            maxTokens: 1000,
            requireJSON: false
        )
    }

    // MARK: - Helper Functions

    func extractJSON(from text: String) -> String? {
        var cleanText = text

        // Remove markdown code blocks if present
        if cleanText.contains("```json") {
            cleanText = cleanText.replacingOccurrences(of: "```json", with: "")
        }
        if cleanText.contains("```") {
            cleanText = cleanText.replacingOccurrences(of: "```", with: "")
        }
        cleanText = cleanText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Try to extract JSON object
        if let start = cleanText.firstIndex(of: "{"),
           let end = cleanText.lastIndex(of: "}") {
            let jsonString = String(cleanText[start...end])
            print("Extracted JSON: \(jsonString.prefix(200))...")
            return jsonString
        }

        // Try to extract JSON array
        if let start = cleanText.firstIndex(of: "["),
           let end = cleanText.lastIndex(of: "]") {
            let jsonString = String(cleanText[start...end])
            print("Extracted JSON Array: \(jsonString.prefix(200))...")
            return jsonString
        }

        print("Could not extract JSON from: \(cleanText.prefix(200))...")
        return cleanText
    }

    // MARK: - Set Daily Topic

    func setDailyTopic(_ topic: String) async {
        dailyTopic = topic
        dailyVocabulary = await generateDailyVocabulary(topic: topic)
    }

    // MARK: - Grammar Check (LanguageTool API)

    struct GrammarError: Identifiable {
        let id = UUID()
        let message: String
        let offset: Int
        let length: Int
        let replacements: [String]
    }

    func checkGrammar(text: String) async -> [GrammarError] {
        let urlString = "https://api.languagetool.org/v2/check"
        guard let url = URL(string: urlString) else { return [] }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&language=en-US"
        request.httpBody = body.data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let matches = json["matches"] as? [[String: Any]] {

                return matches.compactMap { match in
                    let message = match["message"] as? String ?? ""
                    let offset = match["offset"] as? Int ?? 0
                    let length = match["length"] as? Int ?? 0
                    var replacements: [String] = []
                    if let repls = match["replacements"] as? [[String: Any]] {
                        replacements = repls.compactMap { $0["value"] as? String }
                    }
                    return GrammarError(message: message, offset: offset, length: length, replacements: replacements)
                }
            }
        } catch {
            print("Grammar check error: \(error)")
        }
        return []
    }

    // MARK: - Cambridge Style Test Generation

    func generateCambridgeReadingTest(book: String, testNumber: Int) async -> CambridgeReadingTestContent? {
        let topics = [
            "The History of Timekeeping", "Coral Reef Ecosystems", "The Psychology of Decision Making",
            "Urban Planning and Sustainability", "The Evolution of Language", "Artificial Intelligence Ethics",
            "Climate Change Adaptation", "The Science of Sleep", "Ancient Trade Routes", "Modern Architecture"
        ]

        // Generate 3 passages
        var passages: [CambridgeReadingPassage] = []

        for i in 0..<3 {
            let topicIndex = (Int(book) ?? 16 + testNumber + i) % topics.count
            let topic = topics[topicIndex]

            let prompt = """
            Generate an IELTS Academic Reading passage about "\(topic)" for Cambridge IELTS \(book) Test \(testNumber) Passage \(i + 1).

            Return JSON format:
            {
                "title": "passage title",
                "paragraphs": ["paragraph 1 (150 words)", "paragraph 2 (150 words)", "paragraph 3 (150 words)", "paragraph 4 (150 words)", "paragraph 5 (150 words)"],
                "questions": [
                    {
                        "number": 1,
                        "text": "question text",
                        "type": "mcq|tfng|ynng|fill|short",
                        "options": ["A option", "B option", "C option", "D option"] or null,
                        "answer": "correct answer"
                    }
                ]
            }

            Generate exactly 13 questions with these types:
            - Questions 1-4: Multiple Choice (mcq)
            - Questions 5-8: True/False/Not Given (tfng)
            - Questions 9-11: Sentence Completion (fill)
            - Questions 12-13: Short Answer (short)

            Make the passage academic, detailed, and approximately 700-800 words total.
            """

            if let response = await callGroqAI(prompt: prompt, systemPrompt: "You are an IELTS exam content creator. Generate authentic Cambridge IELTS style reading passages. Return valid JSON only.", maxTokens: 4000) {
                if let passage = parseReadingPassage(from: response, passageNumber: i + 1) {
                    passages.append(passage)
                }
            }
        }

        return passages.isEmpty ? nil : CambridgeReadingTestContent(passages: passages)
    }

    private func parseReadingPassage(from json: String, passageNumber: Int) -> CambridgeReadingPassage? {
        guard let jsonString = extractJSON(from: json),
              let data = jsonString.data(using: .utf8) else { return nil }

        do {
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let title = dict["title"] as? String ?? "Untitled Passage"
                let paragraphs = dict["paragraphs"] as? [String] ?? []
                let questionsArray = dict["questions"] as? [[String: Any]] ?? []

                var questions: [CambridgeReadingQuestion] = []
                let baseNum = (passageNumber - 1) * 13 + 1

                for (index, q) in questionsArray.enumerated() {
                    let qNum = baseNum + index
                    let text = q["text"] as? String ?? ""
                    let typeStr = q["type"] as? String ?? "fill"
                    let options = q["options"] as? [String]
                    let answer = q["answer"] as? String ?? ""

                    let type: CambridgeReadingQuestion.CambridgeQuestionType
                    switch typeStr {
                    case "mcq": type = .multipleChoice
                    case "tfng": type = .trueFalseNotGiven
                    case "ynng": type = .yesNoNotGiven
                    case "fill": type = .fillInBlank
                    case "short": type = .shortAnswer
                    default: type = .fillInBlank
                    }

                    questions.append(CambridgeReadingQuestion(
                        number: qNum,
                        text: text,
                        type: type,
                        options: options,
                        answer: answer
                    ))
                }

                let startQ = (passageNumber - 1) * 13 + 1
                let endQ = startQ + 12

                return CambridgeReadingPassage(
                    title: title,
                    paragraphs: paragraphs,
                    questions: questions,
                    questionRange: "\(startQ)-\(endQ)"
                )
            }
        } catch {
            print("Parse reading passage error: \(error)")
        }
        return nil
    }

    func generateCambridgeListeningTest(book: String, testNumber: Int) async -> CambridgeListeningTestContent? {
        let contexts = [
            ("A conversation between a student and accommodation officer about renting a flat", "everyday"),
            ("A tour guide giving information about a local museum", "everyday"),
            ("A discussion between two students and their tutor about a research project", "academic"),
            ("A university lecture about environmental science", "academic")
        ]

        var sections: [CambridgeListeningSection] = []

        for (index, context) in contexts.enumerated() {
            let prompt = """
            Generate IELTS Listening Section \(index + 1) for Cambridge IELTS \(book) Test \(testNumber).

            Context: \(context.0)
            Type: \(context.1)

            Return JSON format:
            {
                "context": "brief description of the situation",
                "transcript": "full dialogue or monologue transcript (300-400 words)",
                "questions": [
                    {"text": "question or sentence with blank ___", "answer": "answer", "type": "fill|mcq|match"}
                ]
            }

            Generate exactly 10 questions. Mix question types:
            - Fill in the blank (with maximum 2-3 words answers)
            - Multiple choice
            - Matching

            Make it authentic Cambridge IELTS style.
            """

            if let response = await callGroqAI(prompt: prompt, systemPrompt: "You are an IELTS exam content creator. Generate authentic listening test content. Return valid JSON only.", maxTokens: 3000) {
                if let section = parseListeningSection(from: response) {
                    sections.append(section)
                }
            }
        }

        return sections.isEmpty ? nil : CambridgeListeningTestContent(sections: sections)
    }

    private func parseListeningSection(from json: String) -> CambridgeListeningSection? {
        guard let jsonString = extractJSON(from: json),
              let data = jsonString.data(using: .utf8) else { return nil }

        do {
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let context = dict["context"] as? String ?? ""
                let transcript = dict["transcript"] as? String ?? ""
                let questionsArray = dict["questions"] as? [[String: Any]] ?? []

                var questions: [CambridgeListeningQuestion] = []
                for q in questionsArray {
                    questions.append(CambridgeListeningQuestion(
                        text: q["text"] as? String ?? "",
                        answer: q["answer"] as? String ?? "",
                        type: q["type"] as? String ?? "fill"
                    ))
                }

                return CambridgeListeningSection(context: context, transcript: transcript, questions: questions)
            }
        } catch {
            print("Parse listening section error: \(error)")
        }
        return nil
    }

    func generateCambridgeWritingTest(book: String, testNumber: Int) async -> CambridgeWritingTestContent? {
        // Task 1 - Graph/Chart/Process
        let task1Prompt = """
        Generate an IELTS Academic Writing Task 1 for Cambridge IELTS \(book) Test \(testNumber).

        Return JSON format:
        {
            "instruction": "You should spend about 20 minutes on this task.",
            "prompt": "The chart/graph/diagram shows... Summarise the information by selecting and reporting the main features, and make comparisons where relevant. Write at least 150 words.",
            "sampleAnswer": "A Band 8 model answer (180-200 words)"
        }

        Choose one type randomly:
        - Line graph showing trends over time
        - Bar chart comparing data
        - Pie charts showing proportions
        - Table with numerical data
        - Process diagram
        - Map showing changes

        Make it authentic Cambridge IELTS style with realistic data.
        """

        // Task 2 - Essay
        let task2Prompt = """
        Generate an IELTS Academic Writing Task 2 for Cambridge IELTS \(book) Test \(testNumber).

        Return JSON format:
        {
            "instruction": "You should spend about 40 minutes on this task. Write about the following topic:",
            "prompt": "Essay question here... Give reasons for your answer and include any relevant examples from your own knowledge or experience. Write at least 250 words.",
            "sampleAnswer": "A Band 8 model answer (280-320 words)"
        }

        Choose one essay type:
        - Opinion essay (agree/disagree)
        - Discussion essay (discuss both views)
        - Problem-solution essay
        - Advantages-disadvantages essay
        - Two-part question

        Topic should be about: education, technology, environment, society, health, or work.
        Make it thought-provoking and authentic Cambridge IELTS style.
        """

        var task1: CambridgeWritingTask?
        var task2: CambridgeWritingTask?

        if let response1 = await callGroqAI(prompt: task1Prompt, systemPrompt: "You are an IELTS exam content creator. Return valid JSON only.", maxTokens: 2000) {
            task1 = parseCambridgeWritingTask(from: response1)
        }

        if let response2 = await callGroqAI(prompt: task2Prompt, systemPrompt: "You are an IELTS exam content creator. Return valid JSON only.", maxTokens: 2000) {
            task2 = parseCambridgeWritingTask(from: response2)
        }

        guard let t1 = task1, let t2 = task2 else { return nil }
        return CambridgeWritingTestContent(task1: t1, task2: t2)
    }

    private func parseCambridgeWritingTask(from json: String) -> CambridgeWritingTask? {
        guard let jsonString = extractJSON(from: json),
              let data = jsonString.data(using: .utf8) else { return nil }

        do {
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return CambridgeWritingTask(
                    instruction: dict["instruction"] as? String ?? "",
                    prompt: dict["prompt"] as? String ?? "",
                    sampleAnswer: dict["sampleAnswer"] as? String
                )
            }
        } catch {
            print("Parse writing task error: \(error)")
        }
        return nil
    }

    func generateCambridgeSpeakingTest(book: String, testNumber: Int) async -> CambridgeSpeakingTestContent? {
        let prompt = """
        Generate a complete IELTS Speaking Test for Cambridge IELTS \(book) Test \(testNumber).

        Return JSON format:
        {
            "part1": {
                "instruction": "The examiner will ask general questions about yourself and familiar topics.",
                "questions": ["Question 1", "Question 2", "Question 3", "Question 4", "Question 5"]
            },
            "part2": {
                "topic": "Describe a [topic]. You should say:",
                "bulletPoints": ["point 1", "point 2", "point 3"],
                "followUp": "and explain why..."
            },
            "part3": {
                "instruction": "The examiner will ask further questions connected to the topic in Part 2.",
                "questions": ["Discussion question 1", "Discussion question 2", "Discussion question 3", "Discussion question 4"]
            }
        }

        Part 1 topics: home, work/study, hobbies, daily routine, hometown
        Part 2: A memorable experience, person, place, or object
        Part 3: Abstract discussion related to Part 2 topic

        Make questions authentic Cambridge IELTS style.
        """

        guard let response = await callGroqAI(prompt: prompt, systemPrompt: "You are an IELTS exam content creator. Return valid JSON only.", maxTokens: 2000) else {
            return nil
        }

        return parseCambridgeSpeakingTest(from: response)
    }

    private func parseCambridgeSpeakingTest(from json: String) -> CambridgeSpeakingTestContent? {
        guard let jsonString = extractJSON(from: json),
              let data = jsonString.data(using: .utf8) else { return nil }

        do {
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let part1Dict = dict["part1"] as? [String: Any] ?? [:]
                let part2Dict = dict["part2"] as? [String: Any] ?? [:]
                let part3Dict = dict["part3"] as? [String: Any] ?? [:]

                let part1 = CambridgeSpeakingPart(
                    instruction: part1Dict["instruction"] as? String ?? "Answer the following questions.",
                    questions: part1Dict["questions"] as? [String] ?? []
                )

                let part2 = CambridgeSpeakingPart2(
                    topic: part2Dict["topic"] as? String ?? "",
                    bulletPoints: part2Dict["bulletPoints"] as? [String] ?? [],
                    followUp: part2Dict["followUp"] as? String ?? ""
                )

                let part3 = CambridgeSpeakingPart(
                    instruction: part3Dict["instruction"] as? String ?? "Discuss the following questions.",
                    questions: part3Dict["questions"] as? [String] ?? []
                )

                return CambridgeSpeakingTestContent(part1: part1, part2: part2, part3: part3)
            }
        } catch {
            print("Parse speaking test error: \(error)")
        }
        return nil
    }
}
