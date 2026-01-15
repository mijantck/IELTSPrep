import SwiftUI

// MARK: - Book Theme Colors
struct BookTheme {
    static let pageBackground = Color(red: 0.98, green: 0.96, blue: 0.92) // Cream paper
    static let coverRed = Color(red: 0.7, green: 0.1, blue: 0.15) // Cambridge red
    static let coverBlue = Color(red: 0.1, green: 0.2, blue: 0.5) // Deep blue
    static let goldAccent = Color(red: 0.85, green: 0.65, blue: 0.2) // Gold text
    static let textDark = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let pageShadow = Color.black.opacity(0.1)
}

// MARK: - Main Mock Test View
struct MockTestView: View {
    @State private var selectedBook: CambridgeBook?

    var body: some View {
        NavigationStack {
            ZStack {
                // Bookshelf background
                LinearGradient(
                    colors: [Color(red: 0.3, green: 0.2, blue: 0.15), Color(red: 0.2, green: 0.15, blue: 0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        Text("Cambridge IELTS")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        Text("Practice Tests")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .foregroundColor(.white.opacity(0.8))

                        // Book Shelf
                        VStack(spacing: 30) {
                            BookShelfRow(books: [.cambridge16, .cambridge17, .cambridge18]) { book in
                                selectedBook = book
                            }

                            BookShelfRow(books: [.cambridge15, .cambridge14, .cambridge13]) { book in
                                selectedBook = book
                            }
                        }
                        .padding(.top, 20)

                        // Info Card
                        BookInfoCard()
                            .padding(.horizontal)
                            .padding(.top, 20)
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedBook) { book in
                TestSelectionView(book: book)
            }
        }
    }
}

// MARK: - Cambridge Book Enum
enum CambridgeBook: String, Identifiable, CaseIterable {
    case cambridge13 = "13"
    case cambridge14 = "14"
    case cambridge15 = "15"
    case cambridge16 = "16"
    case cambridge17 = "17"
    case cambridge18 = "18"

    var id: String { rawValue }

    var title: String {
        "Cambridge IELTS \(rawValue)"
    }

    var subtitle: String {
        "Academic"
    }

    var coverColor: Color {
        switch self {
        case .cambridge13: return Color(red: 0.6, green: 0.2, blue: 0.2)
        case .cambridge14: return Color(red: 0.2, green: 0.3, blue: 0.6)
        case .cambridge15: return Color(red: 0.5, green: 0.15, blue: 0.15)
        case .cambridge16: return Color(red: 0.15, green: 0.35, blue: 0.55)
        case .cambridge17: return Color(red: 0.55, green: 0.2, blue: 0.25)
        case .cambridge18: return Color(red: 0.2, green: 0.25, blue: 0.5)
        }
    }
}

// MARK: - Book Shelf Row
struct BookShelfRow: View {
    let books: [CambridgeBook]
    let onBookTap: (CambridgeBook) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                ForEach(books) { book in
                    BookCoverView(book: book)
                        .onTapGesture {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            onBookTap(book)
                        }
                }
            }
            .padding(.horizontal)

            // Shelf
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.45, green: 0.3, blue: 0.2), Color(red: 0.35, green: 0.22, blue: 0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 15)
                .shadow(color: .black.opacity(0.5), radius: 5, y: 3)
        }
    }
}

