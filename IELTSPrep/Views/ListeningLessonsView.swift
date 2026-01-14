import SwiftUI

struct ListeningLessonsView: View {
    let lessons = LessonsContent.listeningLessons

    var body: some View {
        List {
            // Overview
            Section("Listening Test Overview") {
                ListeningSectionInfo(section: 1, description: "Conversation - everyday context")
                ListeningSectionInfo(section: 2, description: "Monologue - everyday context")
                ListeningSectionInfo(section: 3, description: "Conversation - academic")
                ListeningSectionInfo(section: 4, description: "Monologue - academic lecture")
            }

            // Lessons
            Section("Practice Lessons") {
                ForEach(lessons) { lesson in
                    NavigationLink(destination: ListeningLessonDetailView(lesson: lesson)) {
                        ListeningLessonRow(lesson: lesson)
                    }
                }
            }

            // Question Types
            Section("Question Types") {
                QuestionTypeRow(type: "Fill in the Blanks", tip: "Listen for exact words/spellings")
                QuestionTypeRow(type: "Multiple Choice", tip: "Read options before listening")
                QuestionTypeRow(type: "Matching", tip: "Follow the order of information")
                QuestionTypeRow(type: "Map/Diagram", tip: "Note directions: left, right, opposite")
            }

            // Tips
            Section("Listening Tips") {
                HStack(alignment: .top) {
                    Image(systemName: "ear.fill")
                        .foregroundColor(.pink)
                    Text("You hear the audio ONCE only - stay focused!")
                        .font(.subheadline)
                }
                HStack(alignment: .top) {
                    Image(systemName: "pencil")
                        .foregroundColor(.pink)
                    Text("Write answers while listening, not after")
                        .font(.subheadline)
                }
                HStack(alignment: .top) {
                    Image(systemName: "textformat.abc")
                        .foregroundColor(.pink)
                    Text("Check spelling - it matters for your score!")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Listening")
    }
}

struct ListeningSectionInfo: View {
    let section: Int
    let description: String

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 36, height: 36)
                Text("\(section)")
                    .font(.headline)
                    .foregroundColor(.pink)
            }

            VStack(alignment: .leading) {
                Text("Section \(section)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct QuestionTypeRow: View {
    let type: String
    let tip: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(type)
                .font(.subheadline)
                .fontWeight(.medium)
            Text("💡 \(tip)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct ListeningLessonRow: View {
    let lesson: ListeningLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Section \(lesson.section)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pink)
                    .cornerRadius(6)

                Text(lesson.title)
                    .font(.headline)
            }

            Text("\(lesson.questions.count) questions • Full transcript")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ListeningLessonDetailView: View {
    let lesson: ListeningLesson
    @State private var showTranscript = false
    @State private var showAnswers = false
    @State private var userAnswers: [UUID: String] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Section \(lesson.section)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.pink)
                        .cornerRadius(8)

                    Text(lesson.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .padding()

                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("📝 How to Practice")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        InstructionStep(number: 1, text: "Read the questions first (30 seconds)")
                        InstructionStep(number: 2, text: "Read the transcript as if listening")
                        InstructionStep(number: 3, text: "Answer questions while reading")
                        InstructionStep(number: 4, text: "Check your answers")
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                // Questions
                VStack(alignment: .leading, spacing: 12) {
                    Text("❓ Questions")
                        .font(.headline)

                    ForEach(Array(lesson.questions.enumerated()), id: \.element.id) { index, question in
                        ListeningQuestionCard(
                            index: index + 1,
                            question: question,
                            userAnswer: userAnswers[question.id] ?? "",
                            showAnswer: showAnswers,
                            onAnswerChange: { answer in
                                userAnswers[question.id] = answer
                            }
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                // Transcript Toggle
                Button {
                    withAnimation {
                        showTranscript.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: showTranscript ? "doc.text.fill" : "doc.text")
                        Text(showTranscript ? "Hide Transcript" : "Show Transcript (Start Practice)")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Transcript
                if showTranscript {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("📜 Transcript")
                                .font(.headline)
                            Spacer()
                            Text("Read at normal pace")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text(lesson.transcript)
                            .font(.body)
                            .lineSpacing(6)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Check Answers Button
                Button {
                    showAnswers = true
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Check Answers")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .opacity(showTranscript ? 1 : 0.5)
                .disabled(!showTranscript)

                // Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("💡 Tips for Section \(lesson.section)")
                        .font(.headline)

                    ForEach(lesson.tips, id: \.self) { tip in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.pink)
                                .font(.caption)
                            Text(tip)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.pink.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Listening")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 24, height: 24)
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
            }
            Text(text)
                .font(.subheadline)
        }
    }
}

struct ListeningQuestionCard: View {
    let index: Int
    let question: ListeningQuestion
    let userAnswer: String
    let showAnswer: Bool
    let onAnswerChange: (String) -> Void

    @State private var answer: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Q\(index).")
                    .fontWeight(.bold)

                Text("(\(question.questionType))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(question.question)
                .font(.subheadline)

            TextField("Your answer...", text: $answer)
                .textFieldStyle(.roundedBorder)
                .onChange(of: answer) { _, newValue in
                    onAnswerChange(newValue)
                }
                .disabled(showAnswer)

            if showAnswer {
                HStack {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)

                    Text("Correct answer: \(question.answer)")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(answerBackground)
        .cornerRadius(8)
    }

    var isCorrect: Bool {
        answer.lowercased().trimmingCharacters(in: .whitespaces) ==
        question.answer.lowercased().trimmingCharacters(in: .whitespaces)
    }

    var answerBackground: Color {
        if showAnswer {
            return isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1)
        }
        return Color.gray.opacity(0.1)
    }
}

#Preview {
    NavigationStack {
        ListeningLessonsView()
    }
}
