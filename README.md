# IELTS Prep App 📚

তোমার IELTS Band 7 এর জন্য personalized preparation app!

## Features

### 1. Dashboard
- Days remaining countdown (7 March 2025)
- Today's progress tracking
- Motivational messages
- Focus areas (Grammar, Vocabulary, Writing)

### 2. Daily Tasks
- Grammar Practice (30 min)
- Vocabulary Learning (20 min)
- Writing Task 2 (45 min)
- Reading Practice (30 min)
- Listening Exercise (25 min)

### 3. Writing Practice (AI Powered - FREE!)
- Random IELTS Task 2 topics
- **LanguageTool API** - FREE grammar checking
- Word count tracking
- Estimated band score
- Detailed feedback

### 4. Vocabulary Builder
- 30+ IELTS academic words
- Flashcard system
- Quiz mode
- Spaced repetition

### 5. Home Screen Widget
- Days remaining countdown
- Pending tasks count
- Motivational quotes

---

## Setup Instructions

### Step 1: Create Xcode Project

1. Open **Xcode**
2. File → New → Project
3. Select **iOS → App**
4. Settings:
   - Product Name: `IELTSPrep`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `SwiftData`
5. Click **Create**

### Step 2: Add Files to Project

1. Delete the auto-generated `ContentView.swift`
2. Drag and drop all files from these folders into Xcode:
   - `IELTSPrep/Models/`
   - `IELTSPrep/Services/`
   - `IELTSPrep/ViewModels/`
   - `IELTSPrep/Views/`
3. Replace `IELTSPrepApp.swift` with the one in this folder

### Step 3: Add Widget Extension

1. File → New → Target
2. Select **Widget Extension**
3. Product Name: `IELTSPrepWidget`
4. Uncheck "Include Configuration App Intent"
5. Replace the generated code with `IELTSPrepWidget/IELTSPrepWidget.swift`

### Step 4: Update Exam Date (Optional)

Edit `Models/Models.swift`:
```swift
struct ExamConfig {
    static let examDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 7))!
    // Change the date if your exam is different
}
```

### Step 5: Run!

1. Select your iPhone/Simulator
2. Click Run (⌘R)
3. Add widget to home screen (long press → Edit Home Screen → + → IELTSPrep)

---

## APIs Used (All FREE!)

| API | Purpose | Cost |
|-----|---------|------|
| **LanguageTool** | Grammar checking | FREE |
| **Datamuse** | Vocabulary suggestions | FREE |
| **Local Analysis** | Writing feedback & band estimation | FREE |

---

## Project Structure

```
IELTSPrep/
├── IELTSPrepApp.swift          # App entry point
├── Models/
│   └── Models.swift            # Data models (SwiftData)
├── Services/
│   └── APIService.swift        # API integrations
├── ViewModels/
│   ├── AppViewModel.swift      # Main app logic
│   ├── WritingViewModel.swift  # Writing practice logic
│   └── VocabularyViewModel.swift # Vocabulary logic
├── Views/
│   ├── ContentView.swift       # Tab navigation
│   ├── DashboardView.swift     # Home dashboard
│   ├── TasksView.swift         # Daily tasks list
│   ├── WritingView.swift       # Writing practice
│   └── VocabularyView.swift    # Vocabulary flashcards
└── IELTSPrepWidget/
    └── IELTSPrepWidget.swift   # Home screen widget
```

---

## Daily Study Plan (Recommended)

তোমার level 3/10 থেকে Band 7 পেতে:

| Time | Activity | Focus |
|------|----------|-------|
| 7:00 AM | Vocabulary (20 min) | Learn 10 new words |
| 7:30 AM | Grammar (30 min) | Practice exercises |
| 8:00 AM | Reading (30 min) | One full passage |
| Evening | Writing (45 min) | One Task 2 essay |
| Night | Listening (25 min) | BBC/Podcasts |

**Total: 2.5 hours/day minimum**

---

## Tips for Band 7

### Writing
- Use complex sentences (but don't overdo it)
- Include topic-specific vocabulary
- Follow structure: Intro → Body 1 → Body 2 → Conclusion
- Aim for 280-300 words

### Grammar
- Focus on: Articles, Prepositions, Tenses, Subject-Verb Agreement
- Practice daily with the app's grammar checker

### Vocabulary
- Learn collocations (words that go together)
- Use academic vocabulary naturally
- Don't memorize - understand and use in context

---

## Good Luck! 🎯

তুমি পারবে! Consistent practice is the key.

**Exam Date: 7 March 2025**
**Target: Band 7.0**

---

Made with ❤️ for IELTS preparation
