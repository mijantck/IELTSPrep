import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Countdown Card
                    CountdownCard(daysRemaining: viewModel.daysRemaining)

                    // Progress Card
                    TodayProgressCard(
                        completed: viewModel.completedTasksCount,
                        total: viewModel.todaysTasks.count,
                        progress: viewModel.overallProgress
                    )

                    // Motivational Message
                    MotivationCard(message: viewModel.getMotivationalMessage())

                    // Quick Stats
                    QuickStatsGrid()

                    // Target Info
                    TargetCard()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("IELTS Prep")
        }
    }
}

// MARK: - Countdown Card
struct CountdownCard: View {
    let daysRemaining: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("EXAM DATE: 7 MARCH 2025")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))

            Text("\(daysRemaining)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("DAYS LEFT")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))

            // Urgency indicator
            HStack {
                Image(systemName: urgencyIcon)
                Text(urgencyMessage)
                    .font(.caption)
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            LinearGradient(
                colors: [gradientStartColor, gradientEndColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: gradientStartColor.opacity(0.4), radius: 10, x: 0, y: 5)
    }

    var urgencyIcon: String {
        if daysRemaining > 30 { return "clock" }
        else if daysRemaining > 14 { return "exclamationmark.triangle" }
        else { return "flame.fill" }
    }

    var urgencyMessage: String {
        if daysRemaining > 30 { return "Good time to prepare!" }
        else if daysRemaining > 14 { return "Focus on weak areas!" }
        else { return "Intensive practice mode!" }
    }

    var gradientStartColor: Color {
        if daysRemaining > 30 { return .blue }
        else if daysRemaining > 14 { return .orange }
        else { return .red }
    }

    var gradientEndColor: Color {
        if daysRemaining > 30 { return .purple }
        else if daysRemaining > 14 { return .red }
        else { return .pink }
    }
}

// MARK: - Today's Progress Card
struct TodayProgressCard: View {
    let completed: Int
    let total: Int
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                Spacer()
                Text("\(completed)/\(total) tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 20)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 20)

            Text("\(Int(progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Motivation Card
struct MotivationCard: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.title2)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.yellow.opacity(0.15))
        .cornerRadius(12)
    }
}

// MARK: - Quick Stats Grid
struct QuickStatsGrid: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Target Band", value: "7.0", icon: "target", color: .blue)
            StatCard(title: "Current Level", value: "3/10", icon: "chart.line.uptrend.xyaxis", color: .orange)
            StatCard(title: "Words Learned", value: "0", icon: "text.book.closed", color: .purple)
            StatCard(title: "Essays Written", value: "0", icon: "doc.text", color: .green)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Target Card
struct TargetCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Focus Areas")
                .font(.headline)

            VStack(spacing: 8) {
                FocusAreaRow(area: "Grammar", priority: "High", color: .red)
                FocusAreaRow(area: "Vocabulary", priority: "High", color: .red)
                FocusAreaRow(area: "Writing", priority: "Critical", color: .purple)
                FocusAreaRow(area: "Reading", priority: "Medium", color: .orange)
                FocusAreaRow(area: "Listening", priority: "Medium", color: .orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct FocusAreaRow: View {
    let area: String
    let priority: String
    let color: Color

    var body: some View {
        HStack {
            Text(area)
                .font(.subheadline)

            Spacer()

            Text(priority)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(color)
                .cornerRadius(8)
        }
    }
}

#Preview {
    DashboardView(viewModel: AppViewModel())
}