// MARK: - Book Cover View
struct BookCoverView: View {
    let book: CambridgeBook
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 0) {
            // Book spine effect
            ZStack {
                // Main cover
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [book.coverColor, book.coverColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 95, height: 140)
                    .overlay(
                        // Spine line
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 3)
                            .padding(.leading, 5),
                        alignment: .leading
                    )
                    .overlay(
                        // Book content
                        VStack(spacing: 4) {
                            Spacer()

                            Text("CAMBRIDGE")
                                .font(.system(size: 8, weight: .bold, design: .serif))
                                .foregroundColor(.white.opacity(0.9))

                            Text("IELTS")
                                .font(.system(size: 20, weight: .black, design: .serif))
                                .foregroundColor(.white)

                            Text(book.rawValue)
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(BookTheme.goldAccent)

                            Text(book.subtitle)
                                .font(.system(size: 9, weight: .medium, design: .serif))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.top, 2)

                            Spacer()

                            // Cambridge logo placeholder
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 50, height: 20)
                                .overlay(
                                    Text("CAMBRIDGE")
                                        .font(.system(size: 5, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                )

                            Spacer().frame(height: 10)
                        }
                    )
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 2, y: 2)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: isPressed)
        }
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Book Info Card
struct BookInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(BookTheme.goldAccent)
                Text("About Practice Tests")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
            }

            Text("AI-generated tests following exact Cambridge IELTS format. Each test includes Reading, Listening, Writing, and Speaking sections with authentic question types.")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.secondary)
                .lineSpacing(4)

            Divider()

            HStack(spacing: 20) {
                InfoBadge(icon: "doc.text", text: "40 Questions", subtitle: "Reading")
                InfoBadge(icon: "headphones", text: "40 Questions", subtitle: "Listening")
                InfoBadge(icon: "pencil", text: "2 Tasks", subtitle: "Writing")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(BookTheme.pageBackground)
                .shadow(color: .black.opacity(0.2), radius: 5)
        )
    }
}

struct InfoBadge: View {
    let icon: String
    let text: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(BookTheme.coverRed)
            Text(text)
                .font(.system(size: 11, weight: .semibold, design: .serif))
            Text(subtitle)
                .font(.system(size: 9, design: .serif))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Test Selection View (Book Interior)
struct TestSelectionView: View {
    let book: CambridgeBook
    @Environment(\.dismiss) var dismiss
    @State private var selectedTest: Int?

    var body: some View {
        NavigationStack {
            ZStack {
                // Paper background
                BookTheme.pageBackground
                    .ignoresSafeArea()

                // Page texture
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.02)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Book Header
                        BookHeaderView(book: book)

                        // Contents Page
                        ContentsPageView(book: book, selectedTest: $selectedTest)

                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .fullScreenCover(item: $selectedTest) { testNumber in
                MockTestSessionView(book: book, testNumber: testNumber)
            }
        }
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}

// MARK: - Book Header View
struct BookHeaderView: View {
    let book: CambridgeBook

    var body: some View {
        VStack(spacing: 16) {
            // Decorative line
            Rectangle()
                .fill(book.coverColor)
                .frame(height: 4)

            VStack(spacing: 8) {
                Text("CAMBRIDGE")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(.secondary)
                    .tracking(4)

                Text("IELTS \(book.rawValue)")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(BookTheme.textDark)

                Text("Academic Student's Book")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(.secondary)

                Text("with Answers")
                    .font(.system(size: 12, design: .serif))
                    .italic()
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)

            // Decorative line
            Rectangle()
                .fill(book.coverColor)
                .frame(height: 2)
                .padding(.horizontal, 50)
        }
        .padding(.top)
    }
}

// MARK: - Contents Page View
struct ContentsPageView: View {
    let book: CambridgeBook
    @Binding var selectedTest: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Contents Title
            HStack {
                Spacer()
                Text("Contents")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .italic()
                Spacer()
            }
            .padding(.top, 30)

            // Test entries
            VStack(spacing: 0) {
                ForEach(1...4, id: \.self) { testNum in
                    TestEntryRow(testNumber: testNum, book: book) {
                        selectedTest = testNum
                    }

                    if testNum < 4 {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.5))
                    .shadow(color: BookTheme.pageShadow, radius: 2)
            )
            .padding(.horizontal)

