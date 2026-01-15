import Foundation
import SwiftUI

// MARK: - Video Category Enum (Shared across app)

enum VideoCategory: String, CaseIterable {
    case all = "All"
    case speaking = "Speaking"
    case writing = "Writing"
    case listening = "Listening"
    case reading = "Reading"
    case grammar = "Grammar"
    case vocabulary = "Vocabulary"
    case tips = "Tips & Tricks"

    var icon: String {
        switch self {
        case .all: return "play.rectangle.fill"
        case .speaking: return "mic.fill"
        case .writing: return "pencil"
        case .listening: return "headphones"
        case .reading: return "book.fill"
        case .grammar: return "textformat"
        case .vocabulary: return "character.book.closed.fill"
        case .tips: return "lightbulb.fill"
        }
    }

    var color: Color {
        switch self {
        case .all: return .blue
        case .speaking: return .orange
        case .writing: return .purple
        case .listening: return .green
        case .reading: return .pink
        case .grammar: return .indigo
        case .vocabulary: return .teal
        case .tips: return .yellow
        }
    }
}

// MARK: - YouTube API Service (Using RSS Feeds - No API Key Required)

class YouTubeAPIService: ObservableObject {
    static let shared = YouTubeAPIService()

    @Published var isLoading = false
    @Published var videos: [YouTubeVideoItem] = []
    @Published var shorts: [YouTubeVideoItem] = []
    @Published var error: String?

    // Real IELTS YouTube Channel IDs
    private let ieltsChannels: [(id: String, name: String, category: VideoCategory)] = [
        ("UCVgkr33U5GTBKG0ah3FZhIw", "E2 IELTS", .tips),
        ("UCljTjH6EJdoVPeBaIGntFfA", "IELTS Advantage", .tips),
        ("UCHaHD477h-FeBbVh9Sh7syA", "British Council", .tips),
        ("UCVgkr33U5GTBKG0ah3FZhIw", "BBC Learning English", .grammar),
        ("UCz4tgANd4yy8Oe0iXCdSWfA", "English with Lucy", .vocabulary)
    ]

    // MARK: - Public Methods

    func hasAPIKey() -> Bool {
        return true // RSS doesn't need API key
    }

    func setAPIKey(_ key: String) {
        // Not needed for RSS
    }

    func fetchAllVideos() async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }

        var allVideos: [YouTubeVideoItem] = []

        // Fetch from each channel's RSS feed
        for channel in ieltsChannels {
            let channelVideos = await fetchChannelVideos(channelId: channel.id, channelName: channel.name, defaultCategory: channel.category)
            allVideos.append(contentsOf: channelVideos)
        }

        // Remove duplicates and sort by date
        let uniqueVideos = Array(Set(allVideos)).sorted { $0.publishedAt > $1.publishedAt }

        // Separate shorts from regular videos
        let regularVideos = uniqueVideos.filter { !$0.isShort }
        let shortVideos = uniqueVideos.filter { $0.isShort }

        await MainActor.run {
            self.videos = Array(regularVideos.prefix(30))
            self.shorts = Array(shortVideos.prefix(15))
            self.isLoading = false

            if allVideos.isEmpty {
                self.error = "Could not fetch videos. Check your internet connection."
            }
        }
    }

    // MARK: - RSS Feed Fetching

    private func fetchChannelVideos(channelId: String, channelName: String, defaultCategory: VideoCategory) async -> [YouTubeVideoItem] {
        let rssURL = "https://www.youtube.com/feeds/videos.xml?channel_id=\(channelId)"

        guard let url = URL(string: rssURL) else { return [] }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("RSS fetch failed for \(channelName)")
                return []
            }

            // Parse RSS XML
            let parser = YouTubeRSSParser(channelName: channelName, defaultCategory: defaultCategory)
            return parser.parse(data: data)

        } catch {
            print("Error fetching RSS for \(channelName): \(error)")
            return []
        }
    }
}

// MARK: - RSS Parser

class YouTubeRSSParser: NSObject, XMLParserDelegate {
    private var videos: [YouTubeVideoItem] = []
    private var currentElement = ""
    private var currentVideoId = ""
    private var currentTitle = ""
    private var currentPublished = ""
    private var currentThumbnail = ""
    private var isInEntry = false

    private let channelName: String
    private let defaultCategory: VideoCategory

    init(channelName: String, defaultCategory: VideoCategory) {
        self.channelName = channelName
        self.defaultCategory = defaultCategory
    }

