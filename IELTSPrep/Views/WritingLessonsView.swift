import SwiftUI

struct WritingLessonsView: View {
    let lessons = LessonsContent.writingLessons

    var body: some View {
        List {
            Section {
                ForEach(lessons) { lesson in
                    NavigationLink(destination: WritingLessonDetailView(lesson: lesson)) {
                        WritingLessonRow(lesson: lesson)
                    }
                }
            } header: {
                Text("Writing Lessons")
            } footer: {
                Text("Learn structure, vocabulary, and see sample answers")
            }

            Section("Band 7 Writing Checklist") {
                ChecklistRow(text: "Clear position throughout", isChecked: true)
                ChecklistRow(text: "Well-organized paragraphs", isChecked: true)
                ChecklistRow(text: "Range of vocabulary", isChecked: true)
                ChecklistRow(text: "Complex sentences", isChecked: true)
                ChecklistRow(text: "Minimal grammar errors", isChecked: true)
            }
        }
        .navigationTitle("Writing")
    }
}

struct ChecklistRow: View {
    let text: String
    let isChecked: Bool

    var body: some View {
        HStack {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .foregroundColor(isChecked ? .green : .gray)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct WritingLessonRow: View {
    let lesson: WritingLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(lesson.title)
                    .font(.headline)
                Spacer()
                Text(lesson.type)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
            }

            Text("Structure • Vocabulary • Sample Answer")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct WritingLessonDetailView: View {
    let lesson: WritingLesson
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Section", selection: $selectedTab) {
                    Text("Learn").tag(0)
                    Text("Structure").tag(1)
                    Text("Sample").tag(2)
                    Text("Vocab").tag(3)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content based on selected tab
                switch selectedTab {
                case 0:
                    LearnSection(lesson: lesson)
                case 1:
                    StructureSection(lesson: lesson)
                case 2:
                    SampleSection(lesson: lesson)
                case 3:
                    VocabularySection(lesson: lesson)
                default:
                    EmptyView()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(lesson.type)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LearnSection: View {
    let lesson: WritingLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(lesson.title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            // Explanation
            VStack(alignment: .leading, spacing: 12) {
                Text("📚 What You Need to Know")
                    .font(.headline)

                Text(lesson.explanation)
                    .font(.body)
                    .lineSpacing(4)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)

            // Tips
            VStack(alignment: .leading, spacing: 12) {
                Text("💡 Band 7+ Tips")
                    .font(.headline)

                ForEach(lesson.tips, id: \.self) { tip in
                    HStack(alignment: .top) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(tip)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct StructureSection: View {
    let lesson: WritingLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📝 Essay Structure")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            ForEach(Array(lesson.structure.enumerated()), id: \.offset) { index, part in
                HStack(alignment: .top, spacing: 12) {
                    // Number circle
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 30, height: 30)
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        let parts = part.components(separatedBy: ":")
                        if parts.count > 1 {
                            Text(parts[0])
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(parts[1])
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text(part)
                                .font(.subheadline)
                        }
                    }

                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct SampleSection: View {
    let lesson: WritingLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question
            VStack(alignment: .leading, spacing: 8) {
                Text("📋 Question")
                    .font(.headline)

                Text(lesson.sampleQuestion)
                    .font(.subheadline)
                    .italic()
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)

            // Sample Answer
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("✍️ Sample Answer (Band 7+)")
                        .font(.headline)
                    Spacer()
                    Text("\(lesson.sampleAnswer.split(separator: " ").count) words")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(6)
                }

                Text(lesson.sampleAnswer)
                    .font(.body)
                    .lineSpacing(6)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct VocabularySection: View {
    let lesson: WritingLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📖 Useful Vocabulary")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            ForEach(lesson.vocabularyList, id: \.self) { vocab in
                let parts = vocab.components(separatedBy: " - ")
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(parts.first ?? vocab)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        if parts.count > 1 {
                            Text(parts[1])
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

#Preview {
    NavigationStack {
        WritingLessonsView()
    }
}
