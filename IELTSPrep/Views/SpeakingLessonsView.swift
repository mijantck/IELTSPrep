import SwiftUI

struct SpeakingLessonsView: View {
    let lessons = LessonsContent.speakingLessons

    var body: some View {
        List {
            // Parts overview
            Section("Speaking Test Overview") {
                SpeakingPartInfo(part: 1, duration: "4-5 min", description: "Personal questions")
                SpeakingPartInfo(part: 2, duration: "3-4 min", description: "Long turn (cue card)")
                SpeakingPartInfo(part: 3, duration: "4-5 min", description: "Discussion")
            }

            // Lessons
            Section("Practice Topics") {
                ForEach(lessons) { lesson in
                    NavigationLink(destination: SpeakingLessonDetailView(lesson: lesson)) {
                        SpeakingLessonRow(lesson: lesson)
                    }
                }
            }

            // Tips
            Section("Speaking Tips") {
                TipRow(icon: "mic.fill", text: "Speak clearly and at natural pace")
                TipRow(icon: "clock", text: "Don't give one-word answers")
                TipRow(icon: "text.bubble", text: "Use a range of vocabulary")
                TipRow(icon: "arrow.triangle.branch", text: "Give examples from your life")
            }
        }
        .navigationTitle("Speaking")
    }
}

struct SpeakingPartInfo: View {
    let part: Int
    let duration: String
    let description: String

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 40, height: 40)
                Text("\(part)")
                    .font(.headline)
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading) {
                Text("Part \(part)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(duration) • \(description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct SpeakingLessonRow: View {
    let lesson: SpeakingLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Part \(lesson.part)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(6)

                Text(lesson.topic)
                    .font(.headline)
            }

            Text("\(lesson.questions.count) questions • Sample answers included")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct SpeakingLessonDetailView: View {
    let lesson: SpeakingLesson
    @State private var currentQuestionIndex = 0
    @State private var showAnswer = false
    @State private var isRecording = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Part \(lesson.part)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .cornerRadius(8)

                    Text(lesson.topic)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .padding()

                // Question Card
                VStack(spacing: 16) {
                    // Question number indicator
                    HStack {
                        ForEach(0..<lesson.questions.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentQuestionIndex ? Color.red : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }

                    // Question
                    Text(lesson.questions[currentQuestionIndex])
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()

                    // Record Button
                    Button {
                        isRecording.toggle()
                    } label: {
                        VStack {
                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(isRecording ? .red : .blue)

                            Text(isRecording ? "Tap to Stop" : "Tap to Practice")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()

                    // Show Answer Button
                    Button {
                        showAnswer.toggle()
                    } label: {
                        HStack {
                            Image(systemName: showAnswer ? "eye.slash" : "eye")
                            Text(showAnswer ? "Hide Sample Answer" : "Show Sample Answer")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }

                    // Sample Answer
                    if showAnswer && currentQuestionIndex < lesson.sampleAnswers.count {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💬 Sample Answer:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)

                            Text(lesson.sampleAnswers[currentQuestionIndex])
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                // Navigation Buttons
                HStack(spacing: 20) {
                    Button {
                        if currentQuestionIndex > 0 {
                            currentQuestionIndex -= 1
                            showAnswer = false
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
                    .disabled(currentQuestionIndex == 0)
                    .opacity(currentQuestionIndex == 0 ? 0.5 : 1)

                    Button {
                        if currentQuestionIndex < lesson.questions.count - 1 {
                            currentQuestionIndex += 1
                            showAnswer = false
                        }
                    } label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(currentQuestionIndex == lesson.questions.count - 1)
                    .opacity(currentQuestionIndex == lesson.questions.count - 1 ? 0.5 : 1)
                }
                .padding(.horizontal)

                // Vocabulary
                VStack(alignment: .leading, spacing: 12) {
                    Text("📖 Useful Vocabulary")
                        .font(.headline)

                    FlowLayout(spacing: 8) {
                        ForEach(lesson.vocabularyList, id: \.self) { vocab in
                            Text(vocab)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                // Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("💡 Tips for Part \(lesson.part)")
                        .font(.headline)

                    ForEach(lesson.tips, id: \.self) { tip in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(tip)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Speaking")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Simple flow layout for vocabulary tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    NavigationStack {
        SpeakingLessonsView()
    }
}
