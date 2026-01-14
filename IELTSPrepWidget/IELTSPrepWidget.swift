import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct IELTSEntry: TimelineEntry {
    let date: Date
    let daysRemaining: Int
    let pendingTasks: Int
    let motivationalQuote: String
}

// MARK: - Timeline Provider
struct IELTSProvider: TimelineProvider {
    func placeholder(in context: Context) -> IELTSEntry {
        IELTSEntry(
            date: Date(),
            daysRemaining: 45,
            pendingTasks: 5,
            motivationalQuote: "You can do it!"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (IELTSEntry) -> Void) {
        let entry = IELTSEntry(
            date: Date(),
            daysRemaining: calculateDaysRemaining(),
            pendingTasks: 5,
            motivationalQuote: getRandomQuote()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<IELTSEntry>) -> Void) {
        let entry = IELTSEntry(
            date: Date(),
            daysRemaining: calculateDaysRemaining(),
            pendingTasks: 5,
            motivationalQuote: getRandomQuote()
        )

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func calculateDaysRemaining() -> Int {
        let examDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 7))!
        let components = Calendar.current.dateComponents([.day], from: Date(), to: examDate)
        return max(0, components.day ?? 0)
    }

    private func getRandomQuote() -> String {
        let quotes = [
            "Band 7 is possible!",
            "Practice daily!",
            "You're getting better!",
            "Focus on grammar!",
            "Keep writing!",
            "Learn 10 words today!"
        ]
        return quotes.randomElement() ?? quotes[0]
    }
}

// MARK: - Widget Views
struct IELTSWidgetEntryView: View {
    var entry: IELTSEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let entry: IELTSEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Text("IELTS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))

                Text("\(entry.daysRemaining)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("DAYS LEFT")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                HStack {
                    Image(systemName: "checklist")
                    Text("\(entry.pendingTasks) tasks")
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var gradientColors: [Color] {
        if entry.daysRemaining > 30 {
            return [.blue, .purple]
        } else if entry.daysRemaining > 14 {
            return [.orange, .red]
        } else {
            return [.red, .pink]
        }
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let entry: IELTSEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 20) {
                // Countdown
                VStack(spacing: 4) {
                    Text("\(entry.daysRemaining)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("DAYS LEFT")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }

                Divider()
                    .background(Color.white.opacity(0.5))
                    .frame(height: 60)

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "target")
                        Text("Target: Band 7")
                    }
                    .font(.caption)
                    .foregroundColor(.white)

                    HStack {
                        Image(systemName: "checklist")
                        Text("\(entry.pendingTasks) tasks pending")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))

                    Text(entry.motivationalQuote)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .italic()
                }
            }
            .padding()
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Widget Configuration
@main
struct IELTSPrepWidget: Widget {
    let kind: String = "IELTSPrepWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IELTSProvider()) { entry in
            IELTSWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("IELTS Countdown")
        .description("Track your IELTS exam countdown and daily tasks.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    IELTSPrepWidget()
} timeline: {
    IELTSEntry(date: Date(), daysRemaining: 45, pendingTasks: 5, motivationalQuote: "You can do it!")
    IELTSEntry(date: Date(), daysRemaining: 10, pendingTasks: 3, motivationalQuote: "Almost there!")
}

#Preview(as: .systemMedium) {
    IELTSPrepWidget()
} timeline: {
    IELTSEntry(date: Date(), daysRemaining: 45, pendingTasks: 5, motivationalQuote: "Practice daily!")
}
