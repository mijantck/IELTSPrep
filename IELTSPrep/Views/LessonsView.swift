import SwiftUI
import AVFoundation

// MARK: - Main Lessons View with Daily Topic
struct LessonsView: View {
    @ObservedObject var apiService = IELTSAPIService.shared
    @State private var showTopicPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Topic Card
                    DailyTopicCard(
                        topic: apiService.dailyTopic,
                        onChangeTopic: { showTopicPicker = true }
                    )

                    // YouTube Learning Hub
                    NavigationLink(destination: YouTubeLearningView()) {
                        YouTubeLearningCard()
                    }
                    .buttonStyle(.plain)

                    // Vocabulary Section
                    NavigationLink(destination: VocabularyView()) {
                        VocabularyCard()
                    }
                    .buttonStyle(.plain)

                    // Grammar Lab (Smart Translator)
                    NavigationLink(destination: SmartTranslatorView()) {
                        GrammarLabCard()
                    }
                    .buttonStyle(.plain)

                    // Category Cards
                    ForEach(LessonCategory.allCases, id: \.rawValue) { category in
                        NavigationLink(destination: destinationView(for: category)) {
                            LessonCategoryCard(category: category)
                        }
                        .buttonStyle(.plain)
                    }

                    // Daily Vocabulary Preview
                    if !apiService.dailyVocabulary.isEmpty {
                        DailyVocabularyCard(vocabulary: apiService.dailyVocabulary)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Learn")
            .sheet(isPresented: $showTopicPicker) {
                TopicPickerSheet(apiService: apiService)
            }
            .task {
                if apiService.dailyVocabulary.isEmpty {
                    await apiService.setDailyTopic(apiService.dailyTopic)
                }
            }
        }
    }

    @ViewBuilder
    func destinationView(for category: LessonCategory) -> some View {
        switch category {
        case .reading:
            AIReadingView()
        case .writing:
            AIWritingView()
        case .listening:
            AIListeningView()
        case .speaking:
            AISpeakingView()
        case .grammar:
            AIGrammarView()
        }
    }
}

// MARK: - Daily Topic Card
struct DailyTopicCard: View {
    let topic: String
    let onChangeTopic: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.orange)
                        Text("আজকের Topic")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(topic)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                Spacer()

                Button(action: onChangeTopic) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Change")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
                }
            }

            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("সব content এই topic এর উপর AI generate করবে")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Topic Picker Sheet
struct TopicPickerSheet: View {
    @ObservedObject var apiService: IELTSAPIService
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(apiService.availableTopics, id: \.self) { topic in
                        Button {
                            Task {
                                isLoading = true
                                await apiService.setDailyTopic(topic)
                                isLoading = false
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Text(topic)
                                    .foregroundColor(.primary)
                                Spacer()
                                if apiService.dailyTopic == topic {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .disabled(isLoading)
                    }
                } header: {
                    Text("Select Today's Topic")
                } footer: {
                    Text("Topic বাছাই করলে Reading, Writing, Speaking সব content ওই topic এর উপর generate হবে")
                }
            }
            .navigationTitle("Choose Topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Done") { dismiss() }
                    }
                }
            }
            .overlay {
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Generating vocabulary...")
                            .font(.caption)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                }
            }
        }
    }
}