            // Additional sections
            VStack(alignment: .leading, spacing: 16) {
                Text("Additional Materials")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .padding(.horizontal)

                AdditionalSectionRow(icon: "text.book.closed", title: "Listening Scripts", page: "118")
                AdditionalSectionRow(icon: "checkmark.circle", title: "Answer Keys", page: "142")
                AdditionalSectionRow(icon: "chart.bar", title: "Sample Answer Sheets", page: "160")
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Test Entry Row
struct TestEntryRow: View {
    let testNumber: Int
    let book: CambridgeBook
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Test \(testNumber)")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(BookTheme.textDark)

                    VStack(alignment: .leading, spacing: 4) {
                        TestSectionRow(name: "Listening", icon: "headphones")
                        TestSectionRow(name: "Reading", icon: "doc.text")
                        TestSectionRow(name: "Writing", icon: "pencil.line")
                        TestSectionRow(name: "Speaking", icon: "mic")
                    }
                }

                Spacer()

                VStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(book.coverColor)

                    Text("Start")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .foregroundColor(book.coverColor)
                }
            }
            .padding()
        }
    }
}

struct TestSectionRow: View {
    let name: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(width: 16)
            Text(name)
                .font(.system(size: 13, design: .serif))
                .foregroundColor(.secondary)
        }
    }
}

struct AdditionalSectionRow: View {
    let icon: String
    let title: String
    let page: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 14, design: .serif))

            // Dotted line
            GeometryReader { geo in
                Path { path in
                    let y = geo.size.height / 2
                    for x in stride(from: 0, to: geo.size.width, by: 8) {
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: x + 3, y: y))
                    }
                }
                .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
            }
            .frame(height: 20)

            Text(page)
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

// MARK: - Mock Test Session View
struct MockTestSessionView: View {
    let book: CambridgeBook
    let testNumber: Int
    @Environment(\.dismiss) var dismiss
    @State private var currentSection: TestSection = .reading
    @State private var showExitAlert = false

    enum TestSection: String, CaseIterable {
        case listening = "Listening"
        case reading = "Reading"
        case writing = "Writing"
        case speaking = "Speaking"

        var icon: String {
            switch self {
            case .listening: return "headphones"
            case .reading: return "doc.text"
            case .writing: return "pencil.line"
            case .speaking: return "mic"
            }
        }

        var duration: String {
            switch self {
            case .listening: return "30 min"
            case .reading: return "60 min"
            case .writing: return "60 min"
            case .speaking: return "15 min"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BookTheme.pageBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Section Tabs
                    SectionTabsView(currentSection: $currentSection, bookColor: book.coverColor)

                    // Content
                    TabView(selection: $currentSection) {
                        ListeningTestView(book: book, testNumber: testNumber)
                            .tag(TestSection.listening)

                        ReadingTestView(book: book, testNumber: testNumber)
                            .tag(TestSection.reading)

                        WritingTestView(book: book, testNumber: testNumber)
                            .tag(TestSection.writing)

                        SpeakingTestView(book: book, testNumber: testNumber)
                            .tag(TestSection.speaking)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("\(book.title) - Test \(testNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Exit") {
                        showExitAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Exit Test?", isPresented: $showExitAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Exit", role: .destructive) { dismiss() }
            } message: {
                Text("Your progress will not be saved.")
            }
        }
    }
}

// MARK: - Section Tabs View
struct SectionTabsView: View {
    @Binding var currentSection: MockTestSessionView.TestSection
    let bookColor: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MockTestSessionView.TestSection.allCases, id: \.self) { section in
                    SectionTab(
                        section: section,
                        isSelected: currentSection == section,
                        bookColor: bookColor
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            currentSection = section
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.white.opacity(0.8))
        .shadow(color: BookTheme.pageShadow, radius: 2, y: 2)
    }
}

