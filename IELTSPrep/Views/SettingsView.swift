import SwiftUI
import WidgetKit

struct SettingsView: View {
    @ObservedObject var apiService = IELTSAPIService.shared
    @State private var showAPIKeyInput = false
    @State private var selectedProviderForKey: AIProvider?
    @State private var isTestingAPI = false
    @State private var apiTestResult: String?

    // Exam settings - temporary values until saved
    @State private var tempExamDate: Date = ExamConfig.examDate
    @State private var tempTargetBand: Double = ExamConfig.targetBand
    @State private var examSettingsSaved = false

    var daysUntilExam: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: tempExamDate)
        return max(0, components.day ?? 0)
    }

    var hasExamChanges: Bool {
        tempExamDate != ExamConfig.examDate || tempTargetBand != ExamConfig.targetBand
    }

    var body: some View {
        NavigationStack {
            List {
                // Current Provider Section
                Section {
                    // Provider Selector
                    ForEach(AIProvider.allCases) { provider in
                        ProviderRow(
                            provider: provider,
                            isSelected: apiService.selectedProvider == provider,
                            isConfigured: apiService.apiKeys[provider] != nil && !apiService.apiKeys[provider]!.isEmpty,
                            onSelect: {
                                apiService.saveProvider(provider)
                            },
                            onAddKey: {
                                selectedProviderForKey = provider
                                showAPIKeyInput = true
                            }
                        )
                    }
                } header: {
                    HStack {
                        Image(systemName: "cpu")
                        Text("AI Provider")
                    }
                } footer: {
                    Text("Select your preferred AI provider. You can add API keys for multiple providers.")
                }

                // Test Connection
                if apiService.isConfigured {
                    Section {
                        Button {
                            Task { await testAIConnection() }
                        } label: {
                            HStack {
                                if isTestingAPI {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .foregroundColor(.blue)
                                }
                                Text("Test \(apiService.selectedProvider.rawValue) Connection")
                                    .foregroundColor(.primary)
                            }
                        }
                        .disabled(isTestingAPI)

                        if let result = apiTestResult {
                            Text(result)
                                .font(.caption)
                                .foregroundColor(result.contains("✅") ? .green : .red)
                        }
                    } header: {
                        Text("Connection Test")
                    }
                }

                // AI Features Section
                Section {
                    FeatureRow(
                        icon: "doc.text.magnifyingglass",
                        title: "Essay Feedback",
                        description: "AI-powered IELTS essay scoring",
                        isEnabled: apiService.isConfigured
                    )

                    FeatureRow(
                        icon: "globe",
                        title: "Grammar Lab",
                        description: "Bengali to English with grammar analysis",
                        isEnabled: apiService.isConfigured
                    )

                    FeatureRow(
                        icon: "newspaper",
                        title: "AI Reading Passages",
                        description: "Generate fresh IELTS-style content",
                        isEnabled: apiService.isConfigured
                    )

                    FeatureRow(
                        icon: "text.bubble",
                        title: "Speaking Practice",
                        description: "AI-generated practice questions",
                        isEnabled: apiService.isConfigured
                    )
                } header: {
                    Text("AI Features")
                } footer: {
                    if !apiService.isConfigured {
                        Text("Add an API key to enable AI features")
                            .foregroundColor(.orange)
                    }
                }

                // API Key Guide Section
                Section {
                    DisclosureGroup("How to Get API Keys") {
                        VStack(alignment: .leading, spacing: 16) {
                            APIGuideRow(
                                provider: .groq,
                                url: "console.groq.com",
                                note: "Free, fast, recommended"
                            )

                            APIGuideRow(
                                provider: .openai,
                                url: "platform.openai.com",
                                note: "Paid, GPT-4 quality"
                            )

                            APIGuideRow(
                                provider: .gemini,
                                url: "aistudio.google.com",
                                note: "Free tier available"
                            )

                            APIGuideRow(
                                provider: .claude,
                                url: "console.anthropic.com",
                                note: "Paid, excellent quality"
                            )

                            APIGuideRow(
                                provider: .mistral,
                                url: "console.mistral.ai",
                                note: "European AI, fast"
                            )
                        }
                        .padding(.vertical, 8)
                    }
                }

                // Exam Settings Section
                Section {
                    DatePicker(
                        "Exam Date",
                        selection: $tempExamDate,
                        in: Date()...,
                        displayedComponents: .date
                    )

                    HStack {
                        Text("Target Band")
                        Spacer()
                        Picker("", selection: $tempTargetBand) {
                            ForEach([5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0], id: \.self) { band in
                                Text(String(format: "%.1f", band)).tag(band)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // Days remaining preview
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.orange)
                        Text("Days Remaining")
                        Spacer()
                        Text("\(daysUntilExam)")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }

                    // Save Button
                    Button {
                        saveExamSettings()
                    } label: {
                        HStack {
                            Spacer()
                            if examSettingsSaved {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Saved!")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save Exam Settings")
                            }
                            Spacer()
                        }
                        .font(.headline)
                        .padding(.vertical, 8)
                    }
                    .disabled(!hasExamChanges && !examSettingsSaved)
                    .listRowBackground(
                        hasExamChanges ? Color.blue.opacity(0.15) : Color.clear
                    )
                } header: {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Exam Settings")
                    }
                } footer: {
                    if hasExamChanges {
                        Text("You have unsaved changes. Tap Save to apply.")
                            .foregroundColor(.orange)
                    } else {
                        Text("Set your IELTS exam date to track your countdown")
                    }
                }

                // About Section
                Section("About") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Active Provider")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: apiService.selectedProvider.icon)
                            Text(apiService.selectedProvider.rawValue)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAPIKeyInput) {
                if let provider = selectedProviderForKey {
                    MultiProviderAPIKeySheet(
                        provider: provider,
                        apiService: apiService,
                        onDismiss: { showAPIKeyInput = false }
                    )
                }
            }
            .onAppear {
                // Load current saved values
                tempExamDate = ExamConfig.examDate
                tempTargetBand = ExamConfig.targetBand
            }
        }
    }

    func saveExamSettings() {
        // Save to ExamConfig (which saves to UserDefaults and shared App Group)
        ExamConfig.examDate = tempExamDate
        ExamConfig.targetBand = tempTargetBand

        // Reload widget timeline to reflect new date
        WidgetCenter.shared.reloadAllTimelines()

        // Show saved feedback
        examSettingsSaved = true

        // Reset the saved indicator after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            examSettingsSaved = false
        }
    }

    func testAIConnection() async {
        isTestingAPI = true
        apiTestResult = nil

        if let response = await apiService.callAI(prompt: "Say 'Hello IELTS!' in one line.", systemPrompt: "Be brief. Just say the greeting.", maxTokens: 50) {
            apiTestResult = "✅ \(apiService.selectedProvider.rawValue) connected! Response: \(response.prefix(30))..."
        } else {
            apiTestResult = "❌ Connection failed. Check your API key."
        }

        isTestingAPI = false
    }
}