// MARK: - Daily Vocabulary Card
struct DailyVocabularyCard: View {
    let vocabulary: [IELTSAPIService.VocabularyItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.book.closed.fill")
                    .foregroundColor(.blue)
                Text("Today's Vocabulary")
                    .font(.headline)
                Spacer()
                Text("\(vocabulary.count) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vocabulary.prefix(5)) { word in
                        VocabularyChip(item: word)
                    }
                }
            }

            NavigationLink(destination: DailyVocabularyListView(vocabulary: vocabulary)) {
                HStack {
                    Text("See all vocabulary")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct VocabularyChip: View {
    let item: IELTSAPIService.VocabularyItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.word)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(item.bangla)
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding(10)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Daily Vocabulary List View
struct DailyVocabularyListView: View {
    let vocabulary: [IELTSAPIService.VocabularyItem]
    @State private var selectedWord: IELTSAPIService.VocabularyItem?

    var body: some View {
        List {
            ForEach(vocabulary) { word in
                Button {
                    selectedWord = word
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(word.word)
                                .font(.headline)
                            Text("(\(word.partOfSpeech))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            SpeakButton(text: word.word)
                        }

                        Text(word.bangla)
                            .font(.subheadline)
                            .foregroundColor(.orange)

                        Text(word.definition)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Today's Vocabulary")
        .sheet(item: $selectedWord) { word in
            VocabularyDetailSheet(word: word)
        }
    }
}

struct VocabularyDetailSheet: View {
    let word: IELTSAPIService.VocabularyItem
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Word Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(word.word)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(word.partOfSpeech)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        SpeakButton(text: word.word, size: .large)
                    }

                    // Bangla Meaning
                    VStack(alignment: .leading, spacing: 8) {
                        Label("বাংলা অর্থ", systemImage: "globe.asia.australia.fill")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text(word.bangla)
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)

                    // Definition
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Definition", systemImage: "text.book.closed.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(word.definition)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

                    // Example
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Example", systemImage: "text.quote")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("\"\(word.example)\"")
                            .font(.body)
                            .italic()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)

                    // Synonyms
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Synonyms", systemImage: "arrow.triangle.branch")
                            .font(.headline)
                            .foregroundColor(.purple)
                        FlowLayout(spacing: 8) {
                            ForEach(word.synonyms, id: \.self) { syn in
                                Text(syn)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.purple.opacity(0.15))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Word Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Speak Button
struct SpeakButton: View {
    let text: String
    var size: ButtonSize = .small

    enum ButtonSize {
        case small, large
    }

    var body: some View {
        Button {
            speak(text)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(size == .large ? .title2 : .body)
                .foregroundColor(.white)
                .padding(size == .large ? 14 : 8)
                .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Circle())
        }
    }

    func speak(_ text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
}

struct LessonCategoryCard: View {
    let category: LessonCategory

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(categoryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    HStack(spacing: 2) {
                        Image(systemName: "sparkles")
                        Text("AI")
                    }
                    .font(.caption2)
                    .foregroundColor(.purple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.purple.opacity(0.15))
                    .cornerRadius(4)
                }
                Text(categoryDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    var categoryColor: Color {
        switch category {
        case .reading: return .green
        case .writing: return .orange
        case .listening: return .pink
        case .speaking: return .red
        case .grammar: return .blue
        }
    }

    var categoryDescription: String {
        switch category {
        case .reading: return "AI-generated passages with questions"
        case .writing: return "AI topics, samples & feedback"
        case .listening: return "AI transcripts with practice"
        case .speaking: return "AI questions for all parts"
        case .grammar: return "AI exercises with explanations"
        }
    }
}

// MARK: - AI Reading View
struct AIReadingView: View {
    @ObservedObject var apiService = IELTSAPIService.shared
    @State private var passage: IELTSAPIService.ReadingPassage?
    @State private var isLoading = false
    @State private var showQuestions = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Topic Badge
                HStack {
                    Label(apiService.dailyTopic, systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(8)
                    Spacer()
                    Button {
                        Task { await loadPassage() }
                    } label: {
                        Label("New Passage", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                }

                if isLoading {
                    LoadingView(message: "AI generating passage...")
                } else if let passage = passage {
                    // Passage Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text(passage.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack {
                            Label(passage.difficulty, systemImage: "speedometer")
                                .font(.caption)
                                .foregroundColor(difficultyColor(passage.difficulty))

                            Spacer()

                            Text("\(passage.questions.count) questions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        // Interactive Reading Text
                        InteractiveReadingText(text: passage.content)

                        // Key Vocabulary
                        if !passage.vocabulary.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Key Vocabulary")
                                    .font(.headline)
                                FlowLayout(spacing: 8) {
                                    ForEach(passage.vocabulary, id: \.self) { word in
                                        Text(word)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(12)
                        }

                        // Practice Button
                        Button {
                            showQuestions = true
                        } label: {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                Text("Practice Questions")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                } else {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Generate a Reading Passage")
                            .font(.headline)
                        Text("AI will create a Cambridge-style passage about \(apiService.dailyTopic)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button {
                            Task { await loadPassage() }
                        } label: {
                            Label("Generate", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    }
                    .padding(40)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reading")
        .sheet(isPresented: $showQuestions) {
            if let passage = passage {
                ReadingQuestionsSheet(passage: passage)
            }
        }
    }

    @MainActor
    func loadPassage() async {
        print("loadPassage called - starting...")
        isLoading = true
        print("Loading reading passage for topic: \(apiService.dailyTopic)")
        passage = await apiService.generateReadingPassage(topic: apiService.dailyTopic)
        print("Passage loaded: \(passage != nil ? "success" : "nil")")
        isLoading = false
    }

    func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        default: return .gray
        }
    }
}

// MARK: - Reading Questions Sheet
struct ReadingQuestionsSheet: View {
    let passage: IELTSAPIService.ReadingPassage
    @Environment(\.dismiss) var dismiss
    @State private var selectedAnswers: [UUID: Int] = [:]
    @State private var showResults = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Array(passage.questions.enumerated()), id: \.element.id) { index, question in
                        QuestionCard(
                            index: index + 1,
                            question: question,
                            selectedAnswer: selectedAnswers[question.id],
                            showResults: showResults,
                            onSelect: { answer in
                                selectedAnswers[question.id] = answer
                            }
                        )
                    }

                    Button {
                        showResults = true
                    } label: {
                        Text(showResults ? "Score: \(calculateScore())/\(passage.questions.count)" : "Check Answers")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(showResults ? Color.green : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(selectedAnswers.count < passage.questions.count && !showResults)
                }
                .padding()
            }
            .navigationTitle("Questions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    func calculateScore() -> Int {
        var score = 0
        for question in passage.questions {
            if selectedAnswers[question.id] == question.correctAnswer {
                score += 1
            }
        }
        return score
    }
}

struct QuestionCard: View {
    let index: Int
    let question: IELTSAPIService.ReadingQuestion
    let selectedAnswer: Int?
    let showResults: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Q\(index). \(question.question)")
                .font(.subheadline)
                .fontWeight(.medium)

            ForEach(Array(question.options.enumerated()), id: \.offset) { optionIndex, option in
                Button {
                    if !showResults {
                        onSelect(optionIndex)
                    }
                } label: {
                    HStack {
                        Text("\(["A", "B", "C", "D"][optionIndex]).")
                            .fontWeight(.medium)
                        Text(option)
                            .multilineTextAlignment(.leading)
                        Spacer()

                        if showResults {
                            if optionIndex == question.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else if optionIndex == selectedAnswer && optionIndex != question.correctAnswer {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        } else if selectedAnswer == optionIndex {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    .font(.subheadline)
                    .padding()
                    .background(optionBackground(optionIndex))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            if showResults {
                Text("💡 \(question.explanation)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    func optionBackground(_ index: Int) -> Color {
        if showResults {
            if index == question.correctAnswer {
                return Color.green.opacity(0.2)
            } else if index == selectedAnswer && index != question.correctAnswer {
                return Color.red.opacity(0.2)
            }
        } else if selectedAnswer == index {
            return Color.blue.opacity(0.1)
        }
        return Color.gray.opacity(0.1)
    }
}

// MARK: - AI Writing View
struct AIWritingView: View {
    @ObservedObject var apiService = IELTSAPIService.shared
    @State private var writingTask: IELTSAPIService.WritingTask?
    @State private var isLoading = false
    @State private var selectedTaskType = 2
    @State private var showSample = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Task Type Picker
                Picker("Task Type", selection: $selectedTaskType) {
                    Text("Task 1").tag(1)
                    Text("Task 2").tag(2)
                }
                .pickerStyle(.segmented)

                // Topic Badge
                HStack {
                    Label(apiService.dailyTopic, systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(8)
                    Spacer()
                    Button {
                        Task { await loadTask() }
                    } label: {
                        Label("New Topic", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                }

                if isLoading {
                    LoadingView(message: "AI generating writing task...")
                } else if let task = writingTask {
                    VStack(alignment: .leading, spacing: 16) {
                        // Task Question
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task \(task.taskType)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .cornerRadius(4)

                            Text(task.topic)
                                .font(.body)
                                .fontWeight(.medium)

                            Text(task.instructions)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)

                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tips")
                                .font(.headline)
                            ForEach(task.tips, id: \.self) { tip in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text(tip)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)

                        // Bangla Tips
                        if !task.banglaTips.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("বাংলায় টিপস", systemImage: "globe.asia.australia.fill")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                Text(task.banglaTips)
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Key Vocabulary
                        if !task.keyVocabulary.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Key Vocabulary")
                                    .font(.headline)
                                FlowLayout(spacing: 8) {
                                    ForEach(task.keyVocabulary, id: \.self) { word in
                                        Text(word)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(12)
                        }

                        // Sample Essay Button
                        Button {
                            showSample = true
                        } label: {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("View Sample Essay")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                } else {
                    EmptyStateView(
                        icon: "pencil.and.outline",
                        title: "Generate Writing Task",
                        subtitle: "AI will create a Cambridge-style writing task",
                        buttonTitle: "Generate",
                        action: { Task { await loadTask() } }
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Writing")
        .sheet(isPresented: $showSample) {
            if let task = writingTask {
                SampleEssaySheet(task: task)
            }
        }
    }

    func loadTask() async {
        isLoading = true
        writingTask = await apiService.generateWritingTask(topic: apiService.dailyTopic, taskType: selectedTaskType)
        isLoading = false
    }
}

struct SampleEssaySheet: View {
    let task: IELTSAPIService.WritingTask
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Band 8+ Sample Essay")
                        .font(.headline)
                        .foregroundColor(.green)

                    Text(task.sampleEssay)
                        .font(.body)
                        .lineSpacing(6)
                }
                .padding()
            }
            .navigationTitle("Sample Answer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - AI Speaking View
struct AISpeakingView: View {
    @ObservedObject var apiService = IELTSAPIService.shared
    @State private var speakingSet: IELTSAPIService.SpeakingSet?
    @State private var isLoading = false
    @State private var selectedPart = 1

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Part Picker
                Picker("Part", selection: $selectedPart) {
                    Text("Part 1").tag(1)
                    Text("Part 2").tag(2)
                    Text("Part 3").tag(3)
                }
                .pickerStyle(.segmented)

                // Topic Badge
                HStack {
                    Label(apiService.dailyTopic, systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(8)
                    Spacer()
                    Button {
                        Task { await loadSpeaking() }
                    } label: {
                        Label("New Set", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                }

                if isLoading {
                    LoadingView(message: "AI generating speaking questions...")
                } else if let set = speakingSet {
                    VStack(alignment: .leading, spacing: 16) {
                        if selectedPart == 1 {
                            Part1View(questions: set.part1Questions)
                        } else if selectedPart == 2 {
                            Part2View(cueCard: set.part2CueCard, sampleAnswer: set.sampleAnswers["part2"])
                        } else {
                            Part3View(questions: set.part3Questions)
                        }

                        // Vocabulary
                        if !set.vocabulary.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Useful Vocabulary")
                                    .font(.headline)
                                FlowLayout(spacing: 8) {
                                    ForEach(set.vocabulary, id: \.self) { word in
                                        Text(word)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "mic.fill",
                        title: "Generate Speaking Questions",
                        subtitle: "AI will create questions for all 3 parts",
                        buttonTitle: "Generate",
                        action: { Task { await loadSpeaking() } }
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Speaking")
    }

    func loadSpeaking() async {
        isLoading = true
        speakingSet = await apiService.generateSpeakingSet(topic: apiService.dailyTopic)
        isLoading = false
    }
}

struct Part1View: View {
    let questions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Part 1: Introduction")
                    .font(.headline)
                Text("4-5 minutes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                HStack(alignment: .top) {
                    Text("\(index + 1).")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text(question)
                    Spacer()
                    SpeakButton(text: question)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
        }
    }
}

struct Part2View: View {
    let cueCard: IELTSAPIService.CueCard
    let sampleAnswer: String?
    @State private var showSample = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Part 2: Cue Card")
                    .font(.headline)
                Text("3-4 minutes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(cueCard.mainTopic)
                    .font(.title3)
                    .fontWeight(.bold)

                Text("You should say:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(cueCard.bulletPoints, id: \.self) { point in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.red)
                        Text(point)
                            .font(.subheadline)
                    }
                }

                Divider()

                HStack {
                    Label("Think: \(cueCard.thinkTime)", systemImage: "clock")
                    Spacer()
                    Label("Speak: \(cueCard.speakTime)", systemImage: "waveform")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)

            if let sample = sampleAnswer {
                Button {
                    showSample = true
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("View Sample Answer")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showSample) {
                    NavigationStack {
                        ScrollView {
                            Text(sample)
                                .padding()
                        }
                        .navigationTitle("Sample Answer")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") { showSample = false }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct Part3View: View {
    let questions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Part 3: Discussion")
                    .font(.headline)
                Text("4-5 minutes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                HStack(alignment: .top) {
                    Text("\(index + 1).")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text(question)
                    Spacer()
                    SpeakButton(text: question)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - AI Listening View
struct AIListeningView: View {
    @ObservedObject var apiService = IELTSAPIService.shared
    @State private var exercise: IELTSAPIService.ListeningExercise?
    @State private var isLoading = false
    @State private var selectedSection = 1
    @State private var showTranscript = false
    @State private var userAnswers: [UUID: String] = [:]
    @State private var showResults = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Section Picker
                Picker("Section", selection: $selectedSection) {
                    Text("Section 1").tag(1)
                    Text("Section 2").tag(2)
                    Text("Section 3").tag(3)
                    Text("Section 4").tag(4)
                }
                .pickerStyle(.segmented)

                HStack {
                    Label(apiService.dailyTopic, systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(8)
                    Spacer()
                    Button {
                        Task { await loadExercise() }
                    } label: {
                        Label("New Exercise", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                }

                if isLoading {
                    LoadingView(message: "AI generating listening exercise...")
                } else if let exercise = exercise {
                    VStack(alignment: .leading, spacing: 16) {
                        // Exercise Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text(exercise.title)
                                    .font(.headline)
                                Text("Section \(exercise.section)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                showTranscript = true
                            } label: {
                                Label("Transcript", systemImage: "doc.text")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(12)

                        // Play Audio (TTS)
                        Button {
                            speakTranscript(exercise.transcript)
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                Text("Play Audio")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(12)
                        }

                        // Questions
                        ForEach(Array(exercise.questions.enumerated()), id: \.element.id) { index, question in
                            AIListeningQuestionCard(
                                index: index + 1,
                                question: question,
                                userAnswer: userAnswers[question.id] ?? "",
                                showResults: showResults,
                                onAnswerChange: { answer in
                                    userAnswers[question.id] = answer
                                }
                            )
                        }

                        // Check Answers
                        Button {
                            showResults = true
                        } label: {
                            Text(showResults ? "Score: \(calculateScore())/\(exercise.questions.count)" : "Check Answers")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(showResults ? Color.green : Color.blue)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "headphones",
                        title: "Generate Listening Exercise",
                        subtitle: "AI will create a transcript with questions",
                        buttonTitle: "Generate",
                        action: { Task { await loadExercise() } }
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Listening")
        .sheet(isPresented: $showTranscript) {
            if let exercise = exercise {
                TranscriptSheet(transcript: exercise.transcript)
            }
        }
    }

    func loadExercise() async {
        isLoading = true
        userAnswers = [:]
        showResults = false
        exercise = await apiService.generateListeningExercise(topic: apiService.dailyTopic, section: selectedSection)
        isLoading = false
    }

    func speakTranscript(_ text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }

    func calculateScore() -> Int {
        guard let exercise = exercise else { return 0 }
        var score = 0
        for question in exercise.questions {
            if let userAnswer = userAnswers[question.id],
               userAnswer.lowercased().trimmingCharacters(in: .whitespaces) == question.answer.lowercased() {
                score += 1
            }
        }
        return score
    }
}

struct AIListeningQuestionCard: View {
    let index: Int
    let question: IELTSAPIService.ListeningQuestion
    let userAnswer: String
    let showResults: Bool
    let onAnswerChange: (String) -> Void

    @State private var answer: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Q\(index). \(question.question)")
                .font(.subheadline)
                .fontWeight(.medium)

            TextField("Your answer...", text: $answer)
                .textFieldStyle(.roundedBorder)
                .disabled(showResults)
                .onChange(of: answer) { _, newValue in
                    onAnswerChange(newValue)
                }

            if showResults {
                HStack {
                    if answer.lowercased().trimmingCharacters(in: .whitespaces) == question.answer.lowercased() {
                        Label("Correct!", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Label("Answer: \(question.answer)", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

struct TranscriptSheet: View {
    let transcript: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(transcript)
                    .font(.body)
                    .lineSpacing(6)
                    .padding()
            }
            .navigationTitle("Transcript")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - AI Grammar View
struct AIGrammarView: View {
    @ObservedObject var apiService = IELTSAPIService.shared
    @State private var lesson: IELTSAPIService.GrammarLesson?
    @State private var isLoading = false
    @State private var selectedAnswers: [UUID: Int] = [:]
    @State private var showResults = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Label(apiService.dailyTopic, systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(8)
                    Spacer()
                    Button {
                        Task { await loadLesson() }
                    } label: {
                        Label("New Lesson", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                }

                if isLoading {
                    LoadingView(message: "AI generating grammar lesson...")
                } else if let lesson = lesson {
                    VStack(alignment: .leading, spacing: 16) {
                        // Topic
                        Text(lesson.topic)
                            .font(.title2)
                            .fontWeight(.bold)

                        // Explanation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Explanation")
                                .font(.headline)
                            Text(lesson.explanation)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)

                        // Bangla Explanation
                        if !lesson.banglaExplanation.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("বাংলায় ব্যাখ্যা", systemImage: "globe.asia.australia.fill")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                Text(lesson.banglaExplanation)
                                    .font(.body)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Examples
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Examples")
                                .font(.headline)
                            ForEach(lesson.examples, id: \.self) { example in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text(example)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)

                        // Exercises
                        Text("Practice Exercises")
                            .font(.headline)

                        ForEach(Array(lesson.exercises.enumerated()), id: \.element.id) { index, exercise in
                            AIGrammarExerciseCard(
                                index: index + 1,
                                exercise: exercise,
                                selectedAnswer: selectedAnswers[exercise.id],
                                showResults: showResults,
                                onSelect: { answer in
                                    selectedAnswers[exercise.id] = answer
                                }
                            )
                        }

                        // Check Answers
                        Button {
                            showResults = true
                        } label: {
                            Text(showResults ? "Score: \(calculateScore())/\(lesson.exercises.count)" : "Check Answers")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(showResults ? Color.green : Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                } else {
                    EmptyStateView(
                        icon: "textformat",
                        title: "Generate Grammar Lesson",
                        subtitle: "AI will create a lesson with exercises",
                        buttonTitle: "Generate",
                        action: { Task { await loadLesson() } }
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Grammar")
    }

    func loadLesson() async {
        isLoading = true
        selectedAnswers = [:]
        showResults = false
        lesson = await apiService.generateGrammarLesson(topic: apiService.dailyTopic)
        isLoading = false
    }

    func calculateScore() -> Int {
        guard let lesson = lesson else { return 0 }
        var score = 0
        for exercise in lesson.exercises {
            if selectedAnswers[exercise.id] == exercise.correctAnswer {
                score += 1
            }
        }
        return score
    }
}

struct AIGrammarExerciseCard: View {
    let index: Int
    let exercise: IELTSAPIService.GrammarExercise
    let selectedAnswer: Int?
    let showResults: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Q\(index). \(exercise.question)")
                .font(.subheadline)
                .fontWeight(.medium)

            ForEach(Array(exercise.options.enumerated()), id: \.offset) { optionIndex, option in
                Button {
                    if !showResults {
                        onSelect(optionIndex)
                    }
                } label: {
                    HStack {
                        Text("\(["A", "B", "C", "D"][optionIndex]).")
                            .fontWeight(.medium)
                        Text(option)
                        Spacer()

                        if showResults {
                            if optionIndex == exercise.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else if optionIndex == selectedAnswer && optionIndex != exercise.correctAnswer {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        } else if selectedAnswer == optionIndex {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    .font(.subheadline)
                    .padding()
                    .background(optionBackground(optionIndex))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            if showResults {
                Text("💡 \(exercise.explanation)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    func optionBackground(_ index: Int) -> Color {
        if showResults {
            if index == exercise.correctAnswer {
                return Color.green.opacity(0.2)
            } else if index == selectedAnswer && index != exercise.correctAnswer {
                return Color.red.opacity(0.2)
            }
        } else if selectedAnswer == index {
            return Color.blue.opacity(0.1)
        }
        return Color.gray.opacity(0.1)
    }
}

// MARK: - Helper Views
struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("AI থেকে content আনা হচ্ছে...")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Label(buttonTitle, systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
}

// MARK: - Interactive Reading Text
struct SelectedWord: Identifiable {
    let id = UUID()
    let word: String
}

struct InteractiveReadingText: View {
    let text: String
    @State private var selectedWord: SelectedWord?

    var body: some View {
        FlowLayoutText(text: text) { word in
            selectedWord = SelectedWord(word: word)
        }
        .sheet(item: $selectedWord) { selected in
            WordLookupSheet(word: selected.word)
        }
    }
}

struct FlowLayoutText: View {
    let text: String
    let onWordTap: (String) -> Void

    var words: [String] {
        text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FlowLayout(spacing: 4) {
                ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                    Text(word + " ")
                        .font(.body)
                        .lineSpacing(6)
                        .onLongPressGesture(minimumDuration: 0.5) {
                            let cleanWord = word.trimmingCharacters(in: CharacterSet.letters.inverted)
                            if !cleanWord.isEmpty {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                onWordTap(cleanWord)
                            }
                        }
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct WordLookupSheet: View {
    let word: String
    @Environment(\.dismiss) var dismiss
    @State private var explanation: String?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("AI থেকে শব্দের অর্থ আনা হচ্ছে...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 200)
                    } else if let explanation = explanation {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(word.capitalized)
                                    .font(.title)
                                    .fontWeight(.bold)
                                Spacer()
                                SpeakButton(text: word, size: .large)
                            }

                            Divider()

                            Text(explanation)
                                .font(.body)
                                .lineSpacing(6)
                        }
                        .padding()
                    } else {
                        Text("Could not fetch word explanation")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Word Meaning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                explanation = await IELTSAPIService.shared.explainWord(word: word)
                isLoading = false
            }
        }
    }
}

// MARK: - Vocabulary Card (for Learn section)
struct VocabularyCard: View {
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.teal, .teal.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: "textformat.abc")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Vocabulary Builder")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }

                Text("Learn new words, flashcards & spaced repetition")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label("Flashcards", systemImage: "rectangle.stack.fill")
                    Label("Quiz", systemImage: "questionmark.circle.fill")
                }
                .font(.caption2)
                .foregroundColor(.teal.opacity(0.8))
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
    LessonsView()
}
