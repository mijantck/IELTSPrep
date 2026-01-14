import SwiftUI

struct SettingsView: View {
    @ObservedObject var apiService = IELTSAPIService.shared
    @AppStorage("groqAPIKey") private var savedAPIKey: String = ""
    @State private var tempAPIKey: String = ""
    @State private var showAPIKeyInput = false
    @State private var isTestingAPI = false
    @State private var apiTestResult: String?

    var body: some View {
        NavigationStack {
            List {
                // AI Configuration Section
                Section {
                    // Groq AI Status
                    HStack {
                        Image(systemName: apiService.isGroqConfigured ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(apiService.isGroqConfigured ? .green : .red)

                        VStack(alignment: .leading) {
                            Text("Groq AI")
                                .font(.headline)
                            Text(apiService.isGroqConfigured ? "Connected" : "Not configured")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if apiService.isGroqConfigured {
                            Button("Change") {
                                showAPIKeyInput = true
                            }
                            .font(.caption)
                        }
                    }

                    if !apiService.isGroqConfigured {
                        Button {
                            showAPIKeyInput = true
                        } label: {
                            HStack {
                                Image(systemName: "key.fill")
                                Text("Add Groq API Key")
                            }
                        }
                    }

                    // Test API Button
                    if apiService.isGroqConfigured {
                        Button {
                            Task { await testGroqAPI() }
                        } label: {
                            HStack {
                                if isTestingAPI {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                }
                                Text("Test AI Connection")
                            }
                        }
                        .disabled(isTestingAPI)

                        if let result = apiTestResult {
                            Text(result)
                                .font(.caption)
                                .foregroundColor(result.contains("✅") ? .green : .red)
                        }
                    }
                } header: {
                    Text("🤖 AI Configuration")
                } footer: {
                    Text("Groq AI provides free essay feedback, content generation, and word explanations. Get your free API key at console.groq.com")
                }

                // API Features Section
                Section("AI Features (Requires Groq)") {
                    FeatureRow(
                        icon: "doc.text.magnifyingglass",
                        title: "Essay Feedback",
                        description: "AI-powered IELTS essay scoring & feedback",
                        isEnabled: apiService.isGroqConfigured
                    )

                    FeatureRow(
                        icon: "text.bubble",
                        title: "Speaking Practice",
                        description: "Generate practice questions for any topic",
                        isEnabled: apiService.isGroqConfigured
                    )

                    FeatureRow(
                        icon: "newspaper",
                        title: "AI Reading Passages",
                        description: "Generate fresh IELTS-style passages",
                        isEnabled: apiService.isGroqConfigured
                    )

                    FeatureRow(
                        icon: "character.book.closed",
                        title: "Smart Word Lookup",
                        description: "Context-aware vocabulary explanations",
                        isEnabled: apiService.isGroqConfigured
                    )
                }

                // Free APIs Section
                Section("Free APIs (Always Available)") {
                    FeatureRow(
                        icon: "book.fill",
                        title: "Dictionary API",
                        description: "Word definitions & pronunciations",
                        isEnabled: true
                    )

                    FeatureRow(
                        icon: "globe.asia.australia.fill",
                        title: "Translation API",
                        description: "English to Bangla translations",
                        isEnabled: true
                    )

                    FeatureRow(
                        icon: "checkmark.circle",
                        title: "Grammar Check",
                        description: "LanguageTool grammar checking",
                        isEnabled: true
                    )
                }

                // How to get API Key
                Section("How to Get Groq API Key") {
                    VStack(alignment: .leading, spacing: 12) {
                        StepRow(number: 1, text: "Go to console.groq.com")
                        StepRow(number: 2, text: "Sign up with Google (FREE)")
                        StepRow(number: 3, text: "Click 'API Keys' in sidebar")
                        StepRow(number: 4, text: "Click 'Create API Key'")
                        StepRow(number: 5, text: "Copy and paste here")
                    }
                    .padding(.vertical, 8)

                    Link(destination: URL(string: "https://console.groq.com")!) {
                        HStack {
                            Image(systemName: "link")
                            Text("Open Groq Console")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
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
                        Text("IELTS Exam Date")
                        Spacer()
                        Text("March 7, 2025")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAPIKeyInput) {
                APIKeyInputSheet(
                    apiKey: $tempAPIKey,
                    onSave: {
                        savedAPIKey = tempAPIKey
                        apiService.groqAPIKey = tempAPIKey
                        showAPIKeyInput = false
                    }
                )
            }
            .onAppear {
                // Load saved API key
                if !savedAPIKey.isEmpty {
                    apiService.groqAPIKey = savedAPIKey
                    tempAPIKey = savedAPIKey
                }
            }
        }
    }

    func testGroqAPI() async {
        isTestingAPI = true
        apiTestResult = nil

        if let response = await apiService.callGroqAI(prompt: "Say 'Hello IELTS!' in one line.", systemPrompt: "Be brief.") {
            apiTestResult = "✅ Connected! Response: \(response.prefix(50))..."
        } else {
            apiTestResult = "❌ Connection failed. Check your API key."
        }

        isTestingAPI = false
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

// MARK: - Step Row
struct StepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 24, height: 24)
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - API Key Input Sheet
struct APIKeyInputSheet: View {
    @Binding var apiKey: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)

                    Text("Enter Groq API Key")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Get your free API key from console.groq.com")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Input Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    SecureField("gsk_xxxxxxxxxxxxxxxx", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal)

                // Info
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                    Text("Your API key is stored securely on your device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        onSave()
                    } label: {
                        Text("Save API Key")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(apiKey.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(apiKey.isEmpty)

                    Link(destination: URL(string: "https://console.groq.com")!) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("Get Free API Key")
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("API Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
