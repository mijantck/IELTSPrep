import SwiftUI

struct GrammarLessonsView: View {
    let lessons = LessonsContent.grammarLessons

    var body: some View {
        List {
            Section {
                ForEach(lessons) { lesson in
                    NavigationLink(destination: GrammarLessonDetailView(lesson: lesson)) {
                        GrammarLessonRow(lesson: lesson)
                    }
                }
            } header: {
                Text("Grammar Topics")
            } footer: {
                Text("Each topic includes rules, examples, and exercises")
            }

            Section("Quick Grammar Tips") {
                VStack(alignment: .leading, spacing: 8) {
                    GrammarTipRow(tip: "Always check subject-verb agreement", icon: "checkmark.circle")
                    GrammarTipRow(tip: "Use 'the' only for specific things", icon: "checkmark.circle")
                    GrammarTipRow(tip: "Present perfect = past to now", icon: "checkmark.circle")
                    GrammarTipRow(tip: "Don't use 'will' after 'when/if'", icon: "checkmark.circle")
                }
            }
        }
        .navigationTitle("Grammar")
    }
}

struct GrammarTipRow: View {
    let tip: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(tip)
                .font(.subheadline)
        }
    }
}

struct GrammarLessonRow: View {
    let lesson: GrammarLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lesson.title)
                .font(.headline)

            HStack {
                Label("\(lesson.examples.count) examples", systemImage: "doc.text")
                Spacer()
                Label("\(lesson.exercises.count) exercises", systemImage: "pencil")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct GrammarLessonDetailView: View {
    let lesson: GrammarLesson
    @State private var showExercises = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(lesson.title)
                    .font(.title2)
                    .fontWeight(.bold)

                // Explanation
                VStack(alignment: .leading, spacing: 12) {
                    Text("📚 Rule Explanation")
                        .font(.headline)

                    Text(lesson.explanation)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)

                // Examples
                VStack(alignment: .leading, spacing: 12) {
                    Text("✏️ Examples")
                        .font(.headline)

                    ForEach(lesson.examples) { example in
                        GrammarExampleCard(example: example)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)

                // Tips
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Tips")
                        .font(.headline)

                    ForEach(lesson.tips, id: \.self) { tip in
                        HStack(alignment: .top) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(tip)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)

                // Practice Button
                Button {
                    showExercises = true
                } label: {
                    HStack {
                        Image(systemName: "pencil.and.outline")
                        Text("Practice Exercises (\(lesson.exercises.count))")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Grammar")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExercises) {
            GrammarExerciseSheet(exercises: lesson.exercises)
        }
    }
}

struct GrammarExampleCard: View {
    let example: GrammarExample

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text(example.incorrect)
                    .strikethrough()
                    .foregroundColor(.red)
            }
            .font(.subheadline)

            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(example.correct)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
            .font(.subheadline)

            Text("📖 \(example.rule)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct GrammarExerciseSheet: View {
    let exercises: [GrammarExercise]
    @State private var selectedAnswers: [UUID: Int] = [:]
    @State private var showResults = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                        GrammarExerciseCard(
                            index: index + 1,
                            exercise: exercise,
                            selectedAnswer: selectedAnswers[exercise.id],
                            showResults: showResults
                        ) { answer in
                            selectedAnswers[exercise.id] = answer
                        }
                    }

                    // Check Button
                    Button {
                        showResults = true
                    } label: {
                        Text(showResults ? "Score: \(calculateScore())/\(exercises.count)" : "Check Answers")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(showResults ? Color.green : Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    func calculateScore() -> Int {
        exercises.filter { selectedAnswers[$0.id] == $0.correctAnswer }.count
    }
}

struct GrammarExerciseCard: View {
    let index: Int
    let exercise: GrammarExercise
    let selectedAnswer: Int?
    let showResults: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Q\(index). Fill in the blank:")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(exercise.sentence)
                .font(.body)
                .fontWeight(.medium)

            // Options in 2x2 grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Array(exercise.options.enumerated()), id: \.offset) { optionIndex, option in
                    Button {
                        if !showResults {
                            onSelect(optionIndex)
                        }
                    } label: {
                        Text(option)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(optionBackground(optionIndex))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(optionBorder(optionIndex), lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            if showResults {
                Text("💡 \(exercise.explanation)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
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
            } else if index == selectedAnswer {
                return Color.red.opacity(0.2)
            }
        } else if selectedAnswer == index {
            return Color.blue.opacity(0.2)
        }
        return Color.gray.opacity(0.1)
    }

    func optionBorder(_ index: Int) -> Color {
        if showResults {
            if index == exercise.correctAnswer {
                return Color.green
            } else if index == selectedAnswer && index != exercise.correctAnswer {
                return Color.red
            }
        } else if selectedAnswer == index {
            return Color.blue
        }
        return Color.clear
    }
}

#Preview {
    NavigationStack {
        GrammarLessonsView()
    }
}