struct SectionTab: View {
    let section: MockTestSessionView.TestSection
    let isSelected: Bool
    let bookColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: section.icon)
                    .font(.system(size: 20))

                Text(section.rawValue)
                    .font(.system(size: 12, weight: .medium, design: .serif))

                Text(section.duration)
                    .font(.system(size: 10, design: .serif))
                    .foregroundColor(.secondary)
            }
            .foregroundColor(isSelected ? .white : bookColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? bookColor : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(bookColor, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

// MARK: - Reading Test View
struct ReadingTestView: View {
    let book: CambridgeBook
    let testNumber: Int
    @State private var readingContent: MockReadingTestContent?
    @State private var isLoading = true
    @State private var hasLoaded = false
    @State private var currentPassage = 0
    @State private var userAnswers: [Int: String] = [:]
    @State private var showAnswers = false
    @State private var timeRemaining = 60 * 60 // 60 minutes
    @State private var timerActive = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if isLoading {
                LoadingBookView(message: "Generating Reading Test...")
            } else if let content = readingContent {
                ScrollView {
                    VStack(spacing: 0) {
                        // Timer Bar
                        TimerBarView(timeRemaining: timeRemaining, totalTime: 60 * 60, bookColor: book.coverColor)

                        // Page indicator
                        PageIndicatorView(
                            currentPage: currentPassage + 1,
                            totalPages: content.passages.count,
                            bookColor: book.coverColor
                        )

                        // Passage Content
                        if currentPassage < content.passages.count {
                            PassageView(
                                passage: content.passages[currentPassage],
                                passageNumber: currentPassage + 1,
                                userAnswers: $userAnswers,
                                showAnswers: showAnswers
                            )
                        }

                        // Navigation
                        PassageNavigationView(
                            currentPassage: $currentPassage,
                            totalPassages: content.passages.count,
                            bookColor: book.coverColor
                        )

                        Spacer(minLength: 100)
                    }
                }
            } else {
                ErrorBookView(message: "Failed to load test") {
                    Task { await loadContent() }
                }
            }
        }
        .onAppear {
            timerActive = true
            if !hasLoaded {
                hasLoaded = true
                Task {
                    await loadContent()
                }
            }
        }
        .onReceive(timer) { _ in
            if timerActive && timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }

    func loadContent() async {
        isLoading = true
        readingContent = await IELTSAPIService.shared.generateCambridgeReadingTest(book: book.rawValue, testNumber: testNumber)
        isLoading = false
    }
}

// MARK: - Listening Test View
struct ListeningTestView: View {
    let book: CambridgeBook
    let testNumber: Int
    @State private var listeningContent: MockListeningTestContent?
    @State private var isLoading = true
    @State private var hasLoaded = false

    var body: some View {
        ZStack {
            if isLoading {
                LoadingBookView(message: "Generating Listening Test...")
            } else if let content = listeningContent {
                ScrollView {
                    VStack(spacing: 20) {
                        TimerBarView(timeRemaining: 30 * 60, totalTime: 30 * 60, bookColor: book.coverColor)

                        ForEach(Array(content.sections.enumerated()), id: \.offset) { index, section in
                            ListeningSectionCard(section: section, sectionNumber: index + 1, bookColor: book.coverColor)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            } else {
                ErrorBookView(message: "Failed to load test") {
                    Task { await loadContent() }
                }
            }
        }
        .onAppear {
            if !hasLoaded {
                hasLoaded = true
                Task {
                    await loadContent()
                }
            }
        }
    }

    func loadContent() async {
        isLoading = true
        listeningContent = await IELTSAPIService.shared.generateCambridgeListeningTest(book: book.rawValue, testNumber: testNumber)
        isLoading = false
    }
}

// MARK: - Writing Test View
struct WritingTestView: View {
    let book: CambridgeBook
    let testNumber: Int
    @State private var writingContent: MockWritingTestContent?
    @State private var isLoading = true
    @State private var hasLoaded = false
    @State private var task1Answer = ""
    @State private var task2Answer = ""
    @State private var currentTask = 1

    var body: some View {
        ZStack {
            if isLoading {
                LoadingBookView(message: "Generating Writing Test...")
            } else if let content = writingContent {
                ScrollView {
                    VStack(spacing: 20) {
                        TimerBarView(timeRemaining: 60 * 60, totalTime: 60 * 60, bookColor: book.coverColor)

                        // Task Selector
                        HStack(spacing: 12) {
                            TaskSelectorButton(taskNumber: 1, isSelected: currentTask == 1, bookColor: book.coverColor) {
                                currentTask = 1
                            }
                            TaskSelectorButton(taskNumber: 2, isSelected: currentTask == 2, bookColor: book.coverColor) {
                                currentTask = 2
                            }
                        }
                        .padding(.horizontal)

                        if currentTask == 1 {
                            WritingTaskCard(task: content.task1, taskNumber: 1, answer: $task1Answer, bookColor: book.coverColor)
                        } else {
                            WritingTaskCard(task: content.task2, taskNumber: 2, answer: $task2Answer, bookColor: book.coverColor)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            } else {
                ErrorBookView(message: "Failed to load test") {
                    Task { await loadContent() }
                }
            }
        }
        .onAppear {
            if !hasLoaded {
                hasLoaded = true
                Task {
                    await loadContent()
                }
            }
        }
    }

    func loadContent() async {
        isLoading = true
        writingContent = await IELTSAPIService.shared.generateCambridgeWritingTest(book: book.rawValue, testNumber: testNumber)
        isLoading = false
    }
}

// MARK: - Speaking Test View
struct SpeakingTestView: View {
    let book: CambridgeBook
    let testNumber: Int
    @State private var speakingContent: MockSpeakingTestContent?
    @State private var isLoading = true
    @State private var hasLoaded = false
    @State private var currentPart = 1

    var body: some View {
        ZStack {
            if isLoading {
                LoadingBookView(message: "Generating Speaking Test...")
            } else if let content = speakingContent {
                ScrollView {
                    VStack(spacing: 20) {
                        // Part Selector
                        HStack(spacing: 8) {
                            ForEach(1...3, id: \.self) { part in
                                PartSelectorButton(partNumber: part, isSelected: currentPart == part, bookColor: book.coverColor) {
                                    currentPart = part
                                }
                            }
                        }
                        .padding(.horizontal)

                        switch currentPart {
                        case 1:
                            SpeakingPartCard(part: content.part1, partNumber: 1, bookColor: book.coverColor)
                        case 2:
                            SpeakingPart2Card(part: content.part2, bookColor: book.coverColor)
                        case 3:
                            SpeakingPartCard(part: content.part3, partNumber: 3, bookColor: book.coverColor)
                        default:
                            EmptyView()
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            } else {
                ErrorBookView(message: "Failed to load test") {
                    Task { await loadContent() }
                }
            }
        }
        .onAppear {
            if !hasLoaded {
                hasLoaded = true
                Task {
                    await loadContent()
                }
            }
        }
    }

    func loadContent() async {
        isLoading = true
        speakingContent = await IELTSAPIService.shared.generateCambridgeSpeakingTest(book: book.rawValue, testNumber: testNumber)
        isLoading = false
    }
}

// MARK: - Supporting Views

struct LoadingBookView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            // Animated book
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(BookTheme.coverRed)
                .symbolEffect(.pulse)

            Text(message)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(.secondary)

            ProgressView()
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorBookView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text(message)
                .font(.system(size: 16, design: .serif))

            Button(action: retryAction) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(BookTheme.coverRed)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

struct TimerBarView: View {
    let timeRemaining: Int
    let totalTime: Int
    let bookColor: Color

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        Double(timeRemaining) / Double(totalTime)
    }

    var body: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(timeRemaining < 300 ? .red : bookColor)

            Text(formattedTime)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(timeRemaining < 300 ? .red : .primary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(timeRemaining < 300 ? Color.red : bookColor)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(color: BookTheme.pageShadow, radius: 2)
        .padding(.horizontal)
    }
}

struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int
    let bookColor: Color

    var body: some View {
        HStack {
            Text("Passage \(currentPage) of \(totalPages)")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.secondary)

            Spacer()

            HStack(spacing: 6) {
                ForEach(1...totalPages, id: \.self) { page in
                    Circle()
                        .fill(page == currentPage ? bookColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding()
    }
}

struct PassageNavigationView: View {
    @Binding var currentPassage: Int
    let totalPassages: Int
    let bookColor: Color

    var body: some View {
        HStack {
            Button(action: {
                if currentPassage > 0 {
                    withAnimation { currentPassage -= 1 }
                }
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(currentPassage > 0 ? bookColor : .gray)
            }
            .disabled(currentPassage == 0)

            Spacer()

            Button(action: {
                if currentPassage < totalPassages - 1 {
                    withAnimation { currentPassage += 1 }
                }
            }) {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(currentPassage < totalPassages - 1 ? bookColor : .gray)
            }
            .disabled(currentPassage >= totalPassages - 1)
        }
        .padding()
    }
}

// MARK: - Passage View
struct PassageView: View {
    let passage: MockReadingPassage
    let passageNumber: Int
    @Binding var userAnswers: [Int: String]
    let showAnswers: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Passage Title
            VStack(alignment: .leading, spacing: 8) {
                Text("READING PASSAGE \(passageNumber)")
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .foregroundColor(.secondary)
                    .tracking(2)

                Text(passage.title)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(BookTheme.textDark)
            }
            .padding(.horizontal)

            // Passage Text
            VStack(alignment: .leading, spacing: 12) {
                ForEach(passage.paragraphs.indices, id: \.self) { index in
                    Text(passage.paragraphs[index])
                        .font(.system(size: 15, design: .serif))
                        .lineSpacing(6)
                        .foregroundColor(BookTheme.textDark)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: BookTheme.pageShadow, radius: 3)
            )
            .padding(.horizontal)

            // Questions
            VStack(alignment: .leading, spacing: 16) {
                Text("Questions \(passage.questionRange)")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .padding(.horizontal)

                ForEach(passage.questions) { question in
                    QuestionView(
                        question: question,
                        userAnswer: Binding(
                            get: { userAnswers[question.number] ?? "" },
                            set: { userAnswers[question.number] = $0 }
                        ),
                        showAnswer: showAnswers
                    )
                }
            }
            .padding(.top)
        }
    }
}

struct QuestionView: View {
    let question: MockReadingQuestion
    @Binding var userAnswer: String
    let showAnswer: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("\(question.number).")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .frame(width: 30, alignment: .leading)

                Text(question.text)
                    .font(.system(size: 14, design: .serif))
            }

            switch question.type {
            case .multipleChoice:
                if let options = question.options {
                    ForEach(options, id: \.self) { option in
                        MCQOptionView(
                            option: option,
                            isSelected: userAnswer == option,
                            isCorrect: showAnswer && option == question.answer
                        ) {
                            userAnswer = option
                        }
                    }
                }

            case .trueFalseNotGiven, .yesNoNotGiven:
                let options = question.type == .trueFalseNotGiven ?
                    ["TRUE", "FALSE", "NOT GIVEN"] : ["YES", "NO", "NOT GIVEN"]
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        TFNGOptionView(
                            option: option,
                            isSelected: userAnswer == option,
                            isCorrect: showAnswer && option == question.answer
                        ) {
                            userAnswer = option
                        }
                    }
                }

            case .fillInBlank, .shortAnswer:
                TextField("Your answer", text: $userAnswer)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .serif))

                if showAnswer {
                    Text("Answer: \(question.answer)")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(.green)
                }

            default:
                TextField("Your answer", text: $userAnswer)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .serif))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.8))
        )
        .padding(.horizontal)
    }
}

