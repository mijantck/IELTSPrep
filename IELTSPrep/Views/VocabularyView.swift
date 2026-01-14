import SwiftUI
import SwiftData
import AVFoundation

// MARK: - Speech Manager for Pronunciation
class SpeechManager: ObservableObject {
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false

    func speak(_ text: String) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4  // Slower for learning
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

// MARK: - Pronunciation Button Component
struct PronunciationButton: View {
    let word: String
    @StateObject private var speechManager = SpeechManager.shared
    @State private var isAnimating = false

    var body: some View {
        Button {
            isAnimating = true
            speechManager.speak(word)

            // Reset animation after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isAnimating = false
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isAnimating ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .symbolEffect(.variableColor.iterative, isActive: isAnimating)
            }
            .padding(10)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Circle())
            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(isAnimating ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isAnimating)
    }
}

struct VocabularyView: View {
    @State private var selectedTab: VocabTab = .today
    @State private var selectedCategory: IELTSVocabWord.VocabCategory = .daily

    enum VocabTab: String, CaseIterable {
        case today = "Today"
        case categories = "Categories"
        case quiz = "Quiz"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Tab Selector
                HStack(spacing: 0) {
                    ForEach(VocabTab.allCases, id: \.rawValue) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(tab.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(selectedTab == tab ? .semibold : .regular)
                                    .foregroundColor(selectedTab == tab ? .blue : .secondary)

                                Rectangle()
                                    .fill(selectedTab == tab ? Color.blue : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Content
                TabView(selection: $selectedTab) {
                    TodaysWordsView()
                        .tag(VocabTab.today)

                    CategoriesView(selectedCategory: $selectedCategory)
                        .tag(VocabTab.categories)

                    VocabQuizView()
                        .tag(VocabTab.quiz)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Vocabulary")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Today's Words View
struct TodaysWordsView: View {
    @State private var currentIndex = 0
    @State private var showDetails = false
    @State private var learnedWords: Set<UUID> = []

    let todaysWords = VocabularyDatabase.getTodaysWords()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("আজকের ১০টি শব্দ")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    Text("Daily vocabulary for \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Progress
                    HStack {
                        Text("\(learnedWords.count)/10 learned")
                            .font(.caption)
                            .foregroundColor(.green)
                        Spacer()
                        ProgressView(value: Double(learnedWords.count), total: 10)
                            .frame(width: 100)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                // Flashcard
                if currentIndex < todaysWords.count {
                    EnhancedFlashcard(
                        word: todaysWords[currentIndex],
                        showDetails: $showDetails,
                        isLearned: learnedWords.contains(todaysWords[currentIndex].id),
                        onMarkLearned: {
                            learnedWords.insert(todaysWords[currentIndex].id)
                            if currentIndex < todaysWords.count - 1 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    currentIndex += 1
                                    showDetails = false
                                }
                            }
                        }
                    )
                }

                // Navigation
                HStack(spacing: 16) {
                    Button {
                        if currentIndex > 0 {
                            currentIndex -= 1
                            showDetails = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .disabled(currentIndex == 0)
                    .opacity(currentIndex == 0 ? 0.5 : 1)

                    Button {
                        if currentIndex < todaysWords.count - 1 {
                            currentIndex += 1
                            showDetails = false
                        }
                    } label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(currentIndex == todaysWords.count - 1)
                    .opacity(currentIndex == todaysWords.count - 1 ? 0.5 : 1)
                }
                .padding(.horizontal)

                // Word Progress Dots
                HStack(spacing: 6) {
                    ForEach(Array(todaysWords.enumerated()), id: \.element.id) { index, word in
                        Circle()
                            .fill(
                                learnedWords.contains(word.id) ? Color.green :
                                    (index == currentIndex ? Color.blue : Color.gray.opacity(0.3))
                            )
                            .frame(width: index == currentIndex ? 10 : 8, height: index == currentIndex ? 10 : 8)
                    }
                }
                .padding(.bottom)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Enhanced Flashcard
struct EnhancedFlashcard: View {
    let word: IELTSVocabWord
    @Binding var showDetails: Bool
    let isLearned: Bool
    let onMarkLearned: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Main Card
            VStack(spacing: 16) {
                // Icon & Category
                HStack {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: word.icon)
                            .font(.title2)
                            .foregroundColor(categoryColor)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(word.category.rawValue.components(separatedBy: " ").first ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(word.difficulty.rawValue.components(separatedBy: " ").first ?? "")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(difficultyColor.opacity(0.2))
                            .cornerRadius(4)
                    }
                }

                // Word with Pronunciation Button
                HStack(spacing: 12) {
                    Text(word.word.capitalized)
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.primary)

                    PronunciationButton(word: word.word)
                }

                // Part of Speech
                Text(word.partOfSpeech.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(12)

                Divider()

                // Meanings
                VStack(spacing: 12) {
                    // Bangla Meaning (Always visible)
                    HStack {
                        Image(systemName: "globe.asia.australia.fill")
                            .foregroundColor(.orange)
                        Text(word.banglaMeaning)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }

                    // English Meaning
                    Text(word.englishMeaning)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Tap to reveal more
                if !showDetails {
                    Button {
                        withAnimation(.spring()) {
                            showDetails = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.down")
                            Text("Tap for example & grammar tips")
                            Image(systemName: "chevron.down")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10)
            .onTapGesture {
                withAnimation(.spring()) {
                    showDetails.toggle()
                }
            }

            // Expanded Details
            if showDetails {
                VStack(spacing: 16) {
                    // Example Sentence
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.quote")
                                .foregroundColor(.purple)
                            Text("Example")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }

                        Text(word.example)
                            .font(.subheadline)
                            .italic()

                        Text(word.exampleBangla)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)

                    // Grammar Tip
                    if let grammarTip = word.grammarTip {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Grammar Tip")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }

                            Text(grammarTip)
                                .font(.caption)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.yellow.opacity(0.15))
                        .cornerRadius(12)
                    }

                    // Synonyms
                    if !word.synonyms.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "equal.circle.fill")
                                    .foregroundColor(.green)
                                Text("Synonyms (সমার্থক শব্দ)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }

                            FlowLayout(spacing: 6) {
                                ForEach(word.synonyms, id: \.self) { synonym in
                                    Text(synonym)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.15))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.05))
                        .cornerRadius(12)
                    }

                    // Collocations
                    if !word.collocations.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Common Combinations (শব্দ যোগ)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }

                            ForEach(word.collocations, id: \.self) { collocation in
                                Text("• \(collocation)")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                    }

                    // Mark as Learned Button
                    if !isLearned {
                        Button {
                            onMarkLearned()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("I Learned This! (শিখেছি)")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("Learned!")
                                .foregroundColor(.green)
                        }
                        .font(.headline)
                        .padding()
                    }
                }
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .animation(.spring(), value: showDetails)
    }

    var categoryColor: Color {
        switch word.category {
        case .academic: return .blue
        case .environment: return .green
        case .technology: return .purple
        case .society: return .orange
        case .health: return .red
        case .education: return .indigo
        case .business: return .brown
        case .opinion: return .pink
        case .linking: return .teal
        case .daily: return .yellow
        }
    }

    var difficultyColor: Color {
        switch word.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Categories View
struct CategoriesView: View {
    @Binding var selectedCategory: IELTSVocabWord.VocabCategory
    @State private var showCategoryWords = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Text("Browse by Category")
                        .font(.headline)
                    Text("বিষয় অনুযায়ী শব্দ খুঁজুন")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Category Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(IELTSVocabWord.VocabCategory.allCases, id: \.rawValue) { category in
                        CategoryCard(category: category) {
                            selectedCategory = category
                            showCategoryWords = true
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .sheet(isPresented: $showCategoryWords) {
            CategoryWordsSheet(category: selectedCategory)
        }
    }
}

struct CategoryCard: View {
    let category: IELTSVocabWord.VocabCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(categoryColor)
                }

                VStack(spacing: 2) {
                    Text(category.rawValue.components(separatedBy: "(").first ?? "")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text("\(VocabularyDatabase.getWords(for: category).count) words")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
    }

    var categoryColor: Color {
        switch category {
        case .academic: return .blue
        case .environment: return .green
        case .technology: return .purple
        case .society: return .orange
        case .health: return .red
        case .education: return .indigo
        case .business: return .brown
        case .opinion: return .pink
        case .linking: return .teal
        case .daily: return .yellow
        }
    }
}

struct CategoryWordsSheet: View {
    let category: IELTSVocabWord.VocabCategory
    @Environment(\.dismiss) var dismiss

    var words: [IELTSVocabWord] {
        VocabularyDatabase.getWords(for: category)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(words) { word in
                    NavigationLink {
                        WordDetailView(word: word)
                    } label: {
                        WordRowView(word: word)
                    }
                }
            }
            .navigationTitle(category.rawValue.components(separatedBy: "(").first ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct WordRowView: View {
    let word: IELTSVocabWord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: word.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(word.word.capitalized)
                        .font(.headline)

                    // Small pronunciation button
                    Button {
                        SpeechManager.shared.speak(word.word)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Text(word.banglaMeaning)
                    .font(.subheadline)
                    .foregroundColor(.orange)

                Text(word.englishMeaning)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct WordDetailView: View {
    let word: IELTSVocabWord

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: word.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.blue)

                    HStack(spacing: 16) {
                        Text(word.word.capitalized)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        PronunciationButton(word: word.word)
                    }

                    Text(word.partOfSpeech.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                }
                .padding()

                // Meanings
                VStack(spacing: 16) {
                    MeaningRow(title: "বাংলা অর্থ", content: word.banglaMeaning, color: .orange, icon: "globe.asia.australia.fill")
                    MeaningRow(title: "English Meaning", content: word.englishMeaning, color: .blue, icon: "textformat.abc")
                }
                .padding(.horizontal)

                // Example
                VStack(alignment: .leading, spacing: 8) {
                    Label("Example", systemImage: "text.quote")
                        .font(.headline)
                        .foregroundColor(.purple)

                    Text(word.example)
                        .italic()

                    Text(word.exampleBangla)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                // Grammar Tip
                if let tip = word.grammarTip {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Grammar Tip", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundColor(.yellow)

                        Text(tip)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Synonyms
                if !word.synonyms.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Synonyms", systemImage: "equal.circle.fill")
                            .font(.headline)
                            .foregroundColor(.green)

                        FlowLayout(spacing: 8) {
                            ForEach(word.synonyms, id: \.self) { syn in
                                Text(syn)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Collocations
                if !word.collocations.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Common Combinations", systemImage: "link.circle.fill")
                            .font(.headline)
                            .foregroundColor(.blue)

                        ForEach(word.collocations, id: \.self) { coll in
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text(coll)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(word.word)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MeaningRow: View {
    let title: String
    let content: String
    let color: Color
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(content)
                    .font(.body)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Quiz View
struct VocabQuizView: View {
    @State private var quizStarted = false
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var quizWords: [IELTSVocabWord] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !quizStarted {
                    // Quiz Start Screen
                    VStack(spacing: 20) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 80))
                            .foregroundColor(.purple)

                        Text("Vocabulary Quiz")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Test your vocabulary knowledge!\n১০টি শব্দের অর্থ পরীক্ষা করুন")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button {
                            startQuiz()
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Quiz")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 60)
                } else if showResult {
                    // Result Screen
                    VStack(spacing: 20) {
                        Image(systemName: score >= 7 ? "trophy.fill" : "star.fill")
                            .font(.system(size: 80))
                            .foregroundColor(score >= 7 ? .yellow : .orange)

                        Text("Quiz Complete!")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("\(score)/10")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(score >= 7 ? .green : .orange)

                        Text(scoreMessage)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Button {
                            startQuiz()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Try Again")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 60)
                } else {
                    // Quiz Question
                    QuizQuestionView(
                        word: quizWords[currentQuestion],
                        questionNumber: currentQuestion + 1,
                        totalQuestions: quizWords.count,
                        options: getOptions(for: quizWords[currentQuestion]),
                        selectedAnswer: $selectedAnswer,
                        onSubmit: submitAnswer
                    )
                }
            }
            .padding()
        }
    }

    var scoreMessage: String {
        switch score {
        case 10: return "Perfect! অসাধারণ!"
        case 8...9: return "Excellent! চমৎকার!"
        case 6...7: return "Good job! ভালো হয়েছে!"
        case 4...5: return "Keep practicing! আরও অনুশীলন করুন"
        default: return "Need more practice! আরও পড়তে হবে"
        }
    }

    func startQuiz() {
        quizWords = Array(VocabularyDatabase.allWords.shuffled().prefix(10))
        currentQuestion = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        quizStarted = true
    }

    func getOptions(for word: IELTSVocabWord) -> [String] {
        var options = [word.banglaMeaning]
        let otherWords = VocabularyDatabase.allWords.filter { $0.id != word.id }
        for w in otherWords.shuffled().prefix(3) {
            options.append(w.banglaMeaning)
        }
        return options.shuffled()
    }

    func submitAnswer() {
        if selectedAnswer == quizWords[currentQuestion].banglaMeaning {
            score += 1
        }

        if currentQuestion < quizWords.count - 1 {
            currentQuestion += 1
            selectedAnswer = nil
        } else {
            showResult = true
        }
    }
}

struct QuizQuestionView: View {
    let word: IELTSVocabWord
    let questionNumber: Int
    let totalQuestions: Int
    let options: [String]
    @Binding var selectedAnswer: String?
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Progress
            HStack {
                Text("Question \(questionNumber)/\(totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                ProgressView(value: Double(questionNumber), total: Double(totalQuestions))
                    .frame(width: 100)
            }

            // Question
            VStack(spacing: 12) {
                Text("What is the Bangla meaning of:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: word.icon)
                        .font(.title)
                        .foregroundColor(.blue)

                    Text(word.word.capitalized)
                        .font(.title)
                        .fontWeight(.bold)
                }

                Text("(\(word.partOfSpeech.rawValue.components(separatedBy: "(").first ?? ""))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(16)

            // Options
            ForEach(options, id: \.self) { option in
                Button {
                    selectedAnswer = option
                } label: {
                    HStack {
                        Image(systemName: selectedAnswer == option ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedAnswer == option ? .blue : .gray)

                        Text(option)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding()
                    .background(
                        selectedAnswer == option ? Color.blue.opacity(0.1) : Color(.systemBackground)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedAnswer == option ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }

            // Submit Button
            Button {
                onSubmit()
            } label: {
                Text("Submit Answer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedAnswer != nil ? Color.green : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(selectedAnswer == nil)
        }
    }
}

// MARK: - Progress View (Tab)
struct MyProgressView: View {
    @Query private var writingPractices: [WritingPractice]
    @Query private var learnedWords: [VocabularyWord]

    var body: some View {
        NavigationStack {
            List {
                Section("Overall Progress") {
                    ProgressRow(title: "Essays Written", value: "\(writingPractices.count)", icon: "doc.text", color: .orange)
                    ProgressRow(title: "Words Learned", value: "\(learnedWords.filter { $0.isLearned }.count)", icon: "book", color: .purple)
                    ProgressRow(title: "Days Until Exam", value: "\(daysUntilExam)", icon: "calendar", color: .blue)
                }

                Section("Recent Writing Scores") {
                    if writingPractices.isEmpty {
                        Text("No essays written yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(writingPractices.prefix(5)) { practice in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(practice.topic.prefix(50) + "...")
                                        .font(.caption)
                                        .lineLimit(1)
                                    Text(practice.createdAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(String(format: "%.1f", practice.estimatedBand))
                                    .font(.headline)
                                    .foregroundColor(practice.estimatedBand >= 6.5 ? .green : .orange)
                            }
                        }
                    }
                }

                Section("Study Tips") {
                    Text("Practice writing every day for consistent improvement")
                    Text("Focus on learning 10 new words daily")
                    Text("Review grammar rules regularly")
                }
            }
            .navigationTitle("My Progress")
        }
    }

    var daysUntilExam: Int {
        let examDate = ExamConfig.examDate
        let components = Calendar.current.dateComponents([.day], from: Date(), to: examDate)
        return max(0, components.day ?? 0)
    }
}

struct ProgressRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)

            Text(title)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    VocabularyView()
}
