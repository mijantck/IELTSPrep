import Foundation

// MARK: - Enhanced Vocabulary Word Structure
struct IELTSVocabWord: Identifiable {
    let id = UUID()
    let word: String
    let banglaMeaning: String
    let englishMeaning: String
    let partOfSpeech: PartOfSpeech
    let example: String
    let exampleBangla: String
    let category: VocabCategory
    let icon: String // SF Symbol
    let grammarTip: String?
    let synonyms: [String]
    let collocations: [String]
    let difficulty: VocabDifficulty

    enum PartOfSpeech: String {
        case noun = "Noun (বিশেষ্য)"
        case verb = "Verb (ক্রিয়া)"
        case adjective = "Adjective (বিশেষণ)"
        case adverb = "Adverb (ক্রিয়া-বিশেষণ)"
        case preposition = "Preposition (পদান্বয়ী অব্যয়)"
        case conjunction = "Conjunction (সংযোজক)"
        case phrase = "Phrase (বাক্যাংশ)"
    }

    enum VocabCategory: String, CaseIterable {
        case academic = "Academic (শিক্ষামূলক)"
        case environment = "Environment (পরিবেশ)"
        case technology = "Technology (প্রযুক্তি)"
        case society = "Society (সমাজ)"
        case health = "Health (স্বাস্থ্য)"
        case education = "Education (শিক্ষা)"
        case business = "Business (ব্যবসা)"
        case opinion = "Opinion Words (মতামত)"
        case linking = "Linking Words (সংযোজক)"
        case daily = "Today's Words (আজকের শব্দ)"

        var icon: String {
            switch self {
            case .academic: return "book.fill"
            case .environment: return "leaf.fill"
            case .technology: return "cpu.fill"
            case .society: return "person.3.fill"
            case .health: return "heart.fill"
            case .education: return "graduationcap.fill"
            case .business: return "briefcase.fill"
            case .opinion: return "text.bubble.fill"
            case .linking: return "link"
            case .daily: return "star.fill"
            }
        }

        var color: String {
            switch self {
            case .academic: return "blue"
            case .environment: return "green"
            case .technology: return "purple"
            case .society: return "orange"
            case .health: return "red"
            case .education: return "indigo"
            case .business: return "brown"
            case .opinion: return "pink"
            case .linking: return "teal"
            case .daily: return "yellow"
            }
        }
    }

    enum VocabDifficulty: String {
        case beginner = "Beginner (সহজ)"
        case intermediate = "Intermediate (মধ্যম)"
        case advanced = "Advanced (কঠিন)"
    }
}

// MARK: - Comprehensive IELTS Vocabulary Database (200+ Words)
struct VocabularyDatabase {

    // MARK: - Today's Words (Daily rotating based on date)
    static func getTodaysWords() -> [IELTSVocabWord] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let startIndex = (dayOfYear * 10) % allWords.count
        var todaysWords: [IELTSVocabWord] = []