struct MCQOptionView: View {
    let option: String
    let isSelected: Bool
    let isCorrect: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCorrect ? .green : (isSelected ? BookTheme.coverRed : .gray))

                Text(option)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? BookTheme.coverRed.opacity(0.1) : Color.clear)
            )
        }
    }
}

struct TFNGOptionView: View {
    let option: String
    let isSelected: Bool
    let isCorrect: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(option)
                .font(.system(size: 11, weight: .medium, design: .serif))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isCorrect ? Color.green.opacity(0.2) : (isSelected ? BookTheme.coverRed.opacity(0.2) : Color.gray.opacity(0.1)))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? BookTheme.coverRed : Color.clear, lineWidth: 1)
                )
                .foregroundColor(isSelected ? BookTheme.coverRed : .primary)
        }
    }
}

// MARK: - Listening Section Card
struct ListeningSectionCard: View {
    let section: MockListeningSection
    let sectionNumber: Int
    let bookColor: Color
    @State private var isPlaying = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Section \(sectionNumber)")
                    .font(.system(size: 18, weight: .bold, design: .serif))

                Spacer()

                Button(action: {
                    isPlaying.toggle()
                    // Play audio using TTS
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(bookColor)
                }
            }

            Text(section.context)
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.secondary)

            // Questions
            ForEach(section.questions.indices, id: \.self) { index in
                ListeningQuestionRow(question: section.questions[index], questionNumber: (sectionNumber - 1) * 10 + index + 1)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: BookTheme.pageShadow, radius: 3)
        )
    }
}

