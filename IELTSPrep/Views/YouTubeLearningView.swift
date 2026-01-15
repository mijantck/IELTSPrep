import SwiftUI
import WebKit
import UIKit

// MARK: - Data Models (YouTubeVideo and VideoCategory are defined in YouTubeAPIService.swift)

struct YouTubeChannel: Identifiable {
    let id = UUID()
    let name: String
    let handle: String
    let subscribers: String
    let description: String
    let profileImage: String
}

// MARK: - Main View

struct YouTubeLearningView: View {
    @StateObject private var youtubeAPI = YouTubeAPIService.shared
    @State private var selectedCategory: VideoCategory = .all
    @State private var selectedVideo: YouTubeVideo?
    @State private var searchText = ""
    @State private var showChannels = false
    @State private var showShortsViewer = false
    @State private var selectedShortIndex: Int = 0
    @State private var showAPIKeySheet = false
    @State private var apiKeyInput = ""
    @State private var hasLoadedFromAPI = false

    // Use API data if available, otherwise fallback to static data
    var videos: [YouTubeVideo] {
        if !youtubeAPI.videos.isEmpty {
            return youtubeAPI.videos.map { $0.toYouTubeVideo() }
        }
        return YouTubeVideoData.allVideos
    }

    var shorts: [YouTubeVideo] {
        if !youtubeAPI.shorts.isEmpty {
            return youtubeAPI.shorts.map { $0.toYouTubeVideo() }
        }
        return YouTubeVideoData.shorts
    }

    let channels = YouTubeVideoData.channels