// MARK: - Provider Row
struct ProviderRow: View {
    let provider: AIProvider
    let isSelected: Bool
    let isConfigured: Bool
    let onSelect: () -> Void
    let onAddKey: () -> Void

    var body: some View {
        HStack {
            // Selection Button
            Button(action: {
                if isConfigured {
                    onSelect()
                }
            }) {
                HStack(spacing: 12) {
                    // Radio Button
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title3)

                    // Provider Icon
                    Image(systemName: provider.icon)
                        .foregroundColor(isConfigured ? .blue : .gray)
                        .frame(width: 24)

                    // Provider Info
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(provider.rawValue)
                                .font(.subheadline)
                                .fontWeight(isSelected ? .semibold : .regular)
                                .foregroundColor(.primary)

                            if isConfigured {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }

                        Text(provider.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!isConfigured)

            Spacer()

            // Add/Change Key Button
            Button(action: onAddKey) {
                Text(isConfigured ? "Change" : "Add Key")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .opacity(isConfigured ? 1 : 0.7)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isEnabled ? .blue : .gray)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isEnabled ? .green : .gray)
        }
        .opacity(isEnabled ? 1 : 0.6)
    }
}

// MARK: - API Guide Row
struct APIGuideRow: View {
    let provider: AIProvider
    let url: String
    let note: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: provider.icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(provider.rawValue)
                    .font(.subheadline.bold())

                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Link(destination: URL(string: "https://\(url)")!) {
                HStack(spacing: 4) {
                    Text(url)
                        .font(.caption2)
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                }
                .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Multi Provider API Key Sheet
struct MultiProviderAPIKeySheet: View {
    let provider: AIProvider
    @ObservedObject var apiService: IELTSAPIService
    let onDismiss: () -> Void

    @State private var apiKey: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(providerColor.opacity(0.2))
                            .frame(width: 80, height: 80)

                        Image(systemName: provider.icon)
                            .font(.system(size: 35))
                            .foregroundColor(providerColor)
                    }

                    Text(provider.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(provider.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Input Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    SecureField(placeholder, text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal)

                // Info
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                    Text("Stored securely on your device only")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        apiService.saveAPIKey(apiKey, for: provider)
                        apiService.saveProvider(provider)
                        onDismiss()
                        dismiss()
                    } label: {
                        Text("Save & Use \(provider.rawValue)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(apiKey.isEmpty ? Color.gray : providerColor)
                            .cornerRadius(12)
                    }
                    .disabled(apiKey.isEmpty)

                    Link(destination: URL(string: consoleURL)!) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("Get \(provider.rawValue) API Key")
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Add API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Load existing key if any
                apiKey = apiService.apiKeys[provider] ?? ""
            }
        }
    }

    var providerColor: Color {
        switch provider {
        case .groq: return .orange
        case .openai: return .green
        case .gemini: return .blue
        case .claude: return .purple
        case .mistral: return .red
        }
    }

    var placeholder: String {
        switch provider {
        case .groq: return "gsk_xxxxxxxxxxxxxxxx"
        case .openai: return "sk-xxxxxxxxxxxxxxxx"
        case .gemini: return "AIzaSyxxxxxxxxxxxxxxxx"
        case .claude: return "sk-ant-xxxxxxxxxxxxxxxx"
        case .mistral: return "xxxxxxxxxxxxxxxx"
        }
    }

    var consoleURL: String {
        switch provider {
        case .groq: return "https://console.groq.com"
        case .openai: return "https://platform.openai.com/api-keys"
        case .gemini: return "https://aistudio.google.com/apikey"
        case .claude: return "https://console.anthropic.com"
        case .mistral: return "https://console.mistral.ai"
        }
    }
}

#Preview {
    SettingsView()
}