struct ListeningQuestionRow: View {
    let question: MockListeningQuestion
    let questionNumber: Int
    @State private var answer = ""

    var body: some View {
        HStack(alignment: .top) {
            Text("\(questionNumber).")
                .font(.system(size: 13, weight: .bold, design: .serif))
                .frame(width: 25)

            VStack(alignment: .leading, spacing: 6) {
                Text(question.text)
                    .font(.system(size: 13, design: .serif))

                TextField("Answer", text: $answer)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
            }
        }
    }
}

// MARK: - Writing Components
struct TaskSelectorButton: View {
    let taskNumber: Int
    let isSelected: Bool
    let bookColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("Task \(taskNumber)")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                Text(taskNumber == 1 ? "20 min • 150 words" : "40 min • 250 words")
                    .font(.system(size: 10, design: .serif))
            }
            .foregroundColor(isSelected ? .white : bookColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? bookColor : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(bookColor, lineWidth: 1)
            )
        }
    }
}

struct WritingTaskCard: View {
    let task: MockWritingTask
    let taskNumber: Int
    @Binding var answer: String
    let bookColor: Color

    var wordCount: Int {
        answer.split(separator: " ").count
    }

    var targetWords: Int {
        taskNumber == 1 ? 150 : 250
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WRITING TASK \(taskNumber)")
                .font(.system(size: 12, weight: .bold, design: .serif))
                .foregroundColor(.secondary)
                .tracking(2)

            Text(task.instruction)
                .font(.system(size: 14, design: .serif))
                .italic()

            Text(task.prompt)
                .font(.system(size: 15, design: .serif))
                .lineSpacing(6)

            Divider()

            // Word count
            HStack {
                Text("Word count: \(wordCount)")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(wordCount >= targetWords ? .green : .orange)

                Spacer()

                Text("Target: \(targetWords)+ words")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(.secondary)
            }

            // Text Editor
            TextEditor(text: $answer)
                .font(.system(size: 14, design: .serif))
                .frame(minHeight: 300)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(BookTheme.pageBackground)
                .shadow(color: BookTheme.pageShadow, radius: 3)
        )
    }
}