    var filteredVideos: [YouTubeVideo] {
        var result = videos.filter { !$0.isShort }

        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.channel.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // API Status Banner
                    if !youtubeAPI.hasAPIKey() {
                        apiKeyBanner
                    }

                    // Loading indicator
                    if youtubeAPI.isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading videos...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    // Error message
                    if let error = youtubeAPI.error {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }

                    // Search Bar
                    searchBar

                    // Category Pills
                    categorySelector

                    // Shorts Section
                    shortsSection

                    // Featured Channels
                    channelsSection

                    // Video List
                    videoListSection
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("YouTube Learning")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showAPIKeySheet = true }) {
                            Label("Set API Key", systemImage: "key.fill")
                        }
                        Button(action: {
                            Task { await youtubeAPI.fetchAllVideos() }
                        }) {
                            Label("Refresh Videos", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(item: $selectedVideo) { video in
                VideoInfoSheet(video: video)
            }
            .sheet(isPresented: $showAPIKeySheet) {
                YouTubeAPIKeySheet(apiKey: $apiKeyInput, onSave: {
                    youtubeAPI.setAPIKey(apiKeyInput)
                    showAPIKeySheet = false
                    Task { await youtubeAPI.fetchAllVideos() }
                })
            }
            .fullScreenCover(isPresented: $showShortsViewer) {
                ShortsVerticalViewer(shorts: shorts, startIndex: selectedShortIndex)
            }
            .onAppear {
                if !hasLoadedFromAPI && youtubeAPI.hasAPIKey() {
                    hasLoadedFromAPI = true
                    Task { await youtubeAPI.fetchAllVideos() }
                }
            }
        }
    }

    // MARK: - API Key Banner

    private var apiKeyBanner: some View {
        Button(action: { showAPIKeySheet = true }) {
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("YouTube API Key Required")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Text("Tap to add your API key for real videos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    // Function to open short in viewer
    func openShort(at index: Int) {
        selectedShortIndex = index
        showShortsViewer = true
    }

    // Function to open YouTube video (app or web)
    func openYouTubeVideo(_ video: YouTubeVideo) {
        // Try YouTube app first
        if let appURL = video.videoURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = video.webVideoURL {
            // Fallback to web
            UIApplication.shared.open(webURL)
        }
    }

    // Function to open YouTube short (app or web)
    func openYouTubeShort(_ video: YouTubeVideo) {
        if let appURL = video.shortURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = video.webShortURL {
            UIApplication.shared.open(webURL)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search videos...", text: $searchText)
                .textFieldStyle(.plain)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Category Selector

    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(VideoCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Shorts Section

    private var shortsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.red)
                Text("IELTS Shorts")
                    .font(.title3.bold())

                Spacer()

                Button(action: { openShort(at: 0) }) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(shorts.prefix(10).enumerated()), id: \.element.id) { index, short in
                        ShortVideoCard(video: short) {
                            openShort(at: index)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Channels Section

    private var channelsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
                Text("Top IELTS Channels")
                    .font(.title3.bold())

                Spacer()

                Button(action: { showChannels.toggle() }) {
                    Text(showChannels ? "Hide" : "Show All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(showChannels ? channels : Array(channels.prefix(4))) { channel in
                        ChannelCard(channel: channel)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Video List Section

    private var videoListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "play.rectangle.fill")
                    .foregroundColor(.red)
                Text(selectedCategory == .all ? "All Videos" : "\(selectedCategory.rawValue) Videos")
                    .font(.title3.bold())

                Spacer()

                Text("\(filteredVideos.count) videos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            LazyVStack(spacing: 12) {
                ForEach(filteredVideos) { video in
                    VideoCard(video: video) {
                        // Try YouTube app first, then web
                        openYouTubeVideo(video)
                    } onInfoTap: {
                        selectedVideo = video
                    }
                    .padding(.horizontal)
                }
            }

            if filteredVideos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No videos found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let category: VideoCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Short Video Card

struct ShortVideoCard: View {
    let video: YouTubeVideo
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                // Thumbnail
                AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(9/16, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                        }
                }
                .frame(width: 120, height: 200)
                .clipped()

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(video.channel)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Shorts icon
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "bolt.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.red)
                            .cornerRadius(6)
                            .padding(6)
                    }
                    Spacer()
                }
            }
            .frame(width: 120, height: 200)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Channel Card

struct ChannelCard: View {
    let channel: YouTubeChannel

    var body: some View {
        VStack(spacing: 10) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Text(channel.profileImage)
                    .font(.system(size: 30))
            }

            VStack(spacing: 2) {
                Text(channel.name)
                    .font(.caption.bold())
                    .lineLimit(1)

                Text(channel.subscribers)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 100)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .onTapGesture {
            if let url = URL(string: "https://www.youtube.com/\(channel.handle)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - Video Card

struct VideoCard: View {
    let video: YouTubeVideo
    let action: () -> Void
    var onInfoTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail with play button
            Button(action: action) {
                ZStack {
                    AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay {
                                Image(systemName: "play.fill")
                                    .foregroundColor(.gray)
                            }
                    }
                    .frame(width: 140, height: 80)
                    .clipped()
                    .cornerRadius(8)

                    // Play overlay
                    Circle()
                        .fill(Color.red)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }

                    // Duration badge
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(video.duration)
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(4)
                                .padding(4)
                        }
                    }
                }
                .frame(width: 140, height: 80)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(video.channel)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: video.category.icon)
                        .font(.caption2)
                    Text(video.category.rawValue)
                        .font(.caption2)
                }
                .foregroundColor(video.category.color)
            }

            Spacer()

            // Info button
            if onInfoTap != nil {
                Button(action: { onInfoTap?() }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Video Info Sheet (Simple info without embed)

// MARK: - YouTube Embed Player (In-App Playback)

struct YouTubeEmbedPlayer: UIViewRepresentable {
    let videoId: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; }
                html, body { width: 100%; height: 100%; background: #000; }
                iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
            </style>
        </head>
        <body>
            <iframe
                src="https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0&modestbranding=1&showinfo=0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen>
            </iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
}

struct VideoInfoSheet: View {
    let video: YouTubeVideo
    @Environment(\.dismiss) private var dismiss
    @State private var showInAppPlayer = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // In-App YouTube Player
                    if showInAppPlayer {
                        YouTubeEmbedPlayer(videoId: video.id)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    } else {
                        // Thumbnail fallback
                        AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(16/9, contentMode: .fit)
                                .overlay(
                                    ProgressView()
                                )
                        }
                        .cornerRadius(12)
                    }

                    Text(video.title)
                        .font(.title3.bold())

                    HStack {
                        Label(video.channel, systemImage: "person.circle.fill")
                        Spacer()
                        Label(video.duration, systemImage: "clock")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: video.category.icon)
                        Text(video.category.rawValue)
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(video.category.color)
                    .cornerRadius(20)

                    Divider()

                    // Action Buttons
                    HStack(spacing: 12) {
                        // Open in YouTube App
                        Button(action: {
                            if let url = video.videoURL {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                Text("YouTube")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .cornerRadius(10)
                        }

                        // Share Button
                        Button(action: {
                            if let url = URL(string: "https://www.youtube.com/watch?v=\(video.id)") {
                                let activityVC = UIActivityViewController(
                                    activityItems: [video.title, url],
                                    applicationActivities: nil
                                )
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first,
                                   let rootVC = window.rootViewController {
                                    rootVC.present(activityVC, animated: true)
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }

                    Divider()

                    // Learning Tips
                    LearningTipsView(category: video.category)
                }
                .padding()
            }
            .navigationTitle("Watch Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - TikTok-Style Shorts Vertical Viewer

struct ShortsVerticalViewer: View {
    let shorts: [YouTubeVideo]
    let startIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0

    init(shorts: [YouTubeVideo], startIndex: Int = 0) {
        self.shorts = shorts
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                // Vertical ScrollView with snapping
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(shorts.enumerated()), id: \.element.id) { index, short in
                                ShortCardView(video: short, geometry: geometry)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .id(index)
                            }
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    .onAppear {
                        // Scroll to start index
                        if startIndex > 0 {
                            proxy.scrollTo(startIndex, anchor: .top)
                        }
                    }
                }

                // Close button overlay
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 16)
                        .padding(.top, 60)

                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
    }
}

// MARK: - YouTube Shorts Embed Player (Full Screen)

struct YouTubeShortsEmbedPlayer: UIViewRepresentable {
    let videoId: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Use YouTube Shorts embed URL
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; }
                html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
                iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
            </style>
        </head>
        <body>
            <iframe
                src="https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0&modestbranding=1&autoplay=1&loop=1"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen>
            </iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
}

// MARK: - Short Card View (for vertical viewer)

struct ShortCardView: View {
    let video: YouTubeVideo
    let geometry: GeometryProxy
    @State private var isLiked = false
    @State private var isPlaying = false

    var body: some View {
        ZStack {
            // Background - Black
            Color.black

            // YouTube Embed Player (Full Screen)
            if isPlaying {
                YouTubeShortsEmbedPlayer(videoId: video.id)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                // Thumbnail with play button
                AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView().tint(.white))
                }
                .overlay(Color.black.opacity(0.3))

                // Center play button
                Button(action: { isPlaying = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)

                        Image(systemName: "play.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
            }

            // Overlay UI (always visible)
            VStack {
                Spacer()

                // Bottom info
                HStack(alignment: .bottom) {
                    // Left side - Video info
                    VStack(alignment: .leading, spacing: 8) {
                        // Channel
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Text(String(video.channel.prefix(1)))
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                }

                            Text(video.channel)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }

                        // Title
                        Text(video.title)
                            .font(.body)
                            .foregroundColor(.white)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .shadow(radius: 2)

                        // Category tag
                        HStack(spacing: 4) {
                            Image(systemName: video.category.icon)
                            Text(video.category.rawValue)
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(video.category.color.opacity(0.8))
                        .cornerRadius(12)
                    }
                    .frame(maxWidth: geometry.size.width * 0.7, alignment: .leading)

                    Spacer()

                    // Right side - Actions
                    VStack(spacing: 20) {
                        // Like button
                        Button(action: { isLiked.toggle() }) {
                            VStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.title)
                                    .foregroundColor(isLiked ? .red : .white)
                                    .shadow(radius: 2)
                                Text("Like")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                        }

                        // Share button
                        Button(action: {
                            if let url = URL(string: "https://www.youtube.com/shorts/\(video.id)") {
                                let activityVC = UIActivityViewController(
                                    activityItems: [video.title, url],
                                    applicationActivities: nil
                                )
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first,
                                   let rootVC = window.rootViewController {
                                    rootVC.present(activityVC, animated: true)
                                }
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "arrowshape.turn.up.right.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                Text("Share")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                        }

                        // Open in YouTube button
                        Button(action: {
                            if let url = URL(string: "youtube://www.youtube.com/shorts/\(video.id)") {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                } else if let webURL = URL(string: "https://www.youtube.com/shorts/\(video.id)") {
                                    UIApplication.shared.open(webURL)
                                }
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "play.rectangle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                Text("YouTube")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .onAppear {
            // Auto-play when card appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPlaying = true
            }
        }
    }
}

// MARK: - Learning Tips View

struct LearningTipsView: View {
    let category: VideoCategory

    var tips: [String] {
        switch category {
        case .speaking:
            return [
                "Practice speaking along with the video",
                "Record yourself and compare",
                "Note down useful phrases",
                "Pay attention to intonation"
            ]
        case .writing:
            return [
                "Take notes of essay structures",
                "Learn linking words and phrases",
                "Practice writing after watching",
                "Analyze sample answers carefully"
            ]
        case .listening:
            return [
                "Try watching without subtitles first",
                "Listen multiple times",
                "Practice note-taking",
                "Focus on keywords"
            ]
        case .reading:
            return [
                "Learn skimming and scanning techniques",
                "Practice time management",
                "Build vocabulary from passages",
                "Understand question types"
            ]
        case .grammar:
            return [
                "Practice exercises after learning",
                "Note down common mistakes",
                "Use grammar in your writing",
                "Review regularly"
            ]
        case .vocabulary:
            return [
                "Create flashcards for new words",
                "Use words in sentences",
                "Learn collocations together",
                "Review with spaced repetition"
            ]
        case .tips, .all:
            return [
                "Watch videos regularly",
                "Take notes while watching",
                "Practice what you learn",
                "Stay consistent with your schedule"
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Learning Tips")
                    .font(.headline)
            }

            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(tip)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - All Shorts View

struct AllShortsView: View {
    let shorts: [YouTubeVideo]
    let onSelect: (YouTubeVideo) -> Void

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(shorts) { short in
                    ShortVideoCard(video: short) {
                        onSelect(short)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("IELTS Shorts")
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Video Data

struct YouTubeVideoData {

    // Top IELTS YouTube Channels
    static let channels: [YouTubeChannel] = [
        YouTubeChannel(
            name: "E2 IELTS",
            handle: "@E2IELTS",
            subscribers: "2.5M",
            description: "Expert IELTS preparation",
            profileImage: "🎓"
        ),
        YouTubeChannel(
            name: "IELTS Liz",
            handle: "@iaborlengua",
            subscribers: "1.8M",
            description: "Free IELTS lessons",
            profileImage: "👩‍🏫"
        ),
        YouTubeChannel(
            name: "IELTS Advantage",
            handle: "@Aborlengua",
            subscribers: "1.2M",
            description: "Band 7+ strategies",
            profileImage: "📚"
        ),
        YouTubeChannel(
            name: "British Council",
            handle: "@BritishCouncil",
            subscribers: "3.1M",
            description: "Official IELTS partner",
            profileImage: "🇬🇧"
        ),
        YouTubeChannel(
            name: "BBC Learning",
            handle: "@bbclearningenglish",
            subscribers: "5.2M",
            description: "Learn English with BBC",
            profileImage: "📺"
        ),
        YouTubeChannel(
            name: "English with Lucy",
            handle: "@EnglishwithLucy",
            subscribers: "9.1M",
            description: "British English lessons",
            profileImage: "👱‍♀️"
        )
    ]

    // Full length videos - Using search queries for guaranteed real results
    static let allVideos: [YouTubeVideo] = [
        // Speaking Videos
        YouTubeVideo(
            id: "speaking-1",
            title: "IELTS Speaking Part 1 Tips",
            channel: "YouTube Search",
            duration: "15-20 min",
            category: .speaking,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/JeHhIjWelQ0/mqdefault.jpg",
            searchQuery: "IELTS speaking part 1 tips E2"
        ),
        YouTubeVideo(
            id: "speaking-2",
            title: "IELTS Speaking Part 2 - Cue Card",
            channel: "YouTube Search",
            duration: "15-20 min",
            category: .speaking,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/KWqdLoHLd5I/mqdefault.jpg",
            searchQuery: "IELTS speaking part 2 cue card tips"
        ),
        YouTubeVideo(
            id: "speaking-3",
            title: "IELTS Speaking Part 3 Discussion",
            channel: "YouTube Search",
            duration: "15-20 min",
            category: .speaking,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/OEFxVxKm0YQ/mqdefault.jpg",
            searchQuery: "IELTS speaking part 3 tips band 7"
        ),
        YouTubeVideo(
            id: "speaking-4",
            title: "IELTS Speaking Band 9 Sample",
            channel: "YouTube Search",
            duration: "10-15 min",
            category: .speaking,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/rWY5geMx9FY/mqdefault.jpg",
            searchQuery: "IELTS speaking band 9 sample answer"
        ),

        // Writing Videos
        YouTubeVideo(
            id: "writing-1",
            title: "IELTS Writing Task 1 Tips",
            channel: "YouTube Search",
            duration: "20-25 min",
            category: .writing,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/USGEoxmAQdA/mqdefault.jpg",
            searchQuery: "IELTS writing task 1 tips E2 IELTS"
        ),
        YouTubeVideo(
            id: "writing-2",
            title: "IELTS Writing Task 2 Essay",
            channel: "YouTube Search",
            duration: "20-30 min",
            category: .writing,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/8kl5qLvPdtM/mqdefault.jpg",
            searchQuery: "IELTS writing task 2 essay structure"
        ),
        YouTubeVideo(
            id: "writing-3",
            title: "IELTS Writing Task 2 Opinion Essay",
            channel: "YouTube Search",
            duration: "15-20 min",
            category: .writing,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/Sg3dy1VmBVs/mqdefault.jpg",
            searchQuery: "IELTS writing task 2 opinion essay tips"
        ),
        YouTubeVideo(
            id: "writing-4",
            title: "IELTS Writing Task 1 Bar Chart",
            channel: "YouTube Search",
            duration: "15-20 min",
            category: .writing,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/wDRDJQKpqjE/mqdefault.jpg",
            searchQuery: "IELTS writing task 1 bar chart"
        ),

        // Listening Videos
        YouTubeVideo(
            id: "listening-1",
            title: "IELTS Listening Tips Band 8",
            channel: "YouTube Search",
            duration: "15-20 min",
            category: .listening,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/oSBvI8PIWTU/mqdefault.jpg",
            searchQuery: "IELTS listening tips band 8"
        ),
        YouTubeVideo(
            id: "listening-2",
            title: "IELTS Listening Practice Test",
            channel: "YouTube Search",
            duration: "30-40 min",
            category: .listening,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/HniFbMOMMbA/mqdefault.jpg",
            searchQuery: "IELTS listening practice test with answers"
        ),
        YouTubeVideo(
            id: "listening-3",
            title: "IELTS Listening Map Questions",
            channel: "YouTube Search",
            duration: "10-15 min",
            category: .listening,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/L-Qu-Xddx8U/mqdefault.jpg",
            searchQuery: "IELTS listening map labelling tips"
        ),

        // Reading Videos
        YouTubeVideo(
            id: "reading-1",
            title: "IELTS Reading Skimming Scanning",
            channel: "YouTube Search",
            duration: "15-20 min",
            category: .reading,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/nU4Pa-QJWU4/mqdefault.jpg",
            searchQuery: "IELTS reading skimming scanning techniques"
        ),
        YouTubeVideo(
            id: "reading-2",
            title: "IELTS Reading True False Not Given",
            channel: "YouTube Search",
            duration: "12-18 min",
            category: .reading,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/THyTbFvACKI/mqdefault.jpg",
            searchQuery: "IELTS reading true false not given tips"
        ),
        YouTubeVideo(
            id: "reading-3",
            title: "IELTS Reading Time Management",
            channel: "YouTube Search",
            duration: "15-20 min",
            category: .reading,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/8S5AKfDO9-Q/mqdefault.jpg",
            searchQuery: "IELTS reading time management strategy"
        ),

        // Grammar Videos
        YouTubeVideo(
            id: "grammar-1",
            title: "English Grammar for IELTS",
            channel: "YouTube Search",
            duration: "20-30 min",
            category: .grammar,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/Wb2P4gsmMJo/mqdefault.jpg",
            searchQuery: "English grammar for IELTS band 7"
        ),
        YouTubeVideo(
            id: "grammar-2",
            title: "Common English Grammar Mistakes",
            channel: "YouTube Search",
            duration: "15-20 min",
            category: .grammar,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/gHCvQeJF9TM/mqdefault.jpg",
            searchQuery: "common English grammar mistakes IELTS"
        ),
        YouTubeVideo(
            id: "grammar-3",
            title: "Complex Sentences for IELTS",
            channel: "YouTube Search",
            duration: "12-18 min",
            category: .grammar,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/4ObQ_FyINrc/mqdefault.jpg",
            searchQuery: "IELTS complex sentences band 7"
        ),

        // Vocabulary Videos
        YouTubeVideo(
            id: "vocab-1",
            title: "IELTS Vocabulary Essential Words",
            channel: "YouTube Search",
            duration: "25-35 min",
            category: .vocabulary,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/NeXMxuNNlE8/mqdefault.jpg",
            searchQuery: "IELTS vocabulary essential words"
        ),
        YouTubeVideo(
            id: "vocab-2",
            title: "Academic Vocabulary for IELTS",
            channel: "YouTube Search",
            duration: "15-25 min",
            category: .vocabulary,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/o8SdYz5OmcE/mqdefault.jpg",
            searchQuery: "academic vocabulary IELTS writing"
        ),
        YouTubeVideo(
            id: "vocab-3",
            title: "English Collocations for IELTS",
            channel: "YouTube Search",
            duration: "20-25 min",
            category: .vocabulary,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/dZsZzx5TNRU/mqdefault.jpg",
            searchQuery: "English collocations IELTS speaking"
        ),

        // Tips Videos
        YouTubeVideo(
            id: "tips-1",
            title: "Top IELTS Tips and Tricks",
            channel: "YouTube Search",
            duration: "10-15 min",
            category: .tips,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/yTWLN7YqRbA/mqdefault.jpg",
            searchQuery: "IELTS tips and tricks band 8"
        ),
        YouTubeVideo(
            id: "tips-2",
            title: "How to Get Band 8 in IELTS",
            channel: "YouTube Search",
            duration: "20-30 min",
            category: .tips,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/FgF6fIkLFWs/mqdefault.jpg",
            searchQuery: "how to get band 8 IELTS"
        ),
        YouTubeVideo(
            id: "tips-3",
            title: "IELTS Test Day Tips",
            channel: "YouTube Search",
            duration: "10-15 min",
            category: .tips,
            isShort: false,
            thumbnailURL: "https://img.youtube.com/vi/ua7g0XGIlHw/mqdefault.jpg",
            searchQuery: "IELTS exam day tips what to expect"
        )
    ]

    // YouTube Shorts - Using search queries
    static let shorts: [YouTubeVideo] = [
        YouTubeVideo(
            id: "short-1",
            title: "IELTS Speaking Quick Tip",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .speaking,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/UVLBrSPn7E4/mqdefault.jpg",
            searchQuery: "IELTS speaking tips shorts"
        ),
        YouTubeVideo(
            id: "short-2",
            title: "IELTS Writing Hack",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .writing,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/EscoRFmMiik/mqdefault.jpg",
            searchQuery: "IELTS writing tips shorts"
        ),
        YouTubeVideo(
            id: "short-3",
            title: "English Vocabulary Short",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .vocabulary,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/cQhGe8sGVzo/mqdefault.jpg",
            searchQuery: "English vocabulary shorts learn"
        ),
        YouTubeVideo(
            id: "short-4",
            title: "Pronunciation Tip",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .speaking,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/8fqkSdyNfD4/mqdefault.jpg",
            searchQuery: "English pronunciation shorts"
        ),
        YouTubeVideo(
            id: "short-5",
            title: "IELTS Reading Quick Tip",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .reading,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/3sX_sE_mRVY/mqdefault.jpg",
            searchQuery: "IELTS reading tips shorts"
        ),
        YouTubeVideo(
            id: "short-6",
            title: "Listening Tip for Band 8",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .listening,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/2LwHi1nnH14/mqdefault.jpg",
            searchQuery: "IELTS listening tips shorts"
        ),
        YouTubeVideo(
            id: "short-7",
            title: "Grammar in 60 Seconds",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .grammar,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/3l0R_pHLpaQ/mqdefault.jpg",
            searchQuery: "English grammar shorts learn"
        ),
        YouTubeVideo(
            id: "short-8",
            title: "IELTS Band 9 Phrase",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .speaking,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/vLx2V2p_dGk/mqdefault.jpg",
            searchQuery: "IELTS band 9 phrases shorts"
        ),
        YouTubeVideo(
            id: "short-9",
            title: "Writing Introduction Tip",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .writing,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/OjhU_tPhR_4/mqdefault.jpg",
            searchQuery: "IELTS writing introduction shorts"
        ),
        YouTubeVideo(
            id: "short-10",
            title: "English Idiom of the Day",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .vocabulary,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/4sF0zyTNGRw/mqdefault.jpg",
            searchQuery: "English idioms shorts daily"
        ),
        YouTubeVideo(
            id: "short-11",
            title: "Writing Conclusion Trick",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .writing,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/KPx7DnXjxOo/mqdefault.jpg",
            searchQuery: "IELTS writing conclusion shorts"
        ),
        YouTubeVideo(
            id: "short-12",
            title: "Listening Strategy Short",
            channel: "YouTube Search",
            duration: "< 1 min",
            category: .listening,
            isShort: true,
            thumbnailURL: "https://img.youtube.com/vi/Q4FVT13NvlQ/mqdefault.jpg",
            searchQuery: "IELTS listening strategy shorts"
        )
    ]
}

// MARK: - API Key Input Sheet

struct YouTubeAPIKeySheet: View {
    @Binding var apiKey: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Icon
                Image(systemName: "key.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding(.top, 40)

                Text("YouTube API Key")
                    .font(.title2.bold())

                Text("Enter your YouTube Data API v3 key to fetch real IELTS videos from YouTube.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Input field
                TextField("Paste your API key here", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(.horizontal)

                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to get API key:")
                        .font(.headline)

                    instructionStep(number: 1, text: "Go to Google Cloud Console")
                    instructionStep(number: 2, text: "Create a new project")
                    instructionStep(number: 3, text: "Enable YouTube Data API v3")
                    instructionStep(number: 4, text: "Create credentials (API Key)")
                    instructionStep(number: 5, text: "Copy and paste the key here")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Link button
                Link(destination: URL(string: "https://console.cloud.google.com/apis/credentials")!) {
                    HStack {
                        Image(systemName: "link")
                        Text("Open Google Cloud Console")
                    }
                    .font(.subheadline)
                }

                Spacer()

                // Save button
                Button(action: onSave) {
                    Text("Save API Key")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(apiKey.isEmpty ? Color.gray : Color.red)
                        .cornerRadius(12)
                }
                .disabled(apiKey.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func instructionStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.caption.bold())
                .foregroundColor(.red)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - YouTube Learning Card (for Learn tab)

struct YouTubeLearningCard: View {
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.red, .red.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("YouTube Learning Hub")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Text("Curated IELTS videos & Shorts from top channels")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label("Videos", systemImage: "video.fill")
                    Label("Shorts", systemImage: "bolt.fill")
                }
                .font(.caption2)
                .foregroundColor(.red.opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    YouTubeLearningView()
}

#Preview("Card") {
    YouTubeLearningCard()
        .padding()
}
