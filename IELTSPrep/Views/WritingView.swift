import SwiftUI
import SwiftData

struct WritingView: View {
    @StateObject private var viewModel = WritingViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Topic Card
                    TopicCard(topic: viewModel.currentTopic) {
                        viewModel.generateNewTopic()
                    }

                    // Writing Area
                    WritingEditor(
                        text: $viewModel.userEssay,
                        wordCount: viewModel.wordCount
                    )
                    .onChange(of: viewModel.userEssay) { _, _ in
                        viewModel.updateWordCount()
                    }

                    // Check Button
                    Button {
                        Task {
                            await viewModel.checkEssay()
                        }
                    } label: {
                        HStack {
                            if viewModel.isChecking {
                                SwiftUI.ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "checkmark.shield")
                            }
                            Text(viewModel.isChecking ? "Checking..." : "Check My Essay")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isChecking || viewModel.userEssay.isEmpty)

                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Results
                    if viewModel.showResults {
                        ResultsSection(viewModel: viewModel)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Writing Practice")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.saveProgress(modelContext: modelContext)
                    }
                    .disabled(!viewModel.showResults)
                }
            }
        }
    }
}

// MARK: - Topic Card
struct TopicCard: View {
    let topic: String
    let onNewTopic: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Task 2 Topic", systemImage: "doc.text")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: onNewTopic) {
                    Label("New Topic", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
            }

            Text(topic)
                .font(.subheadline)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)

            Text("Write at least 250 words")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Writing Editor
struct WritingEditor: View {
    @Binding var text: String
    let wordCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your Essay")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(wordCount) words")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(wordCountColor)
            }

            TextEditor(text: $text)
                .frame(minHeight: 250)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            // Word count progress
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)

                    Rectangle()
                        .fill(wordCountColor)
                        .frame(width: min(geometry.size.width * (Double(wordCount) / 250.0), geometry.size.width), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
    }

    var wordCountColor: Color {
        if wordCount < 150 { return .red }
        else if wordCount < 250 { return .orange }
        else { return .green }
    }
}

// MARK: - Results Section
struct ResultsSection: View {
    @ObservedObject var viewModel: WritingViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Band Score
            BandScoreCard(band: viewModel.estimatedBand)

            // Grammar Errors
            if !viewModel.grammarErrors.isEmpty {
                GrammarErrorsCard(errors: viewModel.grammarErrors)
            }

            // Feedback
            FeedbackCard(feedback: viewModel.feedback)
        }
    }
}

// MARK: - Band Score Card
struct BandScoreCard: View {
    let band: Double

    var body: some View {
        VStack(spacing: 8) {
            Text("Estimated Band Score")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(String(format: "%.1f", band))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(bandColor)

            Text(bandMessage)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    var bandColor: Color {
        if band < 5.5 { return .red }
        else if band < 6.5 { return .orange }
        else { return .green }
    }

    var bandMessage: String {
        if band < 5.5 { return "Keep practicing! Focus on basics." }
        else if band < 6.5 { return "Good progress! Almost there." }
        else { return "Excellent! You're on track for Band 7!" }
    }
}

// MARK: - Grammar Errors Card
struct GrammarErrorsCard: View {
    let errors: [GrammarMatch]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Grammar Issues (\(errors.count))")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }

            if isExpanded {
                ForEach(errors.prefix(10)) { error in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(error.message)
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        if let replacement = error.replacements.first {
                            Text("Suggestion: \(replacement.value)")
                                .font(.caption)
                                .foregroundColor(.green)
                        }

                        Divider()
                    }
                }

                if errors.count > 10 {
                    Text("+ \(errors.count - 10) more errors")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Feedback Card
struct FeedbackCard: View {
    let feedback: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .foregroundColor(.blue)
                Text("Detailed Feedback")
                    .font(.headline)
            }

            Text(feedback)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    WritingView()
        .modelContainer(for: WritingPractice.self, inMemory: true)
}