// MARK: - Speaking Components
struct PartSelectorButton: View {
    let partNumber: Int
    let isSelected: Bool
    let bookColor: Color
    let action: () -> Void

    var partTitle: String {
        switch partNumber {
        case 1: return "Introduction"
        case 2: return "Cue Card"
        case 3: return "Discussion"
        default: return ""
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("Part \(partNumber)")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                Text(partTitle)
                    .font(.system(size: 10, design: .serif))
            }
            .foregroundColor(isSelected ? .white : bookColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? bookColor : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(bookColor, lineWidth: 1)
            )
        }
    }
}

struct SpeakingPartCard: View {
    let part: MockSpeakingPart
    let partNumber: Int
    let bookColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PART \(partNumber): \(partNumber == 1 ? "INTRODUCTION & INTERVIEW" : "TWO-WAY DISCUSSION")")
                .font(.system(size: 12, weight: .bold, design: .serif))
                .foregroundColor(.secondary)
                .tracking(1)

            Text(part.instruction)
                .font(.system(size: 14, design: .serif))
                .italic()
                .foregroundColor(.secondary)

            Divider()

            ForEach(part.questions.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(bookColor)

                    Text(part.questions[index])
                        .font(.system(size: 15, design: .serif))
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: BookTheme.pageShadow, radius: 3)
        )
    }
}