        for i in 0..<10 {
            let index = (startIndex + i) % allWords.count
            todaysWords.append(allWords[index])
        }
        return todaysWords
    }

    // MARK: - Get words by category
    static func getWords(for category: IELTSVocabWord.VocabCategory) -> [IELTSVocabWord] {
        return allWords.filter { $0.category == category }
    }

    // MARK: - All Words Database (200+ IELTS Essential Words)
    static let allWords: [IELTSVocabWord] = [

        // ==========================================
        // MARK: - LINKING WORDS (50 words) - Most Important for Writing!
        // ==========================================

        // Addition
        IELTSVocabWord(word: "furthermore", banglaMeaning: "তাছাড়া", englishMeaning: "in addition; besides", partOfSpeech: .adverb, example: "The product is affordable. Furthermore, it is eco-friendly.", exampleBangla: "পণ্যটি সাশ্রয়ী। তাছাড়া, এটি পরিবেশবান্ধব।", category: .linking, icon: "plus.circle.fill", grammarTip: "Use at start of sentence with comma", synonyms: ["moreover", "additionally", "besides"], collocations: ["furthermore, it is", "furthermore, studies show"], difficulty: .intermediate),

        IELTSVocabWord(word: "moreover", banglaMeaning: "তদুপরি", englishMeaning: "in addition to what has been said", partOfSpeech: .adverb, example: "He is intelligent. Moreover, he works hard.", exampleBangla: "সে বুদ্ধিমান। তদুপরি, সে পরিশ্রমী।", category: .linking, icon: "plus.rectangle.fill", grammarTip: "Formal word, use in essays", synonyms: ["furthermore", "additionally", "in addition"], collocations: ["moreover, research", "moreover, it"], difficulty: .intermediate),

        IELTSVocabWord(word: "in addition", banglaMeaning: "এছাড়াও", englishMeaning: "also; as well as", partOfSpeech: .phrase, example: "In addition to English, she speaks French.", exampleBangla: "ইংরেজি ছাড়াও, সে ফরাসি বলে।", category: .linking, icon: "plus.square.fill", grammarTip: "'In addition to' needs a noun after it", synonyms: ["besides", "also", "as well"], collocations: ["in addition to this", "in addition, the"], difficulty: .beginner),

        IELTSVocabWord(word: "additionally", banglaMeaning: "অতিরিক্তভাবে", englishMeaning: "as an extra factor or circumstance", partOfSpeech: .adverb, example: "The hotel is cheap. Additionally, it's near the beach.", exampleBangla: "হোটেলটি সস্তা। অতিরিক্তভাবে, এটি সমুদ্র সৈকতের কাছে।", category: .linking, icon: "plus.app.fill", grammarTip: "Can start or be in middle of sentence", synonyms: ["furthermore", "moreover", "also"], collocations: ["additionally, there are"], difficulty: .intermediate),

        IELTSVocabWord(word: "as well as", banglaMeaning: "পাশাপাশি", englishMeaning: "in addition to", partOfSpeech: .phrase, example: "She plays piano as well as guitar.", exampleBangla: "সে গিটারের পাশাপাশি পিয়ানো বাজায়।", category: .linking, icon: "plus.diamond.fill", grammarTip: "Verb agrees with first subject", synonyms: ["in addition to", "besides", "along with"], collocations: ["as well as being", "as well as this"], difficulty: .beginner),

        // Contrast
        IELTSVocabWord(word: "however", banglaMeaning: "তবে / যাইহোক", englishMeaning: "but; nevertheless", partOfSpeech: .adverb, example: "It was raining. However, we went out.", exampleBangla: "বৃষ্টি হচ্ছিল। তবে, আমরা বাইরে গেলাম।", category: .linking, icon: "arrow.uturn.right", grammarTip: "Use with comma: 'However, ...'", synonyms: ["nevertheless", "nonetheless", "yet"], collocations: ["however, it is", "however, some argue"], difficulty: .beginner),

        IELTSVocabWord(word: "nevertheless", banglaMeaning: "তা সত্ত্বেও", englishMeaning: "in spite of that", partOfSpeech: .adverb, example: "He was tired. Nevertheless, he continued working.", exampleBangla: "সে ক্লান্ত ছিল। তা সত্ত্বেও, সে কাজ চালিয়ে গেল।", category: .linking, icon: "arrow.uturn.right.circle.fill", grammarTip: "Stronger than 'however'", synonyms: ["however", "nonetheless", "even so"], collocations: ["nevertheless, the", "nevertheless, it"], difficulty: .advanced),

        IELTSVocabWord(word: "on the other hand", banglaMeaning: "অন্যদিকে", englishMeaning: "from a different point of view", partOfSpeech: .phrase, example: "Cities offer jobs. On the other hand, they are polluted.", exampleBangla: "শহর চাকরি দেয়। অন্যদিকে, সেগুলো দূষিত।", category: .linking, icon: "hand.raised.fill", grammarTip: "Use to show different perspective", synonyms: ["conversely", "in contrast", "alternatively"], collocations: ["on the other hand, some"], difficulty: .beginner),

        IELTSVocabWord(word: "whereas", banglaMeaning: "যেখানে / অপরদিকে", englishMeaning: "in contrast with the fact that", partOfSpeech: .conjunction, example: "Some like coffee, whereas others prefer tea.", exampleBangla: "কেউ কফি পছন্দ করে, অপরদিকে অন্যরা চা পছন্দ করে।", category: .linking, icon: "arrow.left.arrow.right", grammarTip: "Use in middle of sentence", synonyms: ["while", "although", "but"], collocations: ["whereas others", "whereas in"], difficulty: .intermediate),

        IELTSVocabWord(word: "in contrast", banglaMeaning: "বিপরীতে", englishMeaning: "showing difference when compared", partOfSpeech: .phrase, example: "Japan is safe. In contrast, some countries have high crime.", exampleBangla: "জাপান নিরাপদ। বিপরীতে, কিছু দেশে অপরাধ বেশি।", category: .linking, icon: "arrow.left.and.right.square.fill", grammarTip: "Use to compare two different things", synonyms: ["conversely", "on the contrary"], collocations: ["in contrast to", "in contrast with"], difficulty: .intermediate),

        IELTSVocabWord(word: "although", banglaMeaning: "যদিও", englishMeaning: "despite the fact that", partOfSpeech: .conjunction, example: "Although he studied hard, he failed.", exampleBangla: "যদিও সে পড়াশোনা করেছে, সে ফেল করেছে।", category: .linking, icon: "arrow.triangle.branch", grammarTip: "Don't use 'but' in same sentence", synonyms: ["though", "even though", "despite"], collocations: ["although it is", "although some"], difficulty: .beginner),

        IELTSVocabWord(word: "despite", banglaMeaning: "সত্ত্বেও", englishMeaning: "without being affected by", partOfSpeech: .preposition, example: "Despite the rain, we enjoyed the trip.", exampleBangla: "বৃষ্টি সত্ত্বেও, আমরা ভ্রমণ উপভোগ করেছি।", category: .linking, icon: "xmark.circle", grammarTip: "Follow with noun/gerund, not clause", synonyms: ["in spite of", "regardless of", "notwithstanding"], collocations: ["despite the fact", "despite being"], difficulty: .intermediate),

        IELTSVocabWord(word: "while", banglaMeaning: "যখন / অথচ", englishMeaning: "at the same time as; although", partOfSpeech: .conjunction, example: "While cities grow, villages shrink.", exampleBangla: "যখন শহর বাড়ে, গ্রাম কমে।", category: .linking, icon: "clock.arrow.2.circlepath", grammarTip: "Can show time OR contrast", synonyms: ["whereas", "although", "whilst"], collocations: ["while it is true", "while some"], difficulty: .beginner),

        // Cause & Effect
        IELTSVocabWord(word: "consequently", banglaMeaning: "ফলস্বরূপ", englishMeaning: "as a result", partOfSpeech: .adverb, example: "He didn't study. Consequently, he failed.", exampleBangla: "সে পড়েনি। ফলস্বরূপ, সে ফেল করেছে।", category: .linking, icon: "arrow.right.circle.fill", grammarTip: "Shows result of previous statement", synonyms: ["therefore", "thus", "hence"], collocations: ["consequently, the", "consequently, there"], difficulty: .intermediate),

        IELTSVocabWord(word: "therefore", banglaMeaning: "তাই / সুতরাং", englishMeaning: "for that reason", partOfSpeech: .adverb, example: "It's expensive. Therefore, few people buy it.", exampleBangla: "এটা দামি। তাই, কম লোক কেনে।", category: .linking, icon: "arrow.right.square.fill", grammarTip: "Very common in academic writing", synonyms: ["consequently", "hence", "thus"], collocations: ["therefore, it is", "therefore, the"], difficulty: .beginner),

        IELTSVocabWord(word: "as a result", banglaMeaning: "ফলে", englishMeaning: "because of this", partOfSpeech: .phrase, example: "Prices rose. As a result, sales dropped.", exampleBangla: "দাম বেড়েছে। ফলে, বিক্রি কমেছে।", category: .linking, icon: "arrow.turn.down.right", grammarTip: "Can start sentence or use 'as a result of'", synonyms: ["consequently", "therefore", "hence"], collocations: ["as a result of", "as a result, the"], difficulty: .beginner),

        IELTSVocabWord(word: "thus", banglaMeaning: "এভাবে / তাই", englishMeaning: "as a result of this; therefore", partOfSpeech: .adverb, example: "He worked hard, thus achieving success.", exampleBangla: "সে কঠোর পরিশ্রম করেছে, এভাবে সাফল্য অর্জন করেছে।", category: .linking, icon: "arrow.right.to.line", grammarTip: "Formal, often with -ing form", synonyms: ["therefore", "hence", "consequently"], collocations: ["thus, it is", "thus making"], difficulty: .advanced),

        IELTSVocabWord(word: "due to", banglaMeaning: "কারণে", englishMeaning: "because of", partOfSpeech: .phrase, example: "The flight was delayed due to bad weather.", exampleBangla: "খারাপ আবহাওয়ার কারণে ফ্লাইট দেরি হয়েছে।", category: .linking, icon: "exclamationmark.triangle", grammarTip: "Follow with noun, not clause", synonyms: ["because of", "owing to", "as a result of"], collocations: ["due to the fact", "due to this"], difficulty: .beginner),

        IELTSVocabWord(word: "because of", banglaMeaning: "এর কারণে", englishMeaning: "by reason of", partOfSpeech: .phrase, example: "The match was cancelled because of rain.", exampleBangla: "বৃষ্টির কারণে ম্যাচ বাতিল হয়েছে।", category: .linking, icon: "cloud.rain.fill", grammarTip: "Follow with noun/gerund", synonyms: ["due to", "owing to", "on account of"], collocations: ["because of this", "because of the"], difficulty: .beginner),

        IELTSVocabWord(word: "leads to", banglaMeaning: "পরিচালিত করে", englishMeaning: "results in; causes", partOfSpeech: .phrase, example: "Pollution leads to health problems.", exampleBangla: "দূষণ স্বাস্থ্য সমস্যার দিকে পরিচালিত করে।", category: .linking, icon: "arrow.right", grammarTip: "Subject + leads to + result", synonyms: ["results in", "causes", "brings about"], collocations: ["this leads to", "which leads to"], difficulty: .beginner),

        // Giving Examples
        IELTSVocabWord(word: "for example", banglaMeaning: "উদাহরণস্বরূপ", englishMeaning: "as an illustration", partOfSpeech: .phrase, example: "Many fruits are healthy. For example, apples and oranges.", exampleBangla: "অনেক ফল স্বাস্থ্যকর। উদাহরণস্বরূপ, আপেল এবং কমলা।", category: .linking, icon: "text.badge.star", grammarTip: "Use comma after it", synonyms: ["for instance", "such as", "like"], collocations: ["for example, in", "for example, the"], difficulty: .beginner),

        IELTSVocabWord(word: "for instance", banglaMeaning: "যেমন", englishMeaning: "as an example", partOfSpeech: .phrase, example: "Some countries, for instance Japan, have low crime.", exampleBangla: "কিছু দেশ, যেমন জাপান, কম অপরাধ আছে।", category: .linking, icon: "star.fill", grammarTip: "Can be in middle of sentence", synonyms: ["for example", "such as", "e.g."], collocations: ["for instance, in", "for instance, some"], difficulty: .beginner),

        IELTSVocabWord(word: "such as", banglaMeaning: "যেমন", englishMeaning: "for example", partOfSpeech: .phrase, example: "Vegetables such as carrots are healthy.", exampleBangla: "সবজি যেমন গাজর স্বাস্থ্যকর।", category: .linking, icon: "list.bullet", grammarTip: "No comma before 'such as'", synonyms: ["like", "including", "for example"], collocations: ["such as the", "countries such as"], difficulty: .beginner),

        IELTSVocabWord(word: "namely", banglaMeaning: "অর্থাৎ", englishMeaning: "that is to say; specifically", partOfSpeech: .adverb, example: "Two countries, namely India and China, have huge populations.", exampleBangla: "দুটি দেশ, অর্থাৎ ভারত এবং চীন, বিশাল জনসংখ্যা আছে।", category: .linking, icon: "text.badge.checkmark", grammarTip: "Use to specify exactly what you mean", synonyms: ["specifically", "that is", "i.e."], collocations: ["namely, the", "namely that"], difficulty: .intermediate),

        // Conclusion
        IELTSVocabWord(word: "in conclusion", banglaMeaning: "উপসংহারে", englishMeaning: "to sum up finally", partOfSpeech: .phrase, example: "In conclusion, education is vital for development.", exampleBangla: "উপসংহারে, শিক্ষা উন্নয়নের জন্য অপরিহার্য।", category: .linking, icon: "text.alignleft", grammarTip: "Use only at the END of essay", synonyms: ["to conclude", "in summary", "to sum up"], collocations: ["in conclusion, it is", "in conclusion, the"], difficulty: .beginner),

        IELTSVocabWord(word: "to sum up", banglaMeaning: "সংক্ষেপে", englishMeaning: "to summarize", partOfSpeech: .phrase, example: "To sum up, technology has both benefits and drawbacks.", exampleBangla: "সংক্ষেপে, প্রযুক্তির সুবিধা ও অসুবিধা দুটোই আছে।", category: .linking, icon: "sum", grammarTip: "Use in conclusion paragraph", synonyms: ["in summary", "in conclusion", "overall"], collocations: ["to sum up, the", "to sum up, it"], difficulty: .beginner),

        IELTSVocabWord(word: "overall", banglaMeaning: "সামগ্রিকভাবে", englishMeaning: "taking everything into account", partOfSpeech: .adverb, example: "Overall, the project was successful.", exampleBangla: "সামগ্রিকভাবে, প্রকল্পটি সফল হয়েছে।", category: .linking, icon: "chart.bar.fill", grammarTip: "Good for Task 1 overview", synonyms: ["in general", "on the whole", "all in all"], collocations: ["overall, there was", "overall, the trend"], difficulty: .beginner),

        // ==========================================
        // MARK: - ACADEMIC WORDS (40 words)
        // ==========================================

        IELTSVocabWord(word: "significant", banglaMeaning: "উল্লেখযোগ্য", englishMeaning: "important; notable", partOfSpeech: .adjective, example: "There was a significant increase in sales.", exampleBangla: "বিক্রয়ে উল্লেখযোগ্য বৃদ্ধি হয়েছে।", category: .academic, icon: "chart.line.uptrend.xyaxis", grammarTip: "Adverb: 'significantly'", synonyms: ["considerable", "substantial", "notable"], collocations: ["significant increase", "significant impact", "significant change"], difficulty: .intermediate),

        IELTSVocabWord(word: "significantly", banglaMeaning: "উল্লেখযোগ্যভাবে", englishMeaning: "to an important degree", partOfSpeech: .adverb, example: "Prices increased significantly.", exampleBangla: "দাম উল্লেখযোগ্যভাবে বেড়েছে।", category: .academic, icon: "arrow.up.right", grammarTip: "Use with verbs: increased significantly", synonyms: ["considerably", "substantially", "notably"], collocations: ["increased significantly", "significantly higher"], difficulty: .intermediate),

        IELTSVocabWord(word: "substantial", banglaMeaning: "যথেষ্ট / বিশাল", englishMeaning: "of considerable size or importance", partOfSpeech: .adjective, example: "There has been a substantial improvement.", exampleBangla: "যথেষ্ট উন্নতি হয়েছে।", category: .academic, icon: "rectangle.stack.fill", grammarTip: "Adverb: 'substantially'", synonyms: ["considerable", "significant", "sizeable"], collocations: ["substantial amount", "substantial increase"], difficulty: .intermediate),

        IELTSVocabWord(word: "evident", banglaMeaning: "স্পষ্ট", englishMeaning: "clearly seen or understood", partOfSpeech: .adjective, example: "It is evident that changes are needed.", exampleBangla: "এটা স্পষ্ট যে পরিবর্তন প্রয়োজন।", category: .academic, icon: "eye.fill", grammarTip: "Use: 'It is evident that...'", synonyms: ["obvious", "apparent", "clear"], collocations: ["it is evident", "clearly evident"], difficulty: .intermediate),

        IELTSVocabWord(word: "apparent", banglaMeaning: "আপাত / স্পষ্ট", englishMeaning: "clearly visible or understood", partOfSpeech: .adjective, example: "The benefits are apparent.", exampleBangla: "সুবিধাগুলো স্পষ্ট।", category: .academic, icon: "eye.circle.fill", grammarTip: "Adverb: 'apparently'", synonyms: ["obvious", "evident", "clear"], collocations: ["readily apparent", "immediately apparent"], difficulty: .intermediate),

        IELTSVocabWord(word: "crucial", banglaMeaning: "গুরুত্বপূর্ণ", englishMeaning: "of great importance", partOfSpeech: .adjective, example: "Education is crucial for development.", exampleBangla: "শিক্ষা উন্নয়নের জন্য গুরুত্বপূর্ণ।", category: .academic, icon: "star.circle.fill", grammarTip: "Stronger than 'important'", synonyms: ["essential", "vital", "critical"], collocations: ["crucial role", "crucial factor"], difficulty: .intermediate),

        IELTSVocabWord(word: "essential", banglaMeaning: "অপরিহার্য", englishMeaning: "absolutely necessary", partOfSpeech: .adjective, example: "Water is essential for life.", exampleBangla: "জীবনের জন্য পানি অপরিহার্য।", category: .academic, icon: "checkmark.seal.fill", grammarTip: "Use: 'essential for/to'", synonyms: ["crucial", "vital", "necessary"], collocations: ["essential for", "essential to"], difficulty: .beginner),

        IELTSVocabWord(word: "vital", banglaMeaning: "অত্যাবশ্যক", englishMeaning: "absolutely necessary", partOfSpeech: .adjective, example: "Exercise is vital for health.", exampleBangla: "স্বাস্থ্যের জন্য ব্যায়াম অত্যাবশ্যক।", category: .academic, icon: "heart.circle.fill", grammarTip: "Noun: 'vitality'", synonyms: ["essential", "crucial", "critical"], collocations: ["vital role", "vital importance"], difficulty: .intermediate),

        IELTSVocabWord(word: "primary", banglaMeaning: "প্রধান / প্রাথমিক", englishMeaning: "main; most important", partOfSpeech: .adjective, example: "The primary cause is pollution.", exampleBangla: "প্রধান কারণ হল দূষণ।", category: .academic, icon: "1.circle.fill", grammarTip: "Also means 'first' in order", synonyms: ["main", "chief", "principal"], collocations: ["primary reason", "primary concern"], difficulty: .beginner),

        IELTSVocabWord(word: "fundamental", banglaMeaning: "মৌলিক", englishMeaning: "forming a necessary base", partOfSpeech: .adjective, example: "Education is a fundamental right.", exampleBangla: "শিক্ষা একটি মৌলিক অধিকার।", category: .academic, icon: "building.columns.fill", grammarTip: "Noun: 'fundamentals'", synonyms: ["basic", "essential", "core"], collocations: ["fundamental change", "fundamental principle"], difficulty: .intermediate),

        IELTSVocabWord(word: "widespread", banglaMeaning: "ব্যাপক", englishMeaning: "found or distributed over a large area", partOfSpeech: .adjective, example: "Internet use is now widespread.", exampleBangla: "ইন্টারনেট ব্যবহার এখন ব্যাপক।", category: .academic, icon: "globe", grammarTip: "Often used with problems/issues", synonyms: ["extensive", "prevalent", "common"], collocations: ["widespread use", "widespread concern"], difficulty: .intermediate),

        IELTSVocabWord(word: "prevalent", banglaMeaning: "প্রচলিত", englishMeaning: "widespread; common", partOfSpeech: .adjective, example: "Obesity is prevalent in developed countries.", exampleBangla: "উন্নত দেশে স্থূলতা প্রচলিত।", category: .academic, icon: "chart.pie.fill", grammarTip: "Noun: 'prevalence'", synonyms: ["widespread", "common", "frequent"], collocations: ["highly prevalent", "increasingly prevalent"], difficulty: .advanced),

        IELTSVocabWord(word: "adequate", banglaMeaning: "পর্যাপ্ত", englishMeaning: "enough; sufficient", partOfSpeech: .adjective, example: "The resources are not adequate.", exampleBangla: "সম্পদ পর্যাপ্ত নয়।", category: .academic, icon: "checkmark.rectangle.fill", grammarTip: "Opposite: 'inadequate'", synonyms: ["sufficient", "enough", "satisfactory"], collocations: ["adequate resources", "adequate supply"], difficulty: .intermediate),

        IELTSVocabWord(word: "beneficial", banglaMeaning: "উপকারী", englishMeaning: "favorable; advantageous", partOfSpeech: .adjective, example: "Exercise is beneficial for health.", exampleBangla: "ব্যায়াম স্বাস্থ্যের জন্য উপকারী।", category: .academic, icon: "plus.circle.fill", grammarTip: "Use: 'beneficial for/to'", synonyms: ["advantageous", "helpful", "useful"], collocations: ["beneficial effects", "mutually beneficial"], difficulty: .intermediate),

        IELTSVocabWord(word: "detrimental", banglaMeaning: "ক্ষতিকর", englishMeaning: "causing harm or damage", partOfSpeech: .adjective, example: "Smoking is detrimental to health.", exampleBangla: "ধূমপান স্বাস্থ্যের জন্য ক্ষতিকর।", category: .academic, icon: "minus.circle.fill", grammarTip: "Use: 'detrimental to'", synonyms: ["harmful", "damaging", "negative"], collocations: ["detrimental effects", "detrimental to health"], difficulty: .advanced),

        IELTSVocabWord(word: "implement", banglaMeaning: "বাস্তবায়ন করা", englishMeaning: "to put into effect", partOfSpeech: .verb, example: "The government will implement new policies.", exampleBangla: "সরকার নতুন নীতি বাস্তবায়ন করবে।", category: .academic, icon: "hammer.fill", grammarTip: "Noun: 'implementation'", synonyms: ["execute", "carry out", "enforce"], collocations: ["implement a policy", "implement changes"], difficulty: .intermediate),

        IELTSVocabWord(word: "enhance", banglaMeaning: "উন্নত করা", englishMeaning: "to improve quality or value", partOfSpeech: .verb, example: "Technology can enhance learning.", exampleBangla: "প্রযুক্তি শিক্ষা উন্নত করতে পারে।", category: .academic, icon: "arrow.up.circle.fill", grammarTip: "Noun: 'enhancement'", synonyms: ["improve", "boost", "strengthen"], collocations: ["enhance performance", "enhance quality"], difficulty: .intermediate),

        IELTSVocabWord(word: "facilitate", banglaMeaning: "সহজতর করা", englishMeaning: "to make easier", partOfSpeech: .verb, example: "Technology facilitates communication.", exampleBangla: "প্রযুক্তি যোগাযোগ সহজতর করে।", category: .academic, icon: "hand.thumbsup.fill", grammarTip: "Noun: 'facilitation'", synonyms: ["enable", "assist", "help"], collocations: ["facilitate learning", "facilitate communication"], difficulty: .advanced),

        IELTSVocabWord(word: "contribute", banglaMeaning: "অবদান রাখা", englishMeaning: "to give or add to", partOfSpeech: .verb, example: "Factories contribute to pollution.", exampleBangla: "কারখানা দূষণে অবদান রাখে।", category: .academic, icon: "arrow.right.doc.on.clipboard", grammarTip: "Use: 'contribute to' (not 'for')", synonyms: ["add to", "lead to", "cause"], collocations: ["contribute to", "contribute significantly"], difficulty: .beginner),

        IELTSVocabWord(word: "impact", banglaMeaning: "প্রভাব", englishMeaning: "strong effect", partOfSpeech: .noun, example: "Technology has a huge impact on society.", exampleBangla: "প্রযুক্তি সমাজে বিশাল প্রভাব ফেলে।", category: .academic, icon: "bolt.fill", grammarTip: "Use: 'impact on' (not 'impact to')", synonyms: ["effect", "influence", "consequence"], collocations: ["have an impact", "negative impact", "significant impact"], difficulty: .beginner),

        IELTSVocabWord(word: "affect", banglaMeaning: "প্রভাবিত করা", englishMeaning: "to have an effect on", partOfSpeech: .verb, example: "Climate change affects everyone.", exampleBangla: "জলবায়ু পরিবর্তন সবাইকে প্রভাবিত করে।", category: .academic, icon: "waveform.path.ecg", grammarTip: "Don't confuse with 'effect' (noun)", synonyms: ["influence", "impact", "change"], collocations: ["adversely affect", "directly affect"], difficulty: .beginner),

        IELTSVocabWord(word: "decline", banglaMeaning: "হ্রাস / কমা", englishMeaning: "to decrease; to become less", partOfSpeech: .verb, example: "Sales have declined sharply.", exampleBangla: "বিক্রয় তীব্রভাবে কমেছে।", category: .academic, icon: "arrow.down.right", grammarTip: "Can be noun or verb", synonyms: ["decrease", "drop", "fall"], collocations: ["sharp decline", "gradual decline"], difficulty: .intermediate),

        IELTSVocabWord(word: "increase", banglaMeaning: "বৃদ্ধি", englishMeaning: "to become greater", partOfSpeech: .verb, example: "Population continues to increase.", exampleBangla: "জনসংখ্যা বাড়তে থাকে।", category: .academic, icon: "arrow.up.right", grammarTip: "Can be noun or verb", synonyms: ["rise", "grow", "expand"], collocations: ["sharp increase", "steady increase"], difficulty: .beginner),

        IELTSVocabWord(word: "fluctuate", banglaMeaning: "ওঠানামা করা", englishMeaning: "to rise and fall irregularly", partOfSpeech: .verb, example: "Prices fluctuated throughout the year.", exampleBangla: "সারা বছর দাম ওঠানামা করেছে।", category: .academic, icon: "waveform.path", grammarTip: "Noun: 'fluctuation'", synonyms: ["vary", "oscillate", "waver"], collocations: ["fluctuate between", "prices fluctuate"], difficulty: .intermediate),

        IELTSVocabWord(word: "peak", banglaMeaning: "শীর্ষ / চূড়া", englishMeaning: "highest point", partOfSpeech: .noun, example: "Sales reached a peak in December.", exampleBangla: "ডিসেম্বরে বিক্রয় শীর্ষে পৌঁছেছে।", category: .academic, icon: "chart.line.uptrend.xyaxis.circle.fill", grammarTip: "Opposite: 'trough'", synonyms: ["maximum", "highest point", "summit"], collocations: ["reach a peak", "at its peak"], difficulty: .intermediate),

        IELTSVocabWord(word: "steadily", banglaMeaning: "স্থিরভাবে", englishMeaning: "at a constant rate", partOfSpeech: .adverb, example: "Numbers increased steadily.", exampleBangla: "সংখ্যা স্থিরভাবে বেড়েছে।", category: .academic, icon: "arrow.up.forward", grammarTip: "Adjective: 'steady'", synonyms: ["gradually", "consistently", "continuously"], collocations: ["increased steadily", "rose steadily"], difficulty: .beginner),

        IELTSVocabWord(word: "dramatically", banglaMeaning: "নাটকীয়ভাবে", englishMeaning: "suddenly and noticeably", partOfSpeech: .adverb, example: "Costs have risen dramatically.", exampleBangla: "খরচ নাটকীয়ভাবে বেড়েছে।", category: .academic, icon: "bolt.circle.fill", grammarTip: "Adjective: 'dramatic'", synonyms: ["sharply", "significantly", "substantially"], collocations: ["increased dramatically", "changed dramatically"], difficulty: .intermediate),

        IELTSVocabWord(word: "gradually", banglaMeaning: "ধীরে ধীরে", englishMeaning: "slowly; step by step", partOfSpeech: .adverb, example: "The situation improved gradually.", exampleBangla: "পরিস্থিতি ধীরে ধীরে উন্নত হয়েছে।", category: .academic, icon: "chart.line.flattrend.xyaxis", grammarTip: "Adjective: 'gradual'", synonyms: ["slowly", "steadily", "progressively"], collocations: ["gradually increased", "gradually improved"], difficulty: .beginner),

        IELTSVocabWord(word: "approximately", banglaMeaning: "প্রায়", englishMeaning: "close to; nearly", partOfSpeech: .adverb, example: "Approximately 50% agreed.", exampleBangla: "প্রায় ৫০% একমত হয়েছে।", category: .academic, icon: "number.circle.fill", grammarTip: "Use with numbers/amounts", synonyms: ["about", "roughly", "around"], collocations: ["approximately half", "approximately equal"], difficulty: .beginner),

        IELTSVocabWord(word: "comprise", banglaMeaning: "গঠিত হওয়া", englishMeaning: "to consist of", partOfSpeech: .verb, example: "Women comprise 60% of students.", exampleBangla: "শিক্ষার্থীদের ৬০% নারী।", category: .academic, icon: "chart.pie.fill", grammarTip: "Don't use 'comprise of'", synonyms: ["consist of", "make up", "constitute"], collocations: ["comprise the majority", "comprise approximately"], difficulty: .advanced),

        // ==========================================
        // MARK: - OPINION/ARGUMENT WORDS (25 words)
        // ==========================================

        IELTSVocabWord(word: "argue", banglaMeaning: "যুক্তি দেওয়া", englishMeaning: "to give reasons for an opinion", partOfSpeech: .verb, example: "Some argue that technology is harmful.", exampleBangla: "কেউ কেউ যুক্তি দেয় যে প্রযুক্তি ক্ষতিকর।", category: .opinion, icon: "text.bubble.fill", grammarTip: "Use: 'argue that...'", synonyms: ["claim", "contend", "maintain"], collocations: ["some argue", "it could be argued"], difficulty: .beginner),

        IELTSVocabWord(word: "claim", banglaMeaning: "দাবি করা", englishMeaning: "to state as a fact", partOfSpeech: .verb, example: "Critics claim that the policy has failed.", exampleBangla: "সমালোচকরা দাবি করে যে নীতি ব্যর্থ হয়েছে।", category: .opinion, icon: "exclamationmark.bubble.fill", grammarTip: "Can be noun or verb", synonyms: ["argue", "assert", "maintain"], collocations: ["some claim", "critics claim"], difficulty: .beginner),

        IELTSVocabWord(word: "suggest", banglaMeaning: "প্রস্তাব করা / ইঙ্গিত করা", englishMeaning: "to put forward an idea", partOfSpeech: .verb, example: "Studies suggest that sleep is important.", exampleBangla: "গবেষণা ইঙ্গিত করে যে ঘুম গুরুত্বপূর্ণ।", category: .opinion, icon: "lightbulb.fill", grammarTip: "Use: 'suggest that...'", synonyms: ["indicate", "imply", "propose"], collocations: ["research suggests", "studies suggest"], difficulty: .beginner),

        IELTSVocabWord(word: "believe", banglaMeaning: "বিশ্বাস করা", englishMeaning: "to think something is true", partOfSpeech: .verb, example: "Many believe education is important.", exampleBangla: "অনেকে বিশ্বাস করে শিক্ষা গুরুত্বপূর্ণ।", category: .opinion, icon: "person.fill.checkmark", grammarTip: "Use: 'believe that...'", synonyms: ["think", "consider", "feel"], collocations: ["many believe", "widely believed"], difficulty: .beginner),

        IELTSVocabWord(word: "advocate", banglaMeaning: "সমর্থন করা", englishMeaning: "to publicly support", partOfSpeech: .verb, example: "Experts advocate for stricter laws.", exampleBangla: "বিশেষজ্ঞরা কঠোর আইনের পক্ষে সমর্থন করে।", category: .opinion, icon: "megaphone.fill", grammarTip: "Can be noun (supporter)", synonyms: ["support", "promote", "champion"], collocations: ["advocate for", "strong advocate"], difficulty: .intermediate),

        IELTSVocabWord(word: "oppose", banglaMeaning: "বিরোধিতা করা", englishMeaning: "to disagree with", partOfSpeech: .verb, example: "Many oppose the new policy.", exampleBangla: "অনেকে নতুন নীতির বিরোধিতা করে।", category: .opinion, icon: "hand.raised.slash.fill", grammarTip: "Noun: 'opposition'", synonyms: ["object to", "resist", "reject"], collocations: ["strongly oppose", "oppose the idea"], difficulty: .intermediate),

        IELTSVocabWord(word: "support", banglaMeaning: "সমর্থন করা", englishMeaning: "to agree with; help", partOfSpeech: .verb, example: "I support this view.", exampleBangla: "আমি এই মতামত সমর্থন করি।", category: .opinion, icon: "hand.thumbsup.fill", grammarTip: "Can be noun or verb", synonyms: ["back", "endorse", "favor"], collocations: ["support the idea", "strongly support"], difficulty: .beginner),

        IELTSVocabWord(word: "controversial", banglaMeaning: "বিতর্কিত", englishMeaning: "causing disagreement", partOfSpeech: .adjective, example: "This is a controversial topic.", exampleBangla: "এটি একটি বিতর্কিত বিষয়।", category: .opinion, icon: "bubble.left.and.bubble.right.fill", grammarTip: "Noun: 'controversy'", synonyms: ["contentious", "debatable", "disputed"], collocations: ["controversial issue", "highly controversial"], difficulty: .intermediate),

        IELTSVocabWord(word: "debatable", banglaMeaning: "বিতর্কযোগ্য", englishMeaning: "open to discussion", partOfSpeech: .adjective, example: "This point is debatable.", exampleBangla: "এই বিষয়টি বিতর্কযোগ্য।", category: .opinion, icon: "questionmark.bubble.fill", grammarTip: "Related: 'debate'", synonyms: ["controversial", "questionable", "arguable"], collocations: ["highly debatable", "debatable whether"], difficulty: .intermediate),

        IELTSVocabWord(word: "advantage", banglaMeaning: "সুবিধা", englishMeaning: "a benefit or positive aspect", partOfSpeech: .noun, example: "The main advantage is cost savings.", exampleBangla: "প্রধান সুবিধা হল খরচ সাশ্রয়।", category: .opinion, icon: "plus.circle.fill", grammarTip: "Adjective: 'advantageous'", synonyms: ["benefit", "merit", "plus"], collocations: ["main advantage", "take advantage of"], difficulty: .beginner),

        IELTSVocabWord(word: "disadvantage", banglaMeaning: "অসুবিধা", englishMeaning: "a negative aspect", partOfSpeech: .noun, example: "One disadvantage is the high cost.", exampleBangla: "একটি অসুবিধা হল উচ্চ খরচ।", category: .opinion, icon: "minus.circle.fill", grammarTip: "Adjective: 'disadvantageous'", synonyms: ["drawback", "downside", "limitation"], collocations: ["major disadvantage", "at a disadvantage"], difficulty: .beginner),

        IELTSVocabWord(word: "drawback", banglaMeaning: "ত্রুটি / অসুবিধা", englishMeaning: "a disadvantage or problem", partOfSpeech: .noun, example: "The main drawback is the price.", exampleBangla: "প্রধান ত্রুটি হল দাম।", category: .opinion, icon: "exclamationmark.triangle.fill", grammarTip: "Formal alternative to 'problem'", synonyms: ["disadvantage", "downside", "shortcoming"], collocations: ["major drawback", "one drawback"], difficulty: .intermediate),

        IELTSVocabWord(word: "outweigh", banglaMeaning: "অধিক গুরুত্বপূর্ণ হওয়া", englishMeaning: "to be more important than", partOfSpeech: .verb, example: "The benefits outweigh the costs.", exampleBangla: "সুবিধাগুলো খরচের চেয়ে বেশি গুরুত্বপূর্ণ।", category: .opinion, icon: "scalemass", grammarTip: "Very useful for advantage/disadvantage essays", synonyms: ["exceed", "surpass", "override"], collocations: ["benefits outweigh", "advantages outweigh"], difficulty: .intermediate),

        // ==========================================
        // MARK: - ENVIRONMENT WORDS (25 words)
        // ==========================================

        IELTSVocabWord(word: "pollution", banglaMeaning: "দূষণ", englishMeaning: "harmful substances in environment", partOfSpeech: .noun, example: "Air pollution is a serious problem.", exampleBangla: "বায়ু দূষণ একটি গুরুতর সমস্যা।", category: .environment, icon: "smoke.fill", grammarTip: "Verb: 'pollute'", synonyms: ["contamination", "smog", "impurity"], collocations: ["air pollution", "water pollution", "reduce pollution"], difficulty: .beginner),

        IELTSVocabWord(word: "sustainable", banglaMeaning: "টেকসই", englishMeaning: "able to continue without damage", partOfSpeech: .adjective, example: "We need sustainable development.", exampleBangla: "আমাদের টেকসই উন্নয়ন দরকার।", category: .environment, icon: "leaf.circle.fill", grammarTip: "Noun: 'sustainability'", synonyms: ["eco-friendly", "green", "renewable"], collocations: ["sustainable development", "sustainable energy"], difficulty: .intermediate),

        IELTSVocabWord(word: "renewable", banglaMeaning: "নবায়নযোগ্য", englishMeaning: "can be replaced naturally", partOfSpeech: .adjective, example: "Solar power is renewable.", exampleBangla: "সৌর শক্তি নবায়নযোগ্য।", category: .environment, icon: "sun.max.fill", grammarTip: "Opposite: 'non-renewable'", synonyms: ["sustainable", "replenishable", "green"], collocations: ["renewable energy", "renewable resources"], difficulty: .intermediate),

        IELTSVocabWord(word: "emissions", banglaMeaning: "নির্গমন", englishMeaning: "gases released into air", partOfSpeech: .noun, example: "Carbon emissions must be reduced.", exampleBangla: "কার্বন নির্গমন কমাতে হবে।", category: .environment, icon: "cloud.fill", grammarTip: "Verb: 'emit'", synonyms: ["discharge", "output", "release"], collocations: ["carbon emissions", "reduce emissions"], difficulty: .intermediate),

        IELTSVocabWord(word: "climate change", banglaMeaning: "জলবায়ু পরিবর্তন", englishMeaning: "long-term changes in weather", partOfSpeech: .phrase, example: "Climate change affects everyone.", exampleBangla: "জলবায়ু পরিবর্তন সবাইকে প্রভাবিত করে।", category: .environment, icon: "thermometer.sun.fill", grammarTip: "Related: 'global warming'", synonyms: ["global warming", "climate crisis"], collocations: ["combat climate change", "effects of climate change"], difficulty: .beginner),

        IELTSVocabWord(word: "biodiversity", banglaMeaning: "জীববৈচিত্র্য", englishMeaning: "variety of plant and animal life", partOfSpeech: .noun, example: "We must protect biodiversity.", exampleBangla: "আমাদের জীববৈচিত্র্য রক্ষা করতে হবে।", category: .environment, icon: "tortoise.fill", grammarTip: "bio (life) + diversity (variety)", synonyms: ["variety of life", "ecological diversity"], collocations: ["protect biodiversity", "loss of biodiversity"], difficulty: .advanced),

        IELTSVocabWord(word: "deforestation", banglaMeaning: "বন উজাড়", englishMeaning: "cutting down forests", partOfSpeech: .noun, example: "Deforestation destroys habitats.", exampleBangla: "বন উজাড় বাসস্থান ধ্বংস করে।", category: .environment, icon: "leaf.arrow.triangle.circlepath", grammarTip: "Verb: 'deforest'", synonyms: ["forest clearing", "logging"], collocations: ["illegal deforestation", "prevent deforestation"], difficulty: .intermediate),

        IELTSVocabWord(word: "ecosystem", banglaMeaning: "বাস্তুতন্ত্র", englishMeaning: "community of living things", partOfSpeech: .noun, example: "Pollution damages ecosystems.", exampleBangla: "দূষণ বাস্তুতন্ত্র ক্ষতি করে।", category: .environment, icon: "globe.americas.fill", grammarTip: "eco (environment) + system", synonyms: ["habitat", "environment", "biome"], collocations: ["marine ecosystem", "fragile ecosystem"], difficulty: .intermediate),

        IELTSVocabWord(word: "conservation", banglaMeaning: "সংরক্ষণ", englishMeaning: "protection of nature", partOfSpeech: .noun, example: "Wildlife conservation is important.", exampleBangla: "বন্যপ্রাণী সংরক্ষণ গুরুত্বপূর্ণ।", category: .environment, icon: "hand.raised.fill", grammarTip: "Verb: 'conserve'", synonyms: ["preservation", "protection", "safeguarding"], collocations: ["wildlife conservation", "energy conservation"], difficulty: .intermediate),

        IELTSVocabWord(word: "endangered", banglaMeaning: "বিপন্ন", englishMeaning: "at risk of extinction", partOfSpeech: .adjective, example: "Tigers are endangered species.", exampleBangla: "বাঘ বিপন্ন প্রজাতি।", category: .environment, icon: "exclamationmark.triangle", grammarTip: "Verb: 'endanger'", synonyms: ["threatened", "at risk", "vulnerable"], collocations: ["endangered species", "critically endangered"], difficulty: .intermediate),

        // ==========================================
        // MARK: - TECHNOLOGY WORDS (20 words)
        // ==========================================

        IELTSVocabWord(word: "innovation", banglaMeaning: "উদ্ভাবন", englishMeaning: "a new idea or method", partOfSpeech: .noun, example: "Innovation drives progress.", exampleBangla: "উদ্ভাবন অগ্রগতি চালায়।", category: .technology, icon: "lightbulb.fill", grammarTip: "Verb: 'innovate', Adjective: 'innovative'", synonyms: ["invention", "breakthrough", "advancement"], collocations: ["technological innovation", "drive innovation"], difficulty: .intermediate),

        IELTSVocabWord(word: "automation", banglaMeaning: "স্বয়ংক্রিয়করণ", englishMeaning: "use of machines without humans", partOfSpeech: .noun, example: "Automation reduces costs.", exampleBangla: "স্বয়ংক্রিয়করণ খরচ কমায়।", category: .technology, icon: "gearshape.2.fill", grammarTip: "Verb: 'automate'", synonyms: ["mechanization", "computerization"], collocations: ["industrial automation", "automation of tasks"], difficulty: .intermediate),

        IELTSVocabWord(word: "artificial intelligence", banglaMeaning: "কৃত্রিম বুদ্ধিমত্তা", englishMeaning: "computer systems that think", partOfSpeech: .phrase, example: "AI is transforming industries.", exampleBangla: "AI শিল্পকে রূপান্তরিত করছে।", category: .technology, icon: "brain.head.profile", grammarTip: "Short form: AI", synonyms: ["AI", "machine intelligence"], collocations: ["AI technology", "powered by AI"], difficulty: .intermediate),

        IELTSVocabWord(word: "digital", banglaMeaning: "ডিজিটাল", englishMeaning: "using computer technology", partOfSpeech: .adjective, example: "We live in a digital age.", exampleBangla: "আমরা ডিজিটাল যুগে বাস করি।", category: .technology, icon: "desktopcomputer", grammarTip: "Verb: 'digitalize'", synonyms: ["electronic", "computerized", "online"], collocations: ["digital technology", "digital age"], difficulty: .beginner),

        IELTSVocabWord(word: "connectivity", banglaMeaning: "সংযোগ", englishMeaning: "state of being connected", partOfSpeech: .noun, example: "Internet connectivity has improved.", exampleBangla: "ইন্টারনেট সংযোগ উন্নত হয়েছে।", category: .technology, icon: "wifi", grammarTip: "Verb: 'connect'", synonyms: ["connection", "network", "link"], collocations: ["internet connectivity", "global connectivity"], difficulty: .intermediate),

        // ==========================================
        // MARK: - SOCIETY WORDS (20 words)
        // ==========================================

        IELTSVocabWord(word: "inequality", banglaMeaning: "অসমতা", englishMeaning: "unfair difference between groups", partOfSpeech: .noun, example: "Income inequality is growing.", exampleBangla: "আয় অসমতা বাড়ছে।", category: .society, icon: "scalemass.fill", grammarTip: "Opposite: 'equality'", synonyms: ["disparity", "imbalance", "unfairness"], collocations: ["social inequality", "income inequality"], difficulty: .intermediate),

        IELTSVocabWord(word: "discrimination", banglaMeaning: "বৈষম্য", englishMeaning: "unfair treatment of people", partOfSpeech: .noun, example: "Discrimination is illegal.", exampleBangla: "বৈষম্য অবৈধ।", category: .society, icon: "person.2.slash.fill", grammarTip: "Verb: 'discriminate'", synonyms: ["prejudice", "bias", "racism"], collocations: ["racial discrimination", "face discrimination"], difficulty: .intermediate),

        IELTSVocabWord(word: "urbanization", banglaMeaning: "নগরায়ন", englishMeaning: "growth of cities", partOfSpeech: .noun, example: "Urbanization causes housing problems.", exampleBangla: "নগরায়ন আবাসন সমস্যা সৃষ্টি করে।", category: .society, icon: "building.2.fill", grammarTip: "Verb: 'urbanize'", synonyms: ["city growth", "urban development"], collocations: ["rapid urbanization", "urbanization rate"], difficulty: .intermediate),

        IELTSVocabWord(word: "globalization", banglaMeaning: "বিশ্বায়ন", englishMeaning: "world becoming more connected", partOfSpeech: .noun, example: "Globalization has pros and cons.", exampleBangla: "বিশ্বায়নের ভালো ও খারাপ দিক আছে।", category: .society, icon: "globe.americas.fill", grammarTip: "Verb: 'globalize'", synonyms: ["internationalization", "global integration"], collocations: ["economic globalization", "effects of globalization"], difficulty: .intermediate),

        IELTSVocabWord(word: "poverty", banglaMeaning: "দারিদ্র্য", englishMeaning: "state of being very poor", partOfSpeech: .noun, example: "Poverty affects millions.", exampleBangla: "দারিদ্র্য লক্ষ লক্ষ মানুষকে প্রভাবিত করে।", category: .society, icon: "dollarsign.circle", grammarTip: "Adjective: 'poor'", synonyms: ["hardship", "deprivation", "need"], collocations: ["extreme poverty", "poverty line"], difficulty: .beginner),

        IELTSVocabWord(word: "unemployment", banglaMeaning: "বেকারত্ব", englishMeaning: "state of not having a job", partOfSpeech: .noun, example: "Unemployment is rising.", exampleBangla: "বেকারত্ব বাড়ছে।", category: .society, icon: "person.crop.circle.badge.xmark", grammarTip: "Adjective: 'unemployed'", synonyms: ["joblessness"], collocations: ["unemployment rate", "high unemployment"], difficulty: .beginner),

        // ==========================================
        // MARK: - EDUCATION WORDS (20 words)
        // ==========================================

        IELTSVocabWord(word: "curriculum", banglaMeaning: "পাঠ্যক্রম", englishMeaning: "subjects in a course of study", partOfSpeech: .noun, example: "The curriculum needs updating.", exampleBangla: "পাঠ্যক্রম আপডেট করা দরকার।", category: .education, icon: "list.clipboard.fill", grammarTip: "Plural: 'curricula'", synonyms: ["syllabus", "program", "course"], collocations: ["school curriculum", "national curriculum"], difficulty: .intermediate),

        IELTSVocabWord(word: "literacy", banglaMeaning: "সাক্ষরতা", englishMeaning: "ability to read and write", partOfSpeech: .noun, example: "Literacy rates are improving.", exampleBangla: "সাক্ষরতার হার উন্নত হচ্ছে।", category: .education, icon: "textformat.abc", grammarTip: "Adjective: 'literate'", synonyms: ["reading ability", "education"], collocations: ["literacy rate", "digital literacy"], difficulty: .intermediate),

        IELTSVocabWord(word: "compulsory", banglaMeaning: "বাধ্যতামূলক", englishMeaning: "required by law", partOfSpeech: .adjective, example: "Education is compulsory until 16.", exampleBangla: "১৬ বছর পর্যন্ত শিক্ষা বাধ্যতামূলক।", category: .education, icon: "checkmark.seal.fill", grammarTip: "Synonym: 'mandatory'", synonyms: ["mandatory", "obligatory", "required"], collocations: ["compulsory education", "compulsory subject"], difficulty: .intermediate),

        IELTSVocabWord(word: "tuition", banglaMeaning: "শিক্ষা ফি / টিউশন", englishMeaning: "teaching; fees for education", partOfSpeech: .noun, example: "Tuition fees are too high.", exampleBangla: "টিউশন ফি অনেক বেশি।", category: .education, icon: "dollarsign.circle.fill", grammarTip: "Two meanings: teaching OR fees", synonyms: ["fees", "instruction", "teaching"], collocations: ["tuition fees", "private tuition"], difficulty: .intermediate),

        IELTSVocabWord(word: "scholarship", banglaMeaning: "বৃত্তি", englishMeaning: "money given for education", partOfSpeech: .noun, example: "She won a scholarship.", exampleBangla: "সে বৃত্তি পেয়েছে।", category: .education, icon: "graduationcap.fill", grammarTip: "Verb: 'award a scholarship'", synonyms: ["grant", "bursary", "fellowship"], collocations: ["win a scholarship", "full scholarship"], difficulty: .beginner),

        // ==========================================
        // MARK: - HEALTH WORDS (15 words)
        // ==========================================

        IELTSVocabWord(word: "obesity", banglaMeaning: "স্থূলতা", englishMeaning: "condition of being very overweight", partOfSpeech: .noun, example: "Obesity is a growing problem.", exampleBangla: "স্থূলতা একটি ক্রমবর্ধমান সমস্যা।", category: .health, icon: "figure.stand", grammarTip: "Adjective: 'obese'", synonyms: ["overweight", "corpulence"], collocations: ["childhood obesity", "obesity rates"], difficulty: .intermediate),

        IELTSVocabWord(word: "sedentary", banglaMeaning: "বসে থাকা / নিষ্ক্রিয়", englishMeaning: "involving much sitting", partOfSpeech: .adjective, example: "Sedentary lifestyles cause health problems.", exampleBangla: "নিষ্ক্রিয় জীবনধারা স্বাস্থ্য সমস্যা সৃষ্টি করে।", category: .health, icon: "figure.seated.seatbelt", grammarTip: "Opposite: 'active'", synonyms: ["inactive", "desk-bound", "stationary"], collocations: ["sedentary lifestyle", "sedentary work"], difficulty: .advanced),

        IELTSVocabWord(word: "epidemic", banglaMeaning: "মহামারী", englishMeaning: "widespread disease", partOfSpeech: .noun, example: "The epidemic spread quickly.", exampleBangla: "মহামারী দ্রুত ছড়িয়ে পড়ে।", category: .health, icon: "allergens", grammarTip: "Larger: 'pandemic'", synonyms: ["outbreak", "plague", "pandemic"], collocations: ["epidemic disease", "obesity epidemic"], difficulty: .intermediate),

        IELTSVocabWord(word: "nutrition", banglaMeaning: "পুষ্টি", englishMeaning: "food and health", partOfSpeech: .noun, example: "Good nutrition is essential.", exampleBangla: "ভালো পুষ্টি অপরিহার্য।", category: .health, icon: "carrot.fill", grammarTip: "Adjective: 'nutritious'", synonyms: ["diet", "nourishment"], collocations: ["good nutrition", "child nutrition"], difficulty: .intermediate),

        IELTSVocabWord(word: "wellbeing", banglaMeaning: "সুস্থতা / কল্যাণ", englishMeaning: "state of being healthy and happy", partOfSpeech: .noun, example: "Mental wellbeing is important.", exampleBangla: "মানসিক সুস্থতা গুরুত্বপূর্ণ।", category: .health, icon: "heart.circle.fill", grammarTip: "Also spelled 'well-being'", synonyms: ["welfare", "health", "happiness"], collocations: ["mental wellbeing", "physical wellbeing"], difficulty: .intermediate),

        // ==========================================
        // MARK: - BUSINESS/ECONOMY WORDS (15 words)
        // ==========================================

        IELTSVocabWord(word: "revenue", banglaMeaning: "রাজস্ব / আয়", englishMeaning: "income of a company/government", partOfSpeech: .noun, example: "Revenue increased by 20%.", exampleBangla: "রাজস্ব ২০% বেড়েছে।", category: .business, icon: "dollarsign.circle.fill", grammarTip: "Different from 'profit'", synonyms: ["income", "earnings", "turnover"], collocations: ["annual revenue", "generate revenue"], difficulty: .intermediate),

        IELTSVocabWord(word: "workforce", banglaMeaning: "কর্মীবাহিনী", englishMeaning: "all workers in a company/country", partOfSpeech: .noun, example: "The workforce is aging.", exampleBangla: "কর্মীবাহিনীর বয়স বাড়ছে।", category: .business, icon: "person.3.sequence.fill", grammarTip: "Synonym: 'labor force'", synonyms: ["staff", "employees", "workers"], collocations: ["skilled workforce", "female workforce"], difficulty: .intermediate),

        IELTSVocabWord(word: "entrepreneur", banglaMeaning: "উদ্যোক্তা", englishMeaning: "person who starts a business", partOfSpeech: .noun, example: "Young entrepreneurs create jobs.", exampleBangla: "তরুণ উদ্যোক্তারা চাকরি সৃষ্টি করে।", category: .business, icon: "lightbulb.max.fill", grammarTip: "Adjective: 'entrepreneurial'", synonyms: ["businessperson", "founder"], collocations: ["successful entrepreneur", "young entrepreneur"], difficulty: .intermediate),

        IELTSVocabWord(word: "investment", banglaMeaning: "বিনিয়োগ", englishMeaning: "money put into something for profit", partOfSpeech: .noun, example: "Investment in education is crucial.", exampleBangla: "শিক্ষায় বিনিয়োগ গুরুত্বপূর্ণ।", category: .business, icon: "chart.line.uptrend.xyaxis", grammarTip: "Verb: 'invest'", synonyms: ["funding", "capital"], collocations: ["foreign investment", "investment in"], difficulty: .intermediate),

        IELTSVocabWord(word: "economy", banglaMeaning: "অর্থনীতি", englishMeaning: "system of money and trade", partOfSpeech: .noun, example: "The economy is growing.", exampleBangla: "অর্থনীতি বাড়ছে।", category: .business, icon: "building.columns.fill", grammarTip: "Adjective: 'economic'", synonyms: ["financial system"], collocations: ["global economy", "boost the economy"], difficulty: .beginner),

        IELTSVocabWord(word: "inflation", banglaMeaning: "মুদ্রাস্ফীতি", englishMeaning: "general increase in prices", partOfSpeech: .noun, example: "Inflation is at 5%.", exampleBangla: "মুদ্রাস্ফীতি ৫%।", category: .business, icon: "arrow.up.circle.fill", grammarTip: "Verb: 'inflate'", synonyms: ["price increase", "rising costs"], collocations: ["high inflation", "inflation rate"], difficulty: .intermediate),

        IELTSVocabWord(word: "recession", banglaMeaning: "মন্দা", englishMeaning: "period of economic decline", partOfSpeech: .noun, example: "The country is in recession.", exampleBangla: "দেশটি মন্দায় আছে।", category: .business, icon: "chart.line.downtrend.xyaxis", grammarTip: "Opposite: 'growth/boom'", synonyms: ["downturn", "slump", "depression"], collocations: ["economic recession", "global recession"], difficulty: .intermediate),

        IELTSVocabWord(word: "infrastructure", banglaMeaning: "অবকাঠামো", englishMeaning: "basic facilities of a country", partOfSpeech: .noun, example: "Infrastructure needs investment.", exampleBangla: "অবকাঠামোতে বিনিয়োগ দরকার।", category: .business, icon: "road.lanes", grammarTip: "Includes roads, bridges, etc.", synonyms: ["facilities", "framework"], collocations: ["transport infrastructure", "invest in infrastructure"], difficulty: .intermediate),

        IELTSVocabWord(word: "commodity", banglaMeaning: "পণ্য", englishMeaning: "raw material or product", partOfSpeech: .noun, example: "Oil is an important commodity.", exampleBangla: "তেল একটি গুরুত্বপূর্ণ পণ্য।", category: .business, icon: "shippingbox.fill", grammarTip: "Plural: 'commodities'", synonyms: ["goods", "products", "merchandise"], collocations: ["commodity prices", "agricultural commodities"], difficulty: .intermediate),

        // ==========================================
        // MARK: - MORE TECHNOLOGY WORDS (15 more)
        // ==========================================

        IELTSVocabWord(word: "cybersecurity", banglaMeaning: "সাইবার নিরাপত্তা", englishMeaning: "protection against digital attacks", partOfSpeech: .noun, example: "Cybersecurity is essential for businesses.", exampleBangla: "ব্যবসার জন্য সাইবার নিরাপত্তা অপরিহার্য।", category: .technology, icon: "lock.shield.fill", grammarTip: "Also: 'cyber security'", synonyms: ["digital security", "IT security"], collocations: ["cybersecurity threats", "improve cybersecurity"], difficulty: .intermediate),

        IELTSVocabWord(word: "obsolete", banglaMeaning: "অপ্রচলিত", englishMeaning: "no longer used or outdated", partOfSpeech: .adjective, example: "Technology quickly becomes obsolete.", exampleBangla: "প্রযুক্তি দ্রুত অপ্রচলিত হয়ে যায়।", category: .technology, icon: "xmark.circle.fill", grammarTip: "Noun: 'obsolescence'", synonyms: ["outdated", "old-fashioned", "antiquated"], collocations: ["become obsolete", "render obsolete"], difficulty: .intermediate),

        IELTSVocabWord(word: "revolutionize", banglaMeaning: "বিপ্লব ঘটানো", englishMeaning: "to change completely", partOfSpeech: .verb, example: "The internet revolutionized communication.", exampleBangla: "ইন্টারনেট যোগাযোগে বিপ্লব ঘটিয়েছে।", category: .technology, icon: "sparkles", grammarTip: "Noun: 'revolution'", synonyms: ["transform", "change radically"], collocations: ["revolutionize the industry", "revolutionize how"], difficulty: .intermediate),

        IELTSVocabWord(word: "virtual", banglaMeaning: "ভার্চুয়াল / কল্পিত", englishMeaning: "existing on computers, not physical", partOfSpeech: .adjective, example: "Virtual meetings are common now.", exampleBangla: "ভার্চুয়াল মিটিং এখন সাধারণ।", category: .technology, icon: "display", grammarTip: "Adverb: 'virtually'", synonyms: ["online", "digital", "simulated"], collocations: ["virtual reality", "virtual meeting"], difficulty: .beginner),

        IELTSVocabWord(word: "algorithm", banglaMeaning: "অ্যালগরিদম", englishMeaning: "set of computer instructions", partOfSpeech: .noun, example: "Social media uses algorithms.", exampleBangla: "সোশ্যাল মিডিয়া অ্যালগরিদম ব্যবহার করে।", category: .technology, icon: "function", grammarTip: "Adjective: 'algorithmic'", synonyms: ["program", "formula", "procedure"], collocations: ["search algorithm", "AI algorithm"], difficulty: .advanced),

        IELTSVocabWord(word: "surveillance", banglaMeaning: "নজরদারি", englishMeaning: "close watching of someone", partOfSpeech: .noun, example: "Surveillance cameras are everywhere.", exampleBangla: "নজরদারি ক্যামেরা সব জায়গায় আছে।", category: .technology, icon: "video.fill", grammarTip: "Related: 'monitor'", synonyms: ["monitoring", "observation", "watch"], collocations: ["surveillance camera", "under surveillance"], difficulty: .intermediate),

        IELTSVocabWord(word: "database", banglaMeaning: "ডাটাবেস", englishMeaning: "organized collection of data", partOfSpeech: .noun, example: "The database stores customer information.", exampleBangla: "ডাটাবেস গ্রাহকের তথ্য সংরক্ষণ করে।", category: .technology, icon: "externaldrive.fill", grammarTip: "Also: 'data base'", synonyms: ["data store", "information system"], collocations: ["database management", "online database"], difficulty: .intermediate),

        IELTSVocabWord(word: "software", banglaMeaning: "সফটওয়্যার", englishMeaning: "computer programs", partOfSpeech: .noun, example: "Software needs regular updates.", exampleBangla: "সফটওয়্যারের নিয়মিত আপডেট দরকার।", category: .technology, icon: "app.fill", grammarTip: "Opposite: 'hardware'", synonyms: ["programs", "applications", "apps"], collocations: ["software development", "install software"], difficulty: .beginner),

        IELTSVocabWord(word: "bandwidth", banglaMeaning: "ব্যান্ডউইথ", englishMeaning: "data transmission capacity", partOfSpeech: .noun, example: "Video calls require high bandwidth.", exampleBangla: "ভিডিও কলের জন্য উচ্চ ব্যান্ডউইথ দরকার।", category: .technology, icon: "wifi.circle.fill", grammarTip: "Technical term", synonyms: ["capacity", "throughput"], collocations: ["high bandwidth", "bandwidth limit"], difficulty: .advanced),

        IELTSVocabWord(word: "download", banglaMeaning: "ডাউনলোড", englishMeaning: "to transfer data to device", partOfSpeech: .verb, example: "You can download the app free.", exampleBangla: "আপনি অ্যাপটি বিনামূল্যে ডাউনলোড করতে পারেন।", category: .technology, icon: "arrow.down.circle.fill", grammarTip: "Opposite: 'upload'", synonyms: ["transfer", "save"], collocations: ["download files", "free download"], difficulty: .beginner),

        // ==========================================
        // MARK: - MORE EDUCATION WORDS (15 more)
        // ==========================================

        IELTSVocabWord(word: "vocational", banglaMeaning: "বৃত্তিমূলক", englishMeaning: "related to a job or career", partOfSpeech: .adjective, example: "Vocational training is practical.", exampleBangla: "বৃত্তিমূলক প্রশিক্ষণ ব্যবহারিক।", category: .education, icon: "wrench.and.screwdriver.fill", grammarTip: "Noun: 'vocation'", synonyms: ["occupational", "career", "job-related"], collocations: ["vocational training", "vocational education"], difficulty: .intermediate),

        IELTSVocabWord(word: "undergraduate", banglaMeaning: "স্নাতক শিক্ষার্থী", englishMeaning: "university student before degree", partOfSpeech: .noun, example: "Undergraduates study for 3-4 years.", exampleBangla: "স্নাতক শিক্ষার্থীরা ৩-৪ বছর পড়াশোনা করে।", category: .education, icon: "person.fill", grammarTip: "After degree: 'postgraduate'", synonyms: ["student", "bachelor's student"], collocations: ["undergraduate degree", "undergraduate student"], difficulty: .intermediate),

        IELTSVocabWord(word: "postgraduate", banglaMeaning: "স্নাতকোত্তর", englishMeaning: "study after first degree", partOfSpeech: .noun, example: "She is doing postgraduate research.", exampleBangla: "সে স্নাতকোত্তর গবেষণা করছে।", category: .education, icon: "person.fill.checkmark", grammarTip: "Also: 'graduate student'", synonyms: ["graduate", "master's student"], collocations: ["postgraduate degree", "postgraduate studies"], difficulty: .intermediate),

        IELTSVocabWord(word: "dissertation", banglaMeaning: "গবেষণা পত্র", englishMeaning: "long essay for degree", partOfSpeech: .noun, example: "She wrote her dissertation on climate.", exampleBangla: "সে জলবায়ু নিয়ে গবেষণা পত্র লিখেছে।", category: .education, icon: "doc.text.fill", grammarTip: "Similar: 'thesis'", synonyms: ["thesis", "research paper"], collocations: ["write a dissertation", "doctoral dissertation"], difficulty: .advanced),

        IELTSVocabWord(word: "faculty", banglaMeaning: "অনুষদ / শিক্ষকমণ্ডলী", englishMeaning: "teaching staff of university", partOfSpeech: .noun, example: "The faculty includes 50 professors.", exampleBangla: "অনুষদে ৫০ জন অধ্যাপক আছেন।", category: .education, icon: "person.3.fill", grammarTip: "Two meanings: staff OR department", synonyms: ["staff", "teachers", "department"], collocations: ["faculty member", "faculty of arts"], difficulty: .intermediate),

        IELTSVocabWord(word: "enroll", banglaMeaning: "নাম লেখানো / ভর্তি হওয়া", englishMeaning: "to register for a course", partOfSpeech: .verb, example: "She enrolled in a language course.", exampleBangla: "সে ভাষা কোর্সে ভর্তি হয়েছে।", category: .education, icon: "list.clipboard.fill", grammarTip: "Noun: 'enrollment'", synonyms: ["register", "sign up", "join"], collocations: ["enroll in a course", "enrollment rate"], difficulty: .beginner),

        IELTSVocabWord(word: "diploma", banglaMeaning: "ডিপ্লোমা", englishMeaning: "certificate for completing study", partOfSpeech: .noun, example: "He earned a diploma in IT.", exampleBangla: "সে আইটিতে ডিপ্লোমা অর্জন করেছে।", category: .education, icon: "scroll.fill", grammarTip: "Lower than degree", synonyms: ["certificate", "qualification"], collocations: ["diploma course", "earn a diploma"], difficulty: .beginner),

        IELTSVocabWord(word: "academic", banglaMeaning: "শিক্ষাগত / একাডেমিক", englishMeaning: "related to education and studying", partOfSpeech: .adjective, example: "Academic performance improved.", exampleBangla: "শিক্ষাগত কার্যকারিতা উন্নত হয়েছে।", category: .education, icon: "book.circle.fill", grammarTip: "Noun: 'academia'", synonyms: ["educational", "scholarly"], collocations: ["academic year", "academic performance"], difficulty: .beginner),

        IELTSVocabWord(word: "graduate", banglaMeaning: "স্নাতক হওয়া", englishMeaning: "to complete education", partOfSpeech: .verb, example: "She graduated with honors.", exampleBangla: "সে সম্মানের সাথে স্নাতক হয়েছে।", category: .education, icon: "graduationcap.fill", grammarTip: "Can be noun or verb", synonyms: ["complete", "finish studies"], collocations: ["graduate from", "graduate with honors"], difficulty: .beginner),

        IELTSVocabWord(word: "syllabus", banglaMeaning: "পাঠ্যসূচি", englishMeaning: "outline of course content", partOfSpeech: .noun, example: "Check the syllabus for exam topics.", exampleBangla: "পরীক্ষার বিষয়ের জন্য পাঠ্যসূচি দেখুন।", category: .education, icon: "list.bullet.rectangle.fill", grammarTip: "Plural: 'syllabi' or 'syllabuses'", synonyms: ["curriculum", "course outline"], collocations: ["course syllabus", "exam syllabus"], difficulty: .intermediate),

        // ==========================================
        // MARK: - MORE SOCIETY WORDS (15 more)
        // ==========================================

        IELTSVocabWord(word: "demographic", banglaMeaning: "জনসংখ্যাতাত্ত্বিক", englishMeaning: "related to population statistics", partOfSpeech: .adjective, example: "Demographic changes affect policy.", exampleBangla: "জনসংখ্যাতাত্ত্বিক পরিবর্তন নীতি প্রভাবিত করে।", category: .society, icon: "person.3.sequence.fill", grammarTip: "Noun: 'demographics'", synonyms: ["population", "statistical"], collocations: ["demographic change", "demographic data"], difficulty: .advanced),

        IELTSVocabWord(word: "migration", banglaMeaning: "অভিবাসন", englishMeaning: "movement of people to new place", partOfSpeech: .noun, example: "Migration to cities is increasing.", exampleBangla: "শহরে অভিবাসন বাড়ছে।", category: .society, icon: "figure.walk.motion", grammarTip: "Verb: 'migrate'", synonyms: ["movement", "relocation", "emigration"], collocations: ["mass migration", "rural migration"], difficulty: .intermediate),

        IELTSVocabWord(word: "immigrant", banglaMeaning: "অভিবাসী", englishMeaning: "person who moves to new country", partOfSpeech: .noun, example: "Immigrants contribute to the economy.", exampleBangla: "অভিবাসীরা অর্থনীতিতে অবদান রাখে।", category: .society, icon: "figure.walk.arrival", grammarTip: "Verb: 'immigrate'", synonyms: ["migrant", "newcomer", "settler"], collocations: ["illegal immigrant", "immigrant community"], difficulty: .intermediate),

        IELTSVocabWord(word: "diverse", banglaMeaning: "বৈচিত্র্যপূর্ণ", englishMeaning: "showing variety; different", partOfSpeech: .adjective, example: "Our society is diverse.", exampleBangla: "আমাদের সমাজ বৈচিত্র্যপূর্ণ।", category: .society, icon: "person.2.circle.fill", grammarTip: "Noun: 'diversity'", synonyms: ["varied", "mixed", "multicultural"], collocations: ["culturally diverse", "diverse population"], difficulty: .intermediate),

        IELTSVocabWord(word: "integration", banglaMeaning: "একীকরণ", englishMeaning: "combining into one system", partOfSpeech: .noun, example: "Social integration takes time.", exampleBangla: "সামাজিক একীকরণে সময় লাগে।", category: .society, icon: "square.grid.3x3.fill", grammarTip: "Verb: 'integrate'", synonyms: ["unification", "inclusion", "assimilation"], collocations: ["social integration", "economic integration"], difficulty: .intermediate),

        IELTSVocabWord(word: "welfare", banglaMeaning: "কল্যাণ / সুখ-সমৃদ্ধি", englishMeaning: "health and happiness; government help", partOfSpeech: .noun, example: "Social welfare programs help the poor.", exampleBangla: "সামাজিক কল্যাণ কর্মসূচি দরিদ্রদের সাহায্য করে।", category: .society, icon: "hand.raised.circle.fill", grammarTip: "Two meanings: wellbeing OR government aid", synonyms: ["wellbeing", "benefits", "aid"], collocations: ["social welfare", "welfare state"], difficulty: .intermediate),

        IELTSVocabWord(word: "stereotype", banglaMeaning: "গতানুগতিক ধারণা", englishMeaning: "oversimplified image of group", partOfSpeech: .noun, example: "We should challenge stereotypes.", exampleBangla: "আমাদের গতানুগতিক ধারণাকে চ্যালেঞ্জ করা উচিত।", category: .society, icon: "person.fill.questionmark", grammarTip: "Verb: 'stereotype'", synonyms: ["generalization", "cliché", "prejudice"], collocations: ["gender stereotype", "challenge stereotypes"], difficulty: .intermediate),

        IELTSVocabWord(word: "minority", banglaMeaning: "সংখ্যালঘু", englishMeaning: "smaller group in population", partOfSpeech: .noun, example: "Minorities deserve equal rights.", exampleBangla: "সংখ্যালঘুরা সমান অধিকার প্রাপ্য।", category: .society, icon: "person.2.fill", grammarTip: "Opposite: 'majority'", synonyms: ["smaller group"], collocations: ["ethnic minority", "minority rights"], difficulty: .intermediate),

        IELTSVocabWord(word: "majority", banglaMeaning: "সংখ্যাগরিষ্ঠ", englishMeaning: "larger group; more than half", partOfSpeech: .noun, example: "The majority agreed.", exampleBangla: "সংখ্যাগরিষ্ঠ একমত হয়েছে।", category: .society, icon: "person.3.fill", grammarTip: "Use: 'the majority of'", synonyms: ["most", "greater part"], collocations: ["vast majority", "majority of people"], difficulty: .beginner),

        IELTSVocabWord(word: "elderly", banglaMeaning: "বয়স্ক", englishMeaning: "old people", partOfSpeech: .adjective, example: "The elderly need care.", exampleBangla: "বয়স্কদের যত্ন দরকার।", category: .society, icon: "figure.walk.circle.fill", grammarTip: "More polite than 'old'", synonyms: ["old", "senior", "aged"], collocations: ["elderly people", "care for the elderly"], difficulty: .beginner),

        // ==========================================
        // MARK: - MORE HEALTH WORDS (15 more)
        // ==========================================

        IELTSVocabWord(word: "chronic", banglaMeaning: "দীর্ঘস্থায়ী", englishMeaning: "lasting for a long time", partOfSpeech: .adjective, example: "Chronic diseases are increasing.", exampleBangla: "দীর্ঘস্থায়ী রোগ বাড়ছে।", category: .health, icon: "clock.badge.exclamationmark.fill", grammarTip: "Opposite: 'acute'", synonyms: ["long-term", "persistent", "ongoing"], collocations: ["chronic disease", "chronic illness"], difficulty: .intermediate),

        IELTSVocabWord(word: "symptom", banglaMeaning: "লক্ষণ", englishMeaning: "sign of illness", partOfSpeech: .noun, example: "Fever is a common symptom.", exampleBangla: "জ্বর একটি সাধারণ লক্ষণ।", category: .health, icon: "staroflife.fill", grammarTip: "Adjective: 'symptomatic'", synonyms: ["sign", "indication", "indicator"], collocations: ["common symptom", "symptoms of"], difficulty: .intermediate),

        IELTSVocabWord(word: "diagnosis", banglaMeaning: "রোগ নির্ণয়", englishMeaning: "identification of illness", partOfSpeech: .noun, example: "Early diagnosis saves lives.", exampleBangla: "প্রাথমিক রোগ নির্ণয় জীবন বাঁচায়।", category: .health, icon: "stethoscope", grammarTip: "Verb: 'diagnose'", synonyms: ["identification", "detection"], collocations: ["early diagnosis", "make a diagnosis"], difficulty: .intermediate),

        IELTSVocabWord(word: "treatment", banglaMeaning: "চিকিৎসা", englishMeaning: "medical care for illness", partOfSpeech: .noun, example: "Treatment is expensive.", exampleBangla: "চিকিৎসা ব্যয়বহুল।", category: .health, icon: "pills.fill", grammarTip: "Verb: 'treat'", synonyms: ["therapy", "care", "medication"], collocations: ["medical treatment", "receive treatment"], difficulty: .beginner),

        IELTSVocabWord(word: "prevention", banglaMeaning: "প্রতিরোধ", englishMeaning: "stopping something from happening", partOfSpeech: .noun, example: "Prevention is better than cure.", exampleBangla: "প্রতিকারের চেয়ে প্রতিরোধ ভালো।", category: .health, icon: "shield.checkered", grammarTip: "Verb: 'prevent'", synonyms: ["avoidance", "precaution"], collocations: ["disease prevention", "prevention is better"], difficulty: .intermediate),

        IELTSVocabWord(word: "vaccination", banglaMeaning: "টিকা", englishMeaning: "injection to prevent disease", partOfSpeech: .noun, example: "Vaccination prevents diseases.", exampleBangla: "টিকা রোগ প্রতিরোধ করে।", category: .health, icon: "syringe.fill", grammarTip: "Verb: 'vaccinate'", synonyms: ["immunization", "inoculation"], collocations: ["vaccination program", "childhood vaccination"], difficulty: .intermediate),

        IELTSVocabWord(word: "healthcare", banglaMeaning: "স্বাস্থ্যসেবা", englishMeaning: "medical services", partOfSpeech: .noun, example: "Healthcare should be free.", exampleBangla: "স্বাস্থ্যসেবা বিনামূল্যে হওয়া উচিত।", category: .health, icon: "cross.case.fill", grammarTip: "Also: 'health care'", synonyms: ["medical care", "health services"], collocations: ["healthcare system", "healthcare costs"], difficulty: .beginner),

        IELTSVocabWord(word: "contagious", banglaMeaning: "সংক্রামক", englishMeaning: "spreading by contact", partOfSpeech: .adjective, example: "The disease is highly contagious.", exampleBangla: "রোগটি অত্যন্ত সংক্রামক।", category: .health, icon: "allergens.fill", grammarTip: "Similar: 'infectious'", synonyms: ["infectious", "transmissible", "catching"], collocations: ["highly contagious", "contagious disease"], difficulty: .intermediate),

        IELTSVocabWord(word: "immune", banglaMeaning: "প্রতিরোধ ক্ষমতাসম্পন্ন", englishMeaning: "protected against disease", partOfSpeech: .adjective, example: "Vaccines make us immune.", exampleBangla: "টিকা আমাদের প্রতিরোধ ক্ষমতা দেয়।", category: .health, icon: "shield.fill", grammarTip: "Noun: 'immunity'", synonyms: ["resistant", "protected"], collocations: ["immune system", "become immune"], difficulty: .intermediate),

        IELTSVocabWord(word: "addiction", banglaMeaning: "আসক্তি", englishMeaning: "inability to stop doing something", partOfSpeech: .noun, example: "Phone addiction is a problem.", exampleBangla: "ফোনে আসক্তি একটি সমস্যা।", category: .health, icon: "exclamationmark.bubble.fill", grammarTip: "Adjective: 'addictive'", synonyms: ["dependence", "habit", "compulsion"], collocations: ["drug addiction", "addiction to"], difficulty: .intermediate),

        // ==========================================
        // MARK: - MORE ENVIRONMENT WORDS (15 more)
        // ==========================================

        IELTSVocabWord(word: "habitat", banglaMeaning: "বাসস্থান", englishMeaning: "natural home of animal/plant", partOfSpeech: .noun, example: "Forests are natural habitats.", exampleBangla: "বন প্রাকৃতিক বাসস্থান।", category: .environment, icon: "tree.fill", grammarTip: "Related: 'habitant'", synonyms: ["home", "environment", "territory"], collocations: ["natural habitat", "habitat loss"], difficulty: .intermediate),

        IELTSVocabWord(word: "extinct", banglaMeaning: "বিলুপ্ত", englishMeaning: "no longer existing", partOfSpeech: .adjective, example: "Dinosaurs are extinct.", exampleBangla: "ডাইনোসর বিলুপ্ত।", category: .environment, icon: "xmark.diamond.fill", grammarTip: "Noun: 'extinction'", synonyms: ["wiped out", "died out", "vanished"], collocations: ["become extinct", "extinct species"], difficulty: .intermediate),

        IELTSVocabWord(word: "recycle", banglaMeaning: "পুনর্ব্যবহার করা", englishMeaning: "to use materials again", partOfSpeech: .verb, example: "We should recycle plastic.", exampleBangla: "আমাদের প্লাস্টিক পুনর্ব্যবহার করা উচিত।", category: .environment, icon: "arrow.3.trianglepath", grammarTip: "Noun: 'recycling'", synonyms: ["reuse", "reprocess"], collocations: ["recycle waste", "recycling center"], difficulty: .beginner),

        IELTSVocabWord(word: "carbon footprint", banglaMeaning: "কার্বন পদচিহ্ন", englishMeaning: "amount of CO2 produced", partOfSpeech: .phrase, example: "Reduce your carbon footprint.", exampleBangla: "আপনার কার্বন পদচিহ্ন কমান।", category: .environment, icon: "shoe.fill", grammarTip: "Environmental term", synonyms: ["carbon emissions", "environmental impact"], collocations: ["reduce carbon footprint", "large carbon footprint"], difficulty: .intermediate),

        IELTSVocabWord(word: "ozone layer", banglaMeaning: "ওজন স্তর", englishMeaning: "protective layer in atmosphere", partOfSpeech: .phrase, example: "The ozone layer protects us.", exampleBangla: "ওজন স্তর আমাদের রক্ষা করে।", category: .environment, icon: "cloud.sun.fill", grammarTip: "Related: 'ozone depletion'", synonyms: ["ozone shield"], collocations: ["ozone layer depletion", "protect the ozone layer"], difficulty: .intermediate),

        IELTSVocabWord(word: "greenhouse effect", banglaMeaning: "গ্রীনহাউস প্রভাব", englishMeaning: "warming caused by trapped gases", partOfSpeech: .phrase, example: "The greenhouse effect causes warming.", exampleBangla: "গ্রীনহাউস প্রভাব উষ্ণায়ন ঘটায়।", category: .environment, icon: "thermometer.high", grammarTip: "Related: 'greenhouse gases'", synonyms: ["global warming"], collocations: ["greenhouse gases", "greenhouse effect"], difficulty: .intermediate),

        IELTSVocabWord(word: "contamination", banglaMeaning: "দূষণ / সংক্রমণ", englishMeaning: "making something impure", partOfSpeech: .noun, example: "Water contamination is dangerous.", exampleBangla: "পানি দূষণ বিপজ্জনক।", category: .environment, icon: "drop.triangle.fill", grammarTip: "Verb: 'contaminate'", synonyms: ["pollution", "impurity"], collocations: ["water contamination", "soil contamination"], difficulty: .intermediate),

        IELTSVocabWord(word: "preservation", banglaMeaning: "সংরক্ষণ", englishMeaning: "keeping something safe", partOfSpeech: .noun, example: "Wildlife preservation is vital.", exampleBangla: "বন্যপ্রাণী সংরক্ষণ অত্যাবশ্যক।", category: .environment, icon: "hand.raised.square.on.square.fill", grammarTip: "Verb: 'preserve'", synonyms: ["conservation", "protection", "maintenance"], collocations: ["preservation of", "wildlife preservation"], difficulty: .intermediate),

        IELTSVocabWord(word: "waste", banglaMeaning: "বর্জ্য / অপচয়", englishMeaning: "unwanted materials", partOfSpeech: .noun, example: "Waste management is important.", exampleBangla: "বর্জ্য ব্যবস্থাপনা গুরুত্বপূর্ণ।", category: .environment, icon: "trash.fill", grammarTip: "Can be verb or noun", synonyms: ["garbage", "refuse", "rubbish"], collocations: ["waste management", "waste disposal"], difficulty: .beginner),

        IELTSVocabWord(word: "drought", banglaMeaning: "খরা", englishMeaning: "long period without rain", partOfSpeech: .noun, example: "Drought affects agriculture.", exampleBangla: "খরা কৃষিকে প্রভাবিত করে।", category: .environment, icon: "sun.max.trianglebadge.exclamationmark", grammarTip: "Pronounced 'drowt'", synonyms: ["dry spell", "water shortage"], collocations: ["severe drought", "drought conditions"], difficulty: .intermediate),

        // ==========================================
        // MARK: - MORE LINKING/TRANSITION WORDS (20 more)
        // ==========================================

        IELTSVocabWord(word: "likewise", banglaMeaning: "একইভাবে", englishMeaning: "in the same way", partOfSpeech: .adverb, example: "She is smart. Likewise, her brother.", exampleBangla: "সে স্মার্ট। একইভাবে, তার ভাই।", category: .linking, icon: "equal.circle.fill", grammarTip: "Shows similarity", synonyms: ["similarly", "in the same way"], collocations: ["likewise, the", "and likewise"], difficulty: .intermediate),

        IELTSVocabWord(word: "similarly", banglaMeaning: "একইভাবে", englishMeaning: "in a similar way", partOfSpeech: .adverb, example: "Similarly, other countries face this.", exampleBangla: "একইভাবে, অন্য দেশগুলোও এর সম্মুখীন।", category: .linking, icon: "equal.square.fill", grammarTip: "Use to compare similar things", synonyms: ["likewise", "in the same way"], collocations: ["similarly, the", "similarly situated"], difficulty: .intermediate),

        IELTSVocabWord(word: "alternatively", banglaMeaning: "বিকল্পভাবে", englishMeaning: "as another option", partOfSpeech: .adverb, example: "Alternatively, we could walk.", exampleBangla: "বিকল্পভাবে, আমরা হাঁটতে পারি।", category: .linking, icon: "arrow.triangle.branch", grammarTip: "Use to give options", synonyms: ["instead", "on the other hand"], collocations: ["alternatively, you could"], difficulty: .intermediate),

        IELTSVocabWord(word: "in particular", banglaMeaning: "বিশেষভাবে", englishMeaning: "especially; specifically", partOfSpeech: .phrase, example: "Vegetables, in particular carrots, are healthy.", exampleBangla: "সবজি, বিশেষভাবে গাজর, স্বাস্থ্যকর।", category: .linking, icon: "scope", grammarTip: "Use to specify", synonyms: ["especially", "particularly", "specifically"], collocations: ["in particular, the"], difficulty: .intermediate),

        IELTSVocabWord(word: "specifically", banglaMeaning: "বিশেষভাবে", englishMeaning: "in a precise way", partOfSpeech: .adverb, example: "Specifically, I mean the cost.", exampleBangla: "বিশেষভাবে, আমি খরচের কথা বলছি।", category: .linking, icon: "target", grammarTip: "Use to be exact", synonyms: ["particularly", "precisely"], collocations: ["more specifically", "specifically, the"], difficulty: .intermediate),

        IELTSVocabWord(word: "indeed", banglaMeaning: "প্রকৃতপক্ষে", englishMeaning: "in fact; truly", partOfSpeech: .adverb, example: "Indeed, the results confirm this.", exampleBangla: "প্রকৃতপক্ষে, ফলাফল এটি নিশ্চিত করে।", category: .linking, icon: "checkmark.circle.fill", grammarTip: "Strengthens previous statement", synonyms: ["in fact", "truly", "certainly"], collocations: ["indeed, it is", "very much indeed"], difficulty: .intermediate),

        IELTSVocabWord(word: "notably", banglaMeaning: "উল্লেখযোগ্যভাবে", englishMeaning: "especially; in particular", partOfSpeech: .adverb, example: "Many countries, notably China, grew fast.", exampleBangla: "অনেক দেশ, উল্লেখযোগ্যভাবে চীন, দ্রুত বেড়েছে।", category: .linking, icon: "star.fill", grammarTip: "Use to highlight", synonyms: ["particularly", "especially"], collocations: ["most notably", "notably, the"], difficulty: .advanced),

        IELTSVocabWord(word: "assuming that", banglaMeaning: "ধরে নিলে যে", englishMeaning: "if we accept that", partOfSpeech: .phrase, example: "Assuming that this is true, we should act.", exampleBangla: "ধরে নিলে যে এটি সত্য, আমাদের কাজ করা উচিত।", category: .linking, icon: "questionmark.diamond.fill", grammarTip: "Use for hypothetical situations", synonyms: ["if", "provided that"], collocations: ["assuming that the"], difficulty: .intermediate),

        IELTSVocabWord(word: "provided that", banglaMeaning: "শর্তে যে", englishMeaning: "only if; on condition that", partOfSpeech: .phrase, example: "I'll help, provided that you pay.", exampleBangla: "আমি সাহায্য করব, শর্তে যে তুমি দেবে।", category: .linking, icon: "checkmark.rectangle.fill", grammarTip: "More formal than 'if'", synonyms: ["if", "as long as", "on condition that"], collocations: ["provided that the"], difficulty: .intermediate),

        IELTSVocabWord(word: "given that", banglaMeaning: "যেহেতু", englishMeaning: "considering the fact that", partOfSpeech: .phrase, example: "Given that time is limited, let's start.", exampleBangla: "যেহেতু সময় সীমিত, চলুন শুরু করি।", category: .linking, icon: "arrow.right.circle.fill", grammarTip: "Use to state a known fact", synonyms: ["considering that", "since"], collocations: ["given that the"], difficulty: .intermediate),

        IELTSVocabWord(word: "in other words", banglaMeaning: "অন্য কথায়", englishMeaning: "to explain differently", partOfSpeech: .phrase, example: "In other words, we failed.", exampleBangla: "অন্য কথায়, আমরা ব্যর্থ হয়েছি।", category: .linking, icon: "arrow.triangle.2.circlepath.circle.fill", grammarTip: "Use to rephrase/clarify", synonyms: ["that is", "to put it differently"], collocations: ["in other words, the"], difficulty: .beginner),

        IELTSVocabWord(word: "in terms of", banglaMeaning: "বিষয়ে / ক্ষেত্রে", englishMeaning: "with respect to", partOfSpeech: .phrase, example: "In terms of cost, it's affordable.", exampleBangla: "খরচের ক্ষেত্রে, এটি সাশ্রয়ী।", category: .linking, icon: "text.magnifyingglass", grammarTip: "Use to specify aspect", synonyms: ["regarding", "with respect to"], collocations: ["in terms of the"], difficulty: .intermediate),

        IELTSVocabWord(word: "with regard to", banglaMeaning: "সম্পর্কে", englishMeaning: "concerning; about", partOfSpeech: .phrase, example: "With regard to your question, yes.", exampleBangla: "আপনার প্রশ্ন সম্পর্কে, হ্যাঁ।", category: .linking, icon: "text.badge.plus", grammarTip: "Formal phrase", synonyms: ["regarding", "concerning", "about"], collocations: ["with regard to the"], difficulty: .intermediate),

        IELTSVocabWord(word: "as far as", banglaMeaning: "যতদূর পর্যন্ত", englishMeaning: "to the extent that", partOfSpeech: .phrase, example: "As far as I know, it's true.", exampleBangla: "যতদূর আমি জানি, এটা সত্য।", category: .linking, icon: "arrow.right.to.line.alt", grammarTip: "Often: 'as far as X is concerned'", synonyms: ["to the extent that"], collocations: ["as far as I know", "as far as concerned"], difficulty: .intermediate),

        IELTSVocabWord(word: "above all", banglaMeaning: "সবচেয়ে গুরুত্বপূর্ণ", englishMeaning: "most importantly", partOfSpeech: .phrase, example: "Above all, be honest.", exampleBangla: "সবচেয়ে গুরুত্বপূর্ণ, সৎ থাকুন।", category: .linking, icon: "arrow.up.circle.fill", grammarTip: "Use for emphasis", synonyms: ["most importantly", "primarily"], collocations: ["above all, the"], difficulty: .intermediate),

        // ==========================================
        // MARK: - COMMON VERBS FOR WRITING (15 words)
        // ==========================================

        IELTSVocabWord(word: "illustrate", banglaMeaning: "চিত্রিত করা / দেখানো", englishMeaning: "to show or explain clearly", partOfSpeech: .verb, example: "The graph illustrates the trend.", exampleBangla: "গ্রাফটি প্রবণতা চিত্রিত করে।", category: .academic, icon: "chart.xyaxis.line", grammarTip: "Noun: 'illustration'", synonyms: ["show", "demonstrate", "depict"], collocations: ["illustrate the point", "clearly illustrates"], difficulty: .intermediate),

        IELTSVocabWord(word: "demonstrate", banglaMeaning: "প্রদর্শন করা", englishMeaning: "to show clearly", partOfSpeech: .verb, example: "Research demonstrates this.", exampleBangla: "গবেষণা এটি প্রদর্শন করে।", category: .academic, icon: "hand.point.up.fill", grammarTip: "Noun: 'demonstration'", synonyms: ["show", "prove", "indicate"], collocations: ["demonstrate that", "clearly demonstrates"], difficulty: .intermediate),

        IELTSVocabWord(word: "indicate", banglaMeaning: "নির্দেশ করা", englishMeaning: "to show or point out", partOfSpeech: .verb, example: "Studies indicate that...", exampleBangla: "গবেষণা নির্দেশ করে যে...", category: .academic, icon: "hand.point.right.fill", grammarTip: "Noun: 'indication'", synonyms: ["show", "suggest", "point to"], collocations: ["indicate that", "as indicated"], difficulty: .intermediate),

        IELTSVocabWord(word: "reveal", banglaMeaning: "প্রকাশ করা", englishMeaning: "to make known", partOfSpeech: .verb, example: "The data reveals problems.", exampleBangla: "তথ্য সমস্যা প্রকাশ করে।", category: .academic, icon: "eye.trianglebadge.exclamationmark.fill", grammarTip: "Noun: 'revelation'", synonyms: ["show", "disclose", "uncover"], collocations: ["reveal that", "findings reveal"], difficulty: .intermediate),

        IELTSVocabWord(word: "emphasize", banglaMeaning: "জোর দেওয়া", englishMeaning: "to stress importance", partOfSpeech: .verb, example: "I must emphasize this point.", exampleBangla: "আমাকে এই বিষয়ে জোর দিতে হবে।", category: .academic, icon: "exclamationmark.3", grammarTip: "Noun: 'emphasis'", synonyms: ["stress", "highlight", "underline"], collocations: ["emphasize the importance", "should be emphasized"], difficulty: .intermediate),

        IELTSVocabWord(word: "highlight", banglaMeaning: "তুলে ধরা", englishMeaning: "to draw attention to", partOfSpeech: .verb, example: "The report highlights problems.", exampleBangla: "প্রতিবেদনটি সমস্যা তুলে ধরে।", category: .academic, icon: "highlighter", grammarTip: "Can be noun or verb", synonyms: ["emphasize", "stress", "point out"], collocations: ["highlight the need", "highlight the importance"], difficulty: .beginner),

        IELTSVocabWord(word: "analyze", banglaMeaning: "বিশ্লেষণ করা", englishMeaning: "to examine in detail", partOfSpeech: .verb, example: "We analyzed the data.", exampleBangla: "আমরা তথ্য বিশ্লেষণ করেছি।", category: .academic, icon: "chart.bar.doc.horizontal.fill", grammarTip: "Noun: 'analysis'", synonyms: ["examine", "study", "investigate"], collocations: ["analyze data", "carefully analyzed"], difficulty: .intermediate),

        IELTSVocabWord(word: "evaluate", banglaMeaning: "মূল্যায়ন করা", englishMeaning: "to assess or judge", partOfSpeech: .verb, example: "We need to evaluate the results.", exampleBangla: "আমাদের ফলাফল মূল্যায়ন করতে হবে।", category: .academic, icon: "checkmark.seal.fill", grammarTip: "Noun: 'evaluation'", synonyms: ["assess", "judge", "appraise"], collocations: ["evaluate the effectiveness", "critically evaluate"], difficulty: .intermediate),

        IELTSVocabWord(word: "establish", banglaMeaning: "প্রতিষ্ঠা করা", englishMeaning: "to set up or prove", partOfSpeech: .verb, example: "The research establishes that...", exampleBangla: "গবেষণা প্রতিষ্ঠা করে যে...", category: .academic, icon: "building.2.fill", grammarTip: "Noun: 'establishment'", synonyms: ["set up", "prove", "create"], collocations: ["establish a link", "firmly established"], difficulty: .intermediate),

        IELTSVocabWord(word: "assume", banglaMeaning: "ধরে নেওয়া", englishMeaning: "to suppose without proof", partOfSpeech: .verb, example: "We assume this is correct.", exampleBangla: "আমরা ধরে নিই এটা সঠিক।", category: .academic, icon: "questionmark.circle.fill", grammarTip: "Noun: 'assumption'", synonyms: ["suppose", "presume", "believe"], collocations: ["assume that", "it is assumed"], difficulty: .intermediate),

        IELTSVocabWord(word: "maintain", banglaMeaning: "বজায় রাখা / দাবি করা", englishMeaning: "to continue; to claim", partOfSpeech: .verb, example: "Some maintain that...", exampleBangla: "কেউ কেউ দাবি করে যে...", category: .academic, icon: "rectangle.and.text.magnifyingglass", grammarTip: "Two meanings: keep OR claim", synonyms: ["keep", "assert", "claim"], collocations: ["maintain that", "maintain the position"], difficulty: .intermediate),

        IELTSVocabWord(word: "interpret", banglaMeaning: "ব্যাখ্যা করা", englishMeaning: "to explain meaning", partOfSpeech: .verb, example: "How do you interpret this?", exampleBangla: "আপনি এটি কীভাবে ব্যাখ্যা করেন?", category: .academic, icon: "doc.text.magnifyingglass", grammarTip: "Noun: 'interpretation'", synonyms: ["explain", "understand", "read"], collocations: ["interpret data", "interpreted as"], difficulty: .intermediate),

        IELTSVocabWord(word: "conclude", banglaMeaning: "উপসংহার টানা", englishMeaning: "to end; to decide", partOfSpeech: .verb, example: "We can conclude that...", exampleBangla: "আমরা উপসংহার টানতে পারি যে...", category: .academic, icon: "flag.checkered", grammarTip: "Noun: 'conclusion'", synonyms: ["end", "finish", "determine"], collocations: ["conclude that", "it can be concluded"], difficulty: .beginner),

        IELTSVocabWord(word: "define", banglaMeaning: "সংজ্ঞায়িত করা", englishMeaning: "to explain the meaning", partOfSpeech: .verb, example: "How do we define success?", exampleBangla: "সাফল্যকে আমরা কীভাবে সংজ্ঞায়িত করি?", category: .academic, icon: "text.book.closed.fill", grammarTip: "Noun: 'definition'", synonyms: ["explain", "describe", "specify"], collocations: ["define the term", "clearly defined"], difficulty: .beginner),

        IELTSVocabWord(word: "consider", banglaMeaning: "বিবেচনা করা", englishMeaning: "to think carefully about", partOfSpeech: .verb, example: "We should consider all options.", exampleBangla: "আমাদের সব বিকল্প বিবেচনা করা উচিত।", category: .academic, icon: "brain.head.profile.fill", grammarTip: "Noun: 'consideration'", synonyms: ["think about", "examine", "contemplate"], collocations: ["consider the following", "carefully consider"], difficulty: .beginner),
    ]
}
