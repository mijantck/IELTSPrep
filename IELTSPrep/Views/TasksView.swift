import SwiftUI
import SwiftData

struct TasksView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(viewModel.todaysTasks, id: \.id) { task in
                        TaskRow(
                            task: task,
                            icon: viewModel.getCategoryIcon(for: task.category),
                            color: viewModel.getCategoryColor(for: task.category)
                        ) {
                            viewModel.toggleTaskCompletion(task: task, modelContext: modelContext)
                        }
                    }
                } header: {
                    HStack {
                        Text("Today's Tasks")
                        Spacer()
                        Text("\(viewModel.completedTasksCount)/\(viewModel.todaysTasks.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    StudyTipCard()
                } header: {
                    Text("Study Tip")
                }
            }
            .navigationTitle("Daily Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.generateDailyTasks(modelContext: modelContext)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    let task: DailyTask
    let icon: String
    let color: Color
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            // Icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)

                Text(task.taskDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Duration
            VStack {
                Text("\(task.duration)")
                    .font(.headline)
                    .foregroundColor(color)
                Text("min")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
    }
}

// MARK: - Study Tip Card
struct StudyTipCard: View {
    let tips = [
        "For Band 7 Writing: Use a variety of complex sentences and topic-specific vocabulary.",
        "Practice paraphrasing - never repeat the question words in your answer.",
        "Learn collocations! They help you sound more natural.",
        "For grammar: Focus on articles, prepositions, and tenses.",
        "Read academic articles daily to improve vocabulary naturally.",
        "Listen to BBC/CNN podcasts for Listening practice.",
        "Practice writing one essay daily and check with grammar tools."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Pro Tip")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text(tips.randomElement() ?? tips[0])
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    TasksView(viewModel: AppViewModel())
        .modelContainer(for: DailyTask.self, inMemory: true)
}
