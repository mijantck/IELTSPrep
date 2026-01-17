import SwiftUI
import SwiftData
import UIKit

// MARK: - Study Session Model

@Model
class StudySession {
    var id: UUID
    var date: Date
    var duration: Int // in seconds
    var type: String // "pomodoro", "free"
    var completed: Bool

    init(duration: Int, type: String = "pomodoro", completed: Bool = true) {
        self.id = UUID()
        self.date = Date()
        self.duration = duration
        self.type = type
        self.completed = completed
    }
}

// MARK: - Focus Mode View

struct FocusModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StudySession.date, order: .reverse) private var sessions: [StudySession]

    @State private var timerMode: TimerMode = .focus
    @State private var timeRemaining: Int = 25 * 60 // 25 minutes
    @State private var isRunning = false
    @State private var showingSettings = false
    @State private var showingStats = false
    @State private var showingAchievements = false

    // Timer settings
    @AppStorage("focusDuration") private var focusDuration: Int = 25
    @AppStorage("breakDuration") private var breakDuration: Int = 5
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 15
    @AppStorage("sessionsBeforeLongBreak") private var sessionsBeforeLongBreak: Int = 4

    // Streak tracking
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @AppStorage("longestStreak") private var longestStreak: Int = 0
    @AppStorage("lastStudyDate") private var lastStudyDateString: String = ""
    @AppStorage("totalStudyMinutes") private var totalStudyMinutes: Int = 0
    @AppStorage("completedPomodoros") private var completedPomodoros: Int = 0

    @State private var sessionsCompleted: Int = 0
    @State private var timer: Timer?
    @State private var showCompletionAlert = false
    @State private var motivationalQuote: String = ""

    enum TimerMode: String {
        case focus = "Focus"
        case shortBreak = "Break"
        case longBreak = "Long Break"

        var color: Color {
            switch self {
            case .focus: return .red
            case .shortBreak: return .green
            case .longBreak: return .blue
            }
        }

        var icon: String {
            switch self {
            case .focus: return "brain.head.profile"
            case .shortBreak: return "cup.and.saucer.fill"
            case .longBreak: return "figure.walk"
            }
        }
    }

    let quotes = [
        "Small steps every day lead to big results.",
        "Focus on progress, not perfection.",
        "You don't have to be great to start, but you have to start to be great.",
        "The secret of getting ahead is getting started.",
        "Discipline is choosing between what you want now and what you want most.",
        "Success is the sum of small efforts repeated day in and day out.",
        "Your future self will thank you.",
        "One page at a time. One word at a time.",
        "The only bad study session is the one that didn't happen.",
        "25 minutes of focus can change your life."
    ]

    var todayStudyTime: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions
            .filter { calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.duration }
    }

    var weekStudyTime: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions
            .filter { $0.date >= weekAgo }
            .reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Streak Banner
                    streakBanner

                    // Timer Card
                    timerCard

                    // Quick Stats
                    quickStats

                    // Micro Tasks
                    microTasksSection

                    // Motivational Quote
                    if !motivationalQuote.isEmpty && !isRunning {
                        quoteCard
                    }

                    // Tips
                    tipsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Focus Mode")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingStats = true }) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingAchievements = true }) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                        }
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                TimerSettingsSheet(
                    focusDuration: $focusDuration,
                    breakDuration: $breakDuration,
                    longBreakDuration: $longBreakDuration,
                    sessionsBeforeLongBreak: $sessionsBeforeLongBreak
                )
            }
            .sheet(isPresented: $showingStats) {
                StudyStatsView(sessions: sessions, totalMinutes: totalStudyMinutes, completedPomodoros: completedPomodoros)
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(
                    currentStreak: currentStreak,
                    longestStreak: longestStreak,
                    totalMinutes: totalStudyMinutes,
                    completedPomodoros: completedPomodoros
                )
            }
            .alert("Session Complete! 🎉", isPresented: $showCompletionAlert) {
                Button("Start Break", action: startBreak)
                Button("Continue Studying", action: startNewFocusSession)
                Button("Done", role: .cancel) { }
            } message: {
                Text("Great job! You completed a \(focusDuration) minute focus session. Take a break or keep going!")
            }
            .onAppear {
                motivationalQuote = quotes.randomElement() ?? ""
                checkAndUpdateStreak()
                timeRemaining = focusDuration * 60
            }
        }
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack(spacing: 16) {
            // Streak
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(currentStreak)")
                        .font(.title.bold())
                }
                Text("Day Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)

            // Today's Sessions
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(sessionsCompleted)")
                        .font(.title.bold())
                }
                Text("Today's Sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    // MARK: - Timer Card

    private var timerCard: some View {
        VStack(spacing: 20) {
            // Mode selector
            HStack(spacing: 0) {
                ForEach([TimerMode.focus, .shortBreak, .longBreak], id: \.self) { mode in
                    Button(action: {
                        if !isRunning {
                            switchMode(to: mode)
                        }
                    }) {
                        Text(mode.rawValue)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(timerMode == mode ? .white : .secondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(timerMode == mode ? mode.color : Color.clear)
                            .cornerRadius(20)
                    }
                    .disabled(isRunning)
                }
            }
            .padding(4)
            .background(Color(.systemGray5))
            .cornerRadius(24)

            // Timer display
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 220, height: 220)

                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(timerMode.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                // Time display
                VStack(spacing: 8) {
                    Image(systemName: timerMode.icon)
                        .font(.title)
                        .foregroundColor(timerMode.color)

                    Text(timeString)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()

                    Text(timerMode.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 10)

            // Control buttons
            HStack(spacing: 20) {
                // Reset button
                Button(action: resetTimer) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }

                // Play/Pause button
                Button(action: toggleTimer) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(timerMode.color)
                        .clipShape(Circle())
                        .shadow(color: timerMode.color.opacity(0.4), radius: 10, y: 5)
                }

                // Skip button
                Button(action: skipSession) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }

            // Phone reminder
            if isRunning && timerMode == .focus {
                HStack {
                    Image(systemName: "iphone.slash")
                        .foregroundColor(.orange)
                    Text("Keep your phone away!")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }

    // MARK: - Quick Stats

    private var quickStats: some View {
        HStack(spacing: 12) {
            FocusStatCard(
                icon: "clock.fill",
                value: "\(todayStudyTime / 60)",
                unit: "min",
                label: "Today",
                color: .blue
            )

            FocusStatCard(
                icon: "calendar",
                value: "\(weekStudyTime / 60)",
                unit: "min",
                label: "This Week",
                color: .purple
            )

            FocusStatCard(
                icon: "flame.fill",
                value: "\(longestStreak)",
                unit: "days",
                label: "Best Streak",
                color: .orange
            )
        }
    }

    // MARK: - Micro Tasks

    private var microTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.green)
                Text("Quick Tasks")
                    .font(.headline)
            }

            VStack(spacing: 8) {
                MicroTaskRow(task: "Review 10 vocabulary words", duration: "5 min")
                MicroTaskRow(task: "Read 1 passage", duration: "10 min")
                MicroTaskRow(task: "Practice 1 speaking topic", duration: "5 min")
                MicroTaskRow(task: "Write 1 paragraph", duration: "10 min")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Quote Card

    private var quoteCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.title2)
                .foregroundColor(.blue.opacity(0.5))

            Text(motivationalQuote)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .italic()

            Button(action: { motivationalQuote = quotes.randomElement() ?? "" }) {
                Text("New Quote")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Tips Section

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Focus Tips")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                FocusTipRow(icon: "iphone.slash", text: "Put your phone in another room")
                FocusTipRow(icon: "drop.fill", text: "Keep water nearby")
                FocusTipRow(icon: "headphones", text: "Use noise-cancelling headphones")
                FocusTipRow(icon: "clock", text: "Start with just 1 pomodoro")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Computed Properties

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var progress: CGFloat {
        let totalTime: Int
        switch timerMode {
        case .focus: totalTime = focusDuration * 60
        case .shortBreak: totalTime = breakDuration * 60
        case .longBreak: totalTime = longBreakDuration * 60
        }
        return CGFloat(totalTime - timeRemaining) / CGFloat(totalTime)
    }

    // MARK: - Timer Functions

    private func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeSession()
            }
        }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        pauseTimer()
        switch timerMode {
        case .focus: timeRemaining = focusDuration * 60
        case .shortBreak: timeRemaining = breakDuration * 60
        case .longBreak: timeRemaining = longBreakDuration * 60
        }
    }

    private func skipSession() {
        pauseTimer()
        if timerMode == .focus {
            startBreak()
        } else {
            startNewFocusSession()
        }
    }

    private func switchMode(to mode: TimerMode) {
        timerMode = mode
        resetTimer()
    }

    private func completeSession() {
        pauseTimer()

        if timerMode == .focus {
            // Save session
            let session = StudySession(duration: focusDuration * 60, type: "pomodoro", completed: true)
            modelContext.insert(session)

            // Update stats
            sessionsCompleted += 1
            completedPomodoros += 1
            totalStudyMinutes += focusDuration

            // Update streak
            updateStreak()

            // Show completion alert
            showCompletionAlert = true

            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // Break completed, start new focus
            startNewFocusSession()
        }
    }

    private func startBreak() {
        if sessionsCompleted % sessionsBeforeLongBreak == 0 && sessionsCompleted > 0 {
            switchMode(to: .longBreak)
        } else {
            switchMode(to: .shortBreak)
        }
        startTimer()
    }

    private func startNewFocusSession() {
        switchMode(to: .focus)
        motivationalQuote = quotes.randomElement() ?? ""
    }

    // MARK: - Streak Functions

    private func checkAndUpdateStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        if lastStudyDateString.isEmpty {
            return
        }

        guard let lastDate = formatter.date(from: lastStudyDateString) else { return }
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0

        if daysDiff > 1 {
            // Streak broken
            currentStreak = 0
        }
    }

    private func updateStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        if lastStudyDateString != today {
            if lastStudyDateString.isEmpty {
                currentStreak = 1
            } else {
                guard let lastDate = formatter.date(from: lastStudyDateString) else {
                    currentStreak = 1
                    lastStudyDateString = today
                    return
                }
                let calendar = Calendar.current
                let daysDiff = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0

                if daysDiff == 1 {
                    currentStreak += 1
                } else if daysDiff > 1 {
                    currentStreak = 1
                }
            }
            lastStudyDateString = today

            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        }
    }
}

