# IELTS Prep iOS App - Complete Project Documentation

## Project Overview

**App Name:** IELTSPrep
**Platform:** iOS 17+
**Language:** Swift 5.9+ / SwiftUI
**Architecture:** MVVM
**AI Provider:** Groq API (Llama 3.1-8b-instant)
**Target Exam Date:** March 7, 2025

---

## Features

### 1. AI-Powered Learning Sections
| Section | Features |
|---------|----------|
| **Reading** | AI-generated passages with MCQ questions, explanations |
| **Writing** | AI topics, sample essays, Bangla tips |
| **Speaking** | Part 1, 2, 3 questions with sample answers |
| **Listening** | AI transcripts with fill-in-blank questions, TTS audio |
| **Grammar** | Lessons with Bangla explanations, exercises |

### 2. Daily Topic System
- Select a topic for the day
- All content (Reading, Writing, Speaking, Vocabulary) generated around that topic
- Available topics: Environment, Technology, Education, Health, Work, Travel, Society, Media, Science, Cities

### 3. Vocabulary Features
- Daily vocabulary based on selected topic
- Word details: definition, Bangla meaning, example, synonyms
- Text-to-Speech pronunciation
- Long-press word lookup in reading passages

### 4. Additional Features
- Settings page for API key configuration
- Grammar checking via LanguageTool API
- Translation support (English to Bangla)

---

## Project Structure

```
IELTSPrep/
├── IELTSPrepApp.swift              # App entry point
├── Assets.xcassets/                # Images and colors
├── Models/
│   ├── Models.swift                # Core data models
│   ├── LessonsData.swift           # Static lesson content
│   └── VocabularyData.swift        # Static vocabulary data
├── Services/
│   ├── IELTSAPIService.swift       # Main AI API service (Groq)
│   └── APIService.swift            # Dictionary/Translation APIs
├── ViewModels/
│   ├── AppViewModel.swift          # Main app state
│   ├── VocabularyViewModel.swift   # Vocabulary management
│   └── WritingViewModel.swift      # Writing practice state
├── Views/
│   ├── ContentView.swift           # Main tab view
│   ├── DashboardView.swift         # Home dashboard
│   ├── LessonsView.swift           # AI-powered lessons (main)
│   ├── SettingsView.swift          # API key settings
│   ├── VocabularyView.swift        # Vocabulary flashcards
│   ├── WritingView.swift           # Writing practice
│   ├── GrammarLessonsView.swift    # Grammar section
│   ├── SpeakingLessonsView.swift   # Speaking section
│   ├── ListeningLessonsView.swift  # Listening section
│   └── WritingLessonsView.swift    # Writing lessons
└── IELTSPrepWidget/                # iOS Widget
    ├── IELTSPrepWidget.swift
    └── Info.plist
```

---

## API Integration

### Groq AI API
- **Endpoint:** `https://api.groq.com/openai/v1/chat/completions`
- **Model:** `llama-3.1-8b-instant`
- **Features:**
  - JSON response format enforced
  - Retry logic (3 attempts with exponential backoff)
  - HTTP/3 disabled for simulator compatibility

### Free APIs Used
| API | Purpose | Endpoint |
|-----|---------|----------|
| **Free Dictionary API** | Word definitions | `dictionaryapi.dev` |
| **MyMemory Translation** | English to Bangla | `mymemory.translated.net` |
| **LanguageTool** | Grammar checking | `api.languagetool.org` |

---

## Key Files Explained

### IELTSAPIService.swift
Main service for AI-powered content generation.

```swift
// Key functions:
func callGroqAI(prompt:systemPrompt:maxTokens:) async -> String?
func generateReadingPassage(topic:) async -> ReadingPassage?
func generateWritingTask(topic:taskType:) async -> WritingTask?
func generateSpeakingSet(topic:) async -> SpeakingSet?
func generateListeningExercise(topic:section:) async -> ListeningExercise?
func generateGrammarLesson(topic:) async -> GrammarLesson?
func generateDailyVocabulary(topic:) async -> [VocabularyItem]
func getEssayFeedback(essay:topic:) async -> EssayFeedback?
func explainWord(word:context:) async -> String?
```

### LessonsView.swift
Main AI-powered learning interface with:
- Daily topic selection
- Navigation to all learning sections
- Daily vocabulary display
- Interactive reading text with long-press word lookup

### Data Models (in IELTSAPIService.swift)
```swift
struct VocabularyItem    // Word with definition, Bangla, example
struct ReadingPassage    // Passage with questions
struct ReadingQuestion   // MCQ question with explanation
struct WritingTask       // Writing topic with sample essay
struct SpeakingSet       // All 3 parts with cue card
struct ListeningExercise // Transcript with questions
struct GrammarLesson     // Lesson with exercises
struct EssayFeedback     // Band score and feedback
```

---

## Setup Instructions

### Prerequisites
- macOS with Xcode 15+
- iOS 17+ device or simulator
- Groq API key (free from console.groq.com)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mijantck/IELTSPrep.git
   cd IELTSPrep
   ```

2. **Open in Xcode:**
   ```bash
   open IELTSPrep.xcodeproj
   ```

3. **Configure API Key:**
   - Open `IELTSPrep/Services/IELTSAPIService.swift`
   - Add your Groq API key:
     ```swift
     @Published var groqAPIKey: String = "your_api_key_here"
     ```

4. **Run on device:**
   - Select your device in Xcode
   - Press ▶️ Run

### Getting Groq API Key (Free)
1. Go to [console.groq.com](https://console.groq.com)
2. Sign up with Google (free)
3. Click "API Keys" in sidebar
4. Click "Create API Key"
5. Copy and paste in the app

---

## Build Commands

### Build for Simulator
```bash
xcodebuild -scheme IELTSPrep \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4' \
  build
```

### Build for Device
```bash
xcodebuild -scheme IELTSPrep \
  -destination 'generic/platform=iOS' \
  -configuration Debug \
  build
```

### Install on Device
```bash
xcrun devicectl device install app \
  --device <DEVICE_ID> \
  /path/to/IELTSPrep.app
```

### Launch on Device
```bash
xcrun devicectl device process launch \
  --device <DEVICE_ID> \
  com.ielts.IELTSPrep
```

---

## Troubleshooting

### Simulator Network Issues
If API calls fail in simulator with "cannot parse response" error:
- This is a known HTTP/3 (QUIC) protocol issue
- Solution: Run on real device instead
- The code already includes `request.assumesHTTP3Capable = false` fix

### App Expires on Device
- Free Apple Developer accounts: App expires after 7 days
- Solution: Re-run from Xcode to reinstall
- Paid Developer account ($99/year): App lasts 1 year

### API Key Issues
- Verify key at [console.groq.com](https://console.groq.com)
- Check Settings tab in app shows "Connected"
- Use "Test AI Connection" button to verify

---

## Technologies Used

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | UI Framework |
| **SwiftData** | Local data persistence |
| **AVFoundation** | Text-to-Speech pronunciation |
| **URLSession** | Network requests |
| **Groq API** | AI content generation |
| **WidgetKit** | iOS Home Screen Widget |

---

## Future Improvements

- [ ] Offline mode with cached content
- [ ] Progress tracking and statistics
- [ ] Mock test timer
- [ ] Audio recording for speaking practice
- [ ] Push notifications for daily practice reminders
- [ ] iCloud sync for progress across devices

---

## License

This project is for personal IELTS preparation use.

---

## Author

**Mijan**
GitHub: [@mijantck](https://github.com/mijantck)

---

*Last Updated: January 2025*