struct SpeakingPart2Card: View {
    let part: MockSpeakingPart2
    let bookColor: Color
    @State private var prepTimeRemaining = 60
    @State private var speakTimeRemaining = 120
    @State private var phase: Phase = .notStarted

    enum Phase {
        case notStarted, preparing, speaking, finished
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PART 2: INDIVIDUAL LONG TURN")
                .font(.system(size: 12, weight: .bold, design: .serif))
                .foregroundColor(.secondary)
                .tracking(1)

            // Cue Card
            VStack(alignment: .leading, spacing: 12) {
                Text(part.topic)
                    .font(.system(size: 18, weight: .semibold, design: .serif))

                Text("You should say:")
                    .font(.system(size: 14, design: .serif))
                    .italic()

                ForEach(part.bulletPoints, id: \.self) { point in
                    HStack(alignment: .top) {
                        Text("•")
                            .font(.system(size: 14, design: .serif))
                        Text(point)
                            .font(.system(size: 14, design: .serif))
                    }
                }

                Text(part.followUp)
                    .font(.system(size: 14, design: .serif))
                    .italic()
                    .padding(.top, 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(BookTheme.pageBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(bookColor, lineWidth: 2)
                    )
            )

            // Timer and Controls
            HStack {
                VStack(alignment: .leading) {
                    Text(phase == .preparing ? "Preparation Time" : "Speaking Time")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(.secondary)

                    Text(phase == .preparing ? "\(prepTimeRemaining)s" : "\(speakTimeRemaining)s")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(bookColor)
                }

                Spacer()

                Button(action: {
                    switch phase {
                    case .notStarted:
                        phase = .preparing
                    case .preparing:
                        phase = .speaking
                    case .speaking:
                        phase = .finished
                    case .finished:
                        phase = .notStarted
                        prepTimeRemaining = 60
                        speakTimeRemaining = 120
                    }
                }) {
                    Text(buttonText)
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(bookColor)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: BookTheme.pageShadow, radius: 3)
        )
    }

    var buttonText: String {
        switch phase {
        case .notStarted: return "Start Prep"
        case .preparing: return "Start Speaking"
        case .speaking: return "Finish"
        case .finished: return "Restart"
        }
    }
}

// MARK: - Type Aliases for Cambridge Mock Test Types (Prefixed to avoid conflicts)

typealias MockReadingTestContent = IELTSAPIService.CambridgeReadingTestContent
typealias MockReadingPassage = IELTSAPIService.CambridgeReadingPassage
typealias MockReadingQuestion = IELTSAPIService.CambridgeReadingQuestion
typealias MockQuestionType = IELTSAPIService.CambridgeReadingQuestion.CambridgeQuestionType

typealias MockListeningTestContent = IELTSAPIService.CambridgeListeningTestContent
typealias MockListeningSection = IELTSAPIService.CambridgeListeningSection
typealias MockListeningQuestion = IELTSAPIService.CambridgeListeningQuestion

typealias MockWritingTestContent = IELTSAPIService.CambridgeWritingTestContent
typealias MockWritingTask = IELTSAPIService.CambridgeWritingTask

typealias MockSpeakingTestContent = IELTSAPIService.CambridgeSpeakingTestContent
typealias MockSpeakingPart = IELTSAPIService.CambridgeSpeakingPart
typealias MockSpeakingPart2 = IELTSAPIService.CambridgeSpeakingPart2

#Preview {
    MockTestView()
}