    func parse(data: Data) -> [YouTubeVideoItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return videos
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName

        if elementName == "entry" {
            isInEntry = true
            currentVideoId = ""
            currentTitle = ""
            currentPublished = ""
            currentThumbnail = ""
        }

        if elementName == "yt:videoId" {
            currentVideoId = ""
        }

        if elementName == "media:thumbnail", let url = attributeDict["url"] {
            currentThumbnail = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

        if isInEntry {
            switch currentElement {
            case "yt:videoId":
                currentVideoId += trimmed
            case "title":
                currentTitle += trimmed
            case "published":
                currentPublished += trimmed
            default:
                break
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "entry" && !currentVideoId.isEmpty {
            let category = detectCategory(from: currentTitle)
            let isShort = currentTitle.lowercased().contains("#shorts") ||
                          currentTitle.lowercased().contains("short") ||
                          currentTitle.count < 30

            let thumbnail = currentThumbnail.isEmpty ?
                "https://img.youtube.com/vi/\(currentVideoId)/mqdefault.jpg" : currentThumbnail

            let video = YouTubeVideoItem(
                id: currentVideoId,
                title: cleanTitle(currentTitle),
                channel: channelName,
                duration: isShort ? "< 1 min" : "10-20 min",
                category: category,
                isShort: isShort,
                thumbnailURL: thumbnail,
                publishedAt: currentPublished
            )

            videos.append(video)
            isInEntry = false
        }

        currentElement = ""
    }

    private func cleanTitle(_ title: String) -> String {
        var cleaned = title
        // Remove common prefixes/suffixes
        cleaned = cleaned.replacingOccurrences(of: "#shorts", with: "", options: .caseInsensitive)
        cleaned = cleaned.replacingOccurrences(of: "#short", with: "", options: .caseInsensitive)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned
    }

    private func detectCategory(from title: String) -> VideoCategory {
        let lowercased = title.lowercased()

        if lowercased.contains("speaking") || lowercased.contains("pronunciation") || lowercased.contains("fluency") {
            return .speaking
        } else if lowercased.contains("writing") || lowercased.contains("essay") || lowercased.contains("task 1") || lowercased.contains("task 2") {
            return .writing
        } else if lowercased.contains("listening") {
            return .listening
        } else if lowercased.contains("reading") {
            return .reading
        } else if lowercased.contains("grammar") || lowercased.contains("tense") || lowercased.contains("sentence") {
            return .grammar
        } else if lowercased.contains("vocabulary") || lowercased.contains("word") || lowercased.contains("collocation") {
            return .vocabulary
        } else {
            return defaultCategory
        }
    }
}

// MARK: - YouTube API Response Models

struct YouTubeSearchResponse: Codable {
    let items: [YouTubeSearchItem]
}

struct YouTubeSearchItem: Codable {
    let id: YouTubeVideoId
    let snippet: YouTubeSnippet
}

struct YouTubeVideoId: Codable {
    let videoId: String?
}

struct YouTubeSnippet: Codable {
    let title: String
    let channelTitle: String
    let thumbnails: YouTubeThumbnails
    let publishedAt: String
}

struct YouTubeThumbnails: Codable {
    let `default`: YouTubeThumbnail
    let medium: YouTubeThumbnail?
    let high: YouTubeThumbnail?
}

struct YouTubeThumbnail: Codable {
    let url: String
}

struct YouTubeVideoDetailsResponse: Codable {
    let items: [YouTubeVideoDetail]
}

struct YouTubeVideoDetail: Codable {
    let id: String
    let contentDetails: YouTubeContentDetails
}

struct YouTubeContentDetails: Codable {
    let duration: String
}

// MARK: - Video Item Model

struct YouTubeVideoItem: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let channel: String
    let duration: String
    let category: VideoCategory
    let isShort: Bool
    let thumbnailURL: String
    let publishedAt: String

    var videoURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(id)")
    }

    var shortURL: URL? {
        URL(string: "https://www.youtube.com/shorts/\(id)")
    }

    // Hashable conformance - use id as unique identifier
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Convert to YouTubeVideo for compatibility
    func toYouTubeVideo() -> YouTubeVideo {
        YouTubeVideo(
            id: id,
            title: title,
            channel: channel,
            duration: duration,
            category: category,
            isShort: isShort,
            thumbnailURL: thumbnailURL
        )
    }
}

// MARK: - YouTubeVideo Model (Used by Views)

struct YouTubeVideo: Identifiable {
    let id: String
    let title: String
    let channel: String
    let duration: String
    let category: VideoCategory
    let isShort: Bool
    let thumbnailURL: String
    var searchQuery: String? = nil

    var videoURL: URL? {
        if let query = searchQuery {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return URL(string: "youtube://www.youtube.com/results?search_query=\(encoded)")
        }
        return URL(string: "https://www.youtube.com/watch?v=\(id)")
    }

    var webVideoURL: URL? {
        if let query = searchQuery {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return URL(string: "https://www.youtube.com/results?search_query=\(encoded)")
        }
        return URL(string: "https://www.youtube.com/watch?v=\(id)")
    }

    var shortURL: URL? {
        if let query = searchQuery {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return URL(string: "youtube://www.youtube.com/results?search_query=\(encoded)+%23shorts")
        }
        return URL(string: "https://www.youtube.com/shorts/\(id)")
    }

    var webShortURL: URL? {
        if let query = searchQuery {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return URL(string: "https://www.youtube.com/results?search_query=\(encoded)+%23shorts")
        }
        return URL(string: "https://www.youtube.com/shorts/\(id)")
    }
}