// MARK: - Supporting Views

struct FocusStatCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2.bold())
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct MicroTaskRow: View {
    let task: String
    let duration: String
    @State private var isCompleted = false

    var body: some View {
        Button(action: { isCompleted.toggle() }) {
            HStack {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .secondary)

                Text(task)
                    .font(.subheadline)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted)

                Spacer()

                Text(duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            .padding(.vertical, 4)
        }
    }
}

struct FocusTipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Timer Settings Sheet

struct TimerSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var focusDuration: Int
    @Binding var breakDuration: Int
    @Binding var longBreakDuration: Int
    @Binding var sessionsBeforeLongBreak: Int

    var body: some View {
        NavigationStack {
            Form {
                Section("Focus Duration") {
                    Stepper("\(focusDuration) minutes", value: $focusDuration, in: 5...60, step: 5)
                }

                Section("Short Break") {
                    Stepper("\(breakDuration) minutes", value: $breakDuration, in: 1...15)
                }

                Section("Long Break") {
                    Stepper("\(longBreakDuration) minutes", value: $longBreakDuration, in: 10...30, step: 5)
                }

                Section("Sessions before Long Break") {
                    Stepper("\(sessionsBeforeLongBreak) sessions", value: $sessionsBeforeLongBreak, in: 2...6)
                }

                Section {
                    Button("Reset to Defaults") {
                        focusDuration = 25
                        breakDuration = 5
                        longBreakDuration = 15
                        sessionsBeforeLongBreak = 4
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Timer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Study Stats View

struct StudyStatsView: View {
    @Environment(\.dismiss) private var dismiss
    let sessions: [StudySession]
    let totalMinutes: Int
    let completedPomodoros: Int

    var last7Days: [(String, Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        var result: [(String, Int)] = []
        for i in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let dayStr = formatter.string(from: date)
            let dayMinutes = sessions
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.duration } / 60
            result.append((dayStr, dayMinutes))
        }
        return result
    }

    var maxMinutes: Int {
        max(last7Days.map { $0.1 }.max() ?? 1, 1)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Cards
                    HStack(spacing: 12) {
                        SummaryCard(
                            title: "Total Time",
                            value: "\(totalMinutes / 60)h \(totalMinutes % 60)m",
                            icon: "clock.fill",
                            color: .blue
                        )
                        SummaryCard(
                            title: "Sessions",
                            value: "\(completedPomodoros)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)

                    // Weekly Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Last 7 Days")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(last7Days, id: \.0) { day, minutes in
                                VStack(spacing: 4) {
                                    Text("\(minutes)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(minutes > 0 ? Color.blue : Color(.systemGray5))
                                        .frame(height: CGFloat(minutes) / CGFloat(maxMinutes) * 100 + 10)

                                    Text(day)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // Recent Sessions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Sessions")
                            .font(.headline)
                            .padding(.horizontal)

                        if sessions.isEmpty {
                            Text("No sessions yet. Start your first focus session!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(sessions.prefix(10)) { session in
                                SessionRow(session: session)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Study Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct SessionRow: View {
    let session: StudySession

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(session.duration / 60) min \(session.type)")
                    .font(.subheadline)
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Achievements View

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    let currentStreak: Int
    let longestStreak: Int
    let totalMinutes: Int
    let completedPomodoros: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Streak Achievements
                    AchievementSection(title: "Streak Achievements") {
                        AchievementBadge(
                            icon: "flame.fill",
                            title: "First Flame",
                            description: "Complete your first day",
                            isUnlocked: longestStreak >= 1,
                            color: .orange
                        )
                        AchievementBadge(
                            icon: "flame.fill",
                            title: "Week Warrior",
                            description: "7 day streak",
                            isUnlocked: longestStreak >= 7,
                            color: .orange
                        )
                        AchievementBadge(
                            icon: "flame.fill",
                            title: "Monthly Master",
                            description: "30 day streak",
                            isUnlocked: longestStreak >= 30,
                            color: .orange
                        )
                    }

                    // Session Achievements
                    AchievementSection(title: "Session Achievements") {
                        AchievementBadge(
                            icon: "play.circle.fill",
                            title: "First Focus",
                            description: "Complete 1 pomodoro",
                            isUnlocked: completedPomodoros >= 1,
                            color: .green
                        )
                        AchievementBadge(
                            icon: "star.fill",
                            title: "Getting Started",
                            description: "Complete 10 pomodoros",
                            isUnlocked: completedPomodoros >= 10,
                            color: .green
                        )
                        AchievementBadge(
                            icon: "crown.fill",
                            title: "Focus Champion",
                            description: "Complete 100 pomodoros",
                            isUnlocked: completedPomodoros >= 100,
                            color: .yellow
                        )
                    }

                    // Time Achievements
                    AchievementSection(title: "Time Achievements") {
                        AchievementBadge(
                            icon: "clock.fill",
                            title: "First Hour",
                            description: "Study for 1 hour total",
                            isUnlocked: totalMinutes >= 60,
                            color: .blue
                        )
                        AchievementBadge(
                            icon: "clock.fill",
                            title: "10 Hour Club",
                            description: "Study for 10 hours total",
                            isUnlocked: totalMinutes >= 600,
                            color: .blue
                        )
                        AchievementBadge(
                            icon: "trophy.fill",
                            title: "Study Master",
                            description: "Study for 50 hours total",
                            isUnlocked: totalMinutes >= 3000,
                            color: .purple
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct AchievementSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content()
        }
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color : Color(.systemGray4))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? .white : Color(.systemGray2))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .opacity(isUnlocked ? 1 : 0.7)
    }
}

#Preview {
    FocusModeView()
        .modelContainer(for: StudySession.self, inMemory: true)
}
