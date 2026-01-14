import Foundation

// MARK: - Lesson Types
enum LessonCategory: String, CaseIterable {
    case reading = "Reading"
    case writing = "Writing"
    case listening = "Listening"
    case speaking = "Speaking"
    case grammar = "Grammar"

    var icon: String {
        switch self {
        case .reading: return "book.fill"
        case .writing: return "pencil.and.outline"
        case .listening: return "headphones"
        case .speaking: return "mic.fill"
        case .grammar: return "text.badge.checkmark"
        }
    }

    var color: String {
        switch self {
        case .reading: return "green"
        case .writing: return "orange"
        case .listening: return "pink"
        case .speaking: return "red"
        case .grammar: return "blue"
        }
    }
}

// MARK: - Reading Lessons
struct ReadingPassage: Identifiable {
    let id = UUID()
    let title: String
    let difficulty: String // Easy, Medium, Hard
    let passage: String
    let questions: [ReadingQuestion]
    let tips: [String]
}

struct ReadingQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
}

// MARK: - Grammar Lessons
struct GrammarLesson: Identifiable {
    let id = UUID()
    let title: String
    let explanation: String
    let examples: [GrammarExample]
    let exercises: [GrammarExercise]
    let tips: [String]
}

struct GrammarExample: Identifiable {
    let id = UUID()
    let incorrect: String
    let correct: String
    let rule: String
}

struct GrammarExercise: Identifiable {
    let id = UUID()
    let sentence: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
}

// MARK: - Writing Lessons
struct WritingLesson: Identifiable {
    let id = UUID()
    let title: String
    let type: String // Task 1 or Task 2
    let explanation: String
    let structure: [String]
    let sampleQuestion: String
    let sampleAnswer: String
    let vocabularyList: [String]
    let tips: [String]
}

// MARK: - Speaking Lessons
struct SpeakingLesson: Identifiable {
    let id = UUID()
    let part: Int // Part 1, 2, or 3
    let topic: String
    let questions: [String]
    let sampleAnswers: [String]
    let vocabularyList: [String]
    let tips: [String]
}

// MARK: - Listening Lessons
struct ListeningLesson: Identifiable {
    let id = UUID()
    let title: String
    let section: Int // Section 1-4
    let transcript: String
    let questions: [ListeningQuestion]
    let tips: [String]
}

struct ListeningQuestion: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let questionType: String // Fill blank, MCQ, Matching
}

// MARK: - All Lesson Content
struct LessonsContent {

    // MARK: - Reading Passages
    static let readingPassages: [ReadingPassage] = [
        ReadingPassage(
            title: "Climate Change and Its Effects",
            difficulty: "Medium",
            passage: """
            Climate change represents one of the most significant challenges facing humanity in the 21st century. The Earth's average temperature has risen by approximately 1.1 degrees Celsius since the pre-industrial era, primarily due to human activities such as burning fossil fuels, deforestation, and industrial processes.

            The consequences of this warming are far-reaching and increasingly evident. Glaciers and ice sheets are melting at unprecedented rates, contributing to rising sea levels that threaten coastal communities worldwide. Weather patterns have become more erratic, with many regions experiencing more frequent and intense storms, droughts, and heatwaves.

            Scientists have observed that the Arctic is warming at nearly twice the global average rate, a phenomenon known as Arctic amplification. This rapid warming is causing permafrost to thaw, potentially releasing vast amounts of methane—a greenhouse gas far more potent than carbon dioxide—into the atmosphere.

            The impact on biodiversity has been equally concerning. Many species are struggling to adapt to changing conditions, with some facing extinction. Coral reefs, often called the rainforests of the sea, are experiencing mass bleaching events due to warmer ocean temperatures.

            However, there is growing momentum for action. The Paris Agreement, signed by 196 countries, aims to limit global warming to 1.5 degrees Celsius above pre-industrial levels. Many nations are transitioning to renewable energy sources, implementing carbon pricing mechanisms, and investing in green technologies.

            Individual actions also play a crucial role. Reducing energy consumption, choosing sustainable transportation options, and supporting environmentally responsible businesses can collectively make a significant difference. The challenge of climate change, while daunting, presents an opportunity for innovation and cooperation on a global scale.
            """,
            questions: [
                ReadingQuestion(
                    question: "According to the passage, what is the primary cause of rising global temperatures?",
                    options: [
                        "Natural climate cycles",
                        "Human activities like burning fossil fuels",
                        "Volcanic eruptions",
                        "Solar radiation changes"
                    ],
                    correctAnswer: 1,
                    explanation: "The passage states that the temperature rise is 'primarily due to human activities such as burning fossil fuels, deforestation, and industrial processes.'"
                ),
                ReadingQuestion(
                    question: "What is 'Arctic amplification' as mentioned in the passage?",
                    options: [
                        "The Arctic cooling faster than other regions",
                        "The Arctic warming at nearly twice the global average rate",
                        "Increased ice formation in the Arctic",
                        "Arctic wildlife population growth"
                    ],
                    correctAnswer: 1,
                    explanation: "The passage defines Arctic amplification as 'the Arctic warming at nearly twice the global average rate.'"
                ),
                ReadingQuestion(
                    question: "What is the goal of the Paris Agreement according to the passage?",
                    options: [
                        "To eliminate all carbon emissions immediately",
                        "To limit global warming to 1.5 degrees Celsius above pre-industrial levels",
                        "To increase renewable energy by 50%",
                        "To plant one billion trees worldwide"
                    ],
                    correctAnswer: 1,
                    explanation: "The passage states that the Paris Agreement 'aims to limit global warming to 1.5 degrees Celsius above pre-industrial levels.'"
                ),
                ReadingQuestion(
                    question: "Why are coral reefs experiencing mass bleaching events?",
                    options: [
                        "Overfishing",
                        "Plastic pollution",
                        "Warmer ocean temperatures",
                        "Acidic rain"
                    ],
                    correctAnswer: 2,
                    explanation: "The passage mentions that coral reefs 'are experiencing mass bleaching events due to warmer ocean temperatures.'"
                ),
                ReadingQuestion(
                    question: "What could happen when permafrost thaws?",
                    options: [
                        "It releases oxygen into the atmosphere",
                        "It releases methane, a potent greenhouse gas",
                        "It creates new farmland",
                        "It reduces sea levels"
                    ],
                    correctAnswer: 1,
                    explanation: "The passage states that thawing permafrost could 'potentially release vast amounts of methane—a greenhouse gas far more potent than carbon dioxide—into the atmosphere.'"
                )
            ],
            tips: [
                "Skim the passage first to get the main idea before reading questions",
                "Look for keywords in questions and find them in the passage",
                "Pay attention to transition words like 'however', 'therefore', 'because'",
                "Don't spend more than 20 minutes on one passage"
            ]
        ),

        ReadingPassage(
            title: "The Rise of Artificial Intelligence",
            difficulty: "Hard",
            passage: """
            Artificial Intelligence (AI) has transitioned from the realm of science fiction to an integral part of modern life. From virtual assistants on smartphones to sophisticated algorithms that power recommendation systems, AI technologies are reshaping how we live, work, and interact with the world around us.

            The field of AI encompasses several subdomains, including machine learning, natural language processing, computer vision, and robotics. Machine learning, perhaps the most influential of these, enables computers to learn from data and improve their performance over time without being explicitly programmed for every task.

            Deep learning, a subset of machine learning inspired by the structure of the human brain, has achieved remarkable breakthroughs in recent years. Neural networks with multiple layers can now recognize speech, translate languages, diagnose diseases from medical images, and even create art and music.

            The economic implications of AI are substantial. According to various estimates, AI could contribute up to $15.7 trillion to the global economy by 2030. Industries from healthcare to finance, manufacturing to agriculture, are being transformed by AI-driven innovations that increase efficiency, reduce costs, and enable new capabilities.

            However, the rapid advancement of AI also raises important ethical and societal questions. Concerns about job displacement are widespread, as automation threatens to render many traditional occupations obsolete. There are also pressing issues related to algorithmic bias, privacy, and the potential misuse of AI technologies.

            The question of AI governance has become increasingly urgent. Policymakers, technologists, and ethicists are grappling with how to ensure that AI development proceeds in ways that benefit humanity while minimizing potential harms. Proposals range from industry self-regulation to comprehensive government oversight.

            Despite these challenges, many experts remain optimistic about AI's potential to address some of humanity's most pressing problems, from climate change to disease prevention. The key lies in developing AI responsibly, with careful attention to its social implications and a commitment to ensuring its benefits are widely shared.
            """,
            questions: [
                ReadingQuestion(
                    question: "What enables computers to learn from data without explicit programming?",
                    options: [
                        "Computer vision",
                        "Robotics",
                        "Machine learning",
                        "Virtual assistants"
                    ],
                    correctAnswer: 2,
                    explanation: "The passage states that 'Machine learning enables computers to learn from data and improve their performance over time without being explicitly programmed.'"
                ),
                ReadingQuestion(
                    question: "What is deep learning inspired by?",
                    options: [
                        "Computer algorithms",
                        "The structure of the human brain",
                        "Traditional programming",
                        "Statistical analysis"
                    ],
                    correctAnswer: 1,
                    explanation: "The passage mentions that 'Deep learning, a subset of machine learning inspired by the structure of the human brain.'"
                ),
                ReadingQuestion(
                    question: "How much could AI contribute to the global economy by 2030?",
                    options: [
                        "$5 trillion",
                        "$10 trillion",
                        "$15.7 trillion",
                        "$20 trillion"
                    ],
                    correctAnswer: 2,
                    explanation: "The passage states that 'AI could contribute up to $15.7 trillion to the global economy by 2030.'"
                ),
                ReadingQuestion(
                    question: "Which of the following is NOT mentioned as a concern about AI?",
                    options: [
                        "Job displacement",
                        "Algorithmic bias",
                        "Environmental damage",
                        "Privacy issues"
                    ],
                    correctAnswer: 2,
                    explanation: "Environmental damage is not mentioned. The passage discusses 'job displacement', 'algorithmic bias', and 'privacy' as concerns."
                ),
                ReadingQuestion(
                    question: "What do experts believe is key to AI's future benefit to humanity?",
                    options: [
                        "Faster development",
                        "Less government involvement",
                        "Developing AI responsibly with attention to social implications",
                        "Focusing only on economic benefits"
                    ],
                    correctAnswer: 2,
                    explanation: "The passage concludes that 'The key lies in developing AI responsibly, with careful attention to its social implications.'"
                )
            ],
            tips: [
                "For difficult passages, read the first and last paragraph first",
                "Underline key facts, numbers, and names",
                "If you don't know an answer, make an educated guess and move on",
                "Practice reading academic texts daily to improve speed"
            ]
        ),

        ReadingPassage(
            title: "The Psychology of Happiness",
            difficulty: "Easy",
            passage: """
            What makes people happy? This seemingly simple question has occupied philosophers for millennia and scientists for decades. Recent research in positive psychology has begun to provide some answers, revealing that happiness is more complex—and more achievable—than many people assume.

            Studies consistently show that once basic needs are met, additional wealth has diminishing returns on happiness. This phenomenon, known as the Easterlin Paradox, suggests that above a certain income threshold, more money does not significantly increase well-being. Instead, factors like relationships, purpose, and personal growth play more crucial roles.

            Social connections emerge as one of the strongest predictors of happiness. People with strong social ties—close friendships, supportive family relationships, and community involvement—tend to report higher levels of life satisfaction. Loneliness, conversely, is associated with depression, anxiety, and even physical health problems.

            Another key finding is the importance of gratitude. Research by psychologist Robert Emmons has shown that people who regularly practice gratitude—by keeping journals or expressing thanks to others—experience more positive emotions, sleep better, and feel more alive and connected.

            Physical activity also contributes significantly to happiness. Exercise releases endorphins, chemicals in the brain that act as natural mood elevators. Even moderate activity, such as a daily 30-minute walk, can reduce symptoms of depression and anxiety.

            Perhaps surprisingly, the pursuit of happiness itself can sometimes backfire. Studies suggest that people who place too much emphasis on being happy may actually become less happy over time. A more effective approach may be to focus on meaningful activities and let happiness emerge as a byproduct.

            The good news from happiness research is that well-being is not fixed. Through intentional practices—cultivating relationships, expressing gratitude, staying active, and pursuing meaningful goals—people can significantly increase their happiness levels over time.
            """,
            questions: [
                ReadingQuestion(
                    question: "What is the Easterlin Paradox?",
                    options: [
                        "Rich people are always happier",
                        "Above a certain income, more money doesn't significantly increase happiness",
                        "Poor people are happier than rich people",
                        "Money has no effect on happiness"
                    ],
                    correctAnswer: 1,
                    explanation: "The passage explains the Easterlin Paradox as the finding that 'above a certain income threshold, more money does not significantly increase well-being.'"
                ),
                ReadingQuestion(
                    question: "According to the passage, what is one of the strongest predictors of happiness?",
                    options: [
                        "Wealth",
                        "Intelligence",
                        "Social connections",
                        "Physical appearance"
                    ],
                    correctAnswer: 2,
                    explanation: "The passage states that 'Social connections emerge as one of the strongest predictors of happiness.'"
                ),
                ReadingQuestion(
                    question: "What did Robert Emmons' research show about gratitude?",
                    options: [
                        "Gratitude has no effect on happiness",
                        "People who practice gratitude experience more positive emotions",
                        "Gratitude only works for wealthy people",
                        "Gratitude causes stress"
                    ],
                    correctAnswer: 1,
                    explanation: "The passage mentions that 'people who regularly practice gratitude experience more positive emotions, sleep better, and feel more alive.'"
                ),
                ReadingQuestion(
                    question: "Why does exercise contribute to happiness?",
                    options: [
                        "It makes people look better",
                        "It releases endorphins that act as natural mood elevators",
                        "It helps people make money",
                        "It reduces the need for sleep"
                    ],
                    correctAnswer: 1,
                    explanation: "The passage explains that 'Exercise releases endorphins, chemicals in the brain that act as natural mood elevators.'"
                ),
                ReadingQuestion(
                    question: "What does the passage suggest about pursuing happiness directly?",
                    options: [
                        "It is the best approach",
                        "It always works",
                        "It can sometimes backfire",
                        "It is impossible"
                    ],
                    correctAnswer: 2,
                    explanation: "The passage states that 'the pursuit of happiness itself can sometimes backfire' and suggests focusing on meaningful activities instead."
                )
            ],
            tips: [
                "For True/False/Not Given questions, stick strictly to what the passage says",
                "Don't use your own knowledge—only use information from the passage",
                "Watch out for absolute words like 'always', 'never', 'all'",
                "Practice timing yourself—aim for 20 minutes per passage"
            ]
        )
    ]

    // MARK: - Grammar Lessons
    static let grammarLessons: [GrammarLesson] = [
        GrammarLesson(
            title: "Articles (A, An, The)",
            explanation: """
            Articles are small words that come before nouns. English has three articles: 'a', 'an', and 'the'.

            • 'A' is used before consonant sounds: a book, a university (sounds like 'yoo')
            • 'An' is used before vowel sounds: an apple, an hour (the 'h' is silent)
            • 'The' is used for specific things that both speaker and listener know about

            Common mistakes in IELTS:
            - Using 'the' with general concepts: "The education is important" ❌ → "Education is important" ✓
            - Missing articles with singular countable nouns: "I saw movie" ❌ → "I saw a movie" ✓
            """,
            examples: [
                GrammarExample(incorrect: "I want to be doctor.", correct: "I want to be a doctor.", rule: "Use 'a/an' before singular countable nouns when mentioning them for the first time."),
                GrammarExample(incorrect: "The life is beautiful.", correct: "Life is beautiful.", rule: "Don't use 'the' with abstract nouns used in a general sense."),
                GrammarExample(incorrect: "She goes to the university.", correct: "She goes to university.", rule: "Don't use 'the' with institutions when referring to their general purpose."),
                GrammarExample(incorrect: "I had a breakfast.", correct: "I had breakfast.", rule: "Don't use 'a/an' with meals unless you're describing them."),
                GrammarExample(incorrect: "Sun rises in east.", correct: "The sun rises in the east.", rule: "Use 'the' with unique things (sun, moon, earth) and directions.")
            ],
            exercises: [
                GrammarExercise(sentence: "I saw ___ elephant at the zoo.", options: ["a", "an", "the", "no article"], correctAnswer: 1, explanation: "'Elephant' starts with a vowel sound, so we use 'an'."),
                GrammarExercise(sentence: "___ water is essential for life.", options: ["A", "An", "The", "No article"], correctAnswer: 3, explanation: "When talking about water in general, no article is needed."),
                GrammarExercise(sentence: "She is ___ best student in class.", options: ["a", "an", "the", "no article"], correctAnswer: 2, explanation: "Use 'the' with superlatives like 'best', 'most', 'highest'."),
                GrammarExercise(sentence: "He plays ___ piano very well.", options: ["a", "an", "the", "no article"], correctAnswer: 2, explanation: "Use 'the' with musical instruments."),
                GrammarExercise(sentence: "I need ___ information about the course.", options: ["a", "an", "some", "the"], correctAnswer: 2, explanation: "'Information' is uncountable, so use 'some' not 'a/an'.")
            ],
            tips: [
                "Read English newspapers to see how articles are used naturally",
                "When in doubt with general statements, often no article is needed",
                "Remember: jobs always need 'a/an' - I am A teacher, She is AN engineer"
            ]
        ),

        GrammarLesson(
            title: "Subject-Verb Agreement",
            explanation: """
            The verb must agree with its subject in number (singular or plural).

            Basic Rules:
            • Singular subjects need singular verbs: He works, She plays, It runs
            • Plural subjects need plural verbs: They work, We play, Students run

            Tricky situations:
            • Collective nouns (team, family, government) can be singular or plural
            • Words like 'everyone', 'someone', 'nobody' are singular
            • 'The number of' is singular; 'A number of' is plural
            """,
            examples: [
                GrammarExample(incorrect: "The team are playing well.", correct: "The team is playing well.", rule: "In American English, collective nouns are usually singular."),
                GrammarExample(incorrect: "Everyone have their own opinion.", correct: "Everyone has their own opinion.", rule: "'Everyone' is singular and takes a singular verb."),
                GrammarExample(incorrect: "The news are shocking.", correct: "The news is shocking.", rule: "'News' is uncountable and takes a singular verb."),
                GrammarExample(incorrect: "A number of students was absent.", correct: "A number of students were absent.", rule: "'A number of' takes a plural verb."),
                GrammarExample(incorrect: "Neither the teacher nor the students was happy.", correct: "Neither the teacher nor the students were happy.", rule: "With 'neither...nor', the verb agrees with the nearest subject.")
            ],
            exercises: [
                GrammarExercise(sentence: "The quality of these products ___ excellent.", options: ["is", "are", "were", "being"], correctAnswer: 0, explanation: "The subject is 'quality' (singular), not 'products'."),
                GrammarExercise(sentence: "Mathematics ___ my favorite subject.", options: ["is", "are", "were", "be"], correctAnswer: 0, explanation: "Subjects ending in '-ics' like mathematics, physics are singular."),
                GrammarExercise(sentence: "The committee ___ their decision yesterday.", options: ["make", "makes", "made", "making"], correctAnswer: 2, explanation: "Past tense, and the committee acts as a unit making one decision."),
                GrammarExercise(sentence: "Each of the students ___ given a certificate.", options: ["was", "were", "are", "been"], correctAnswer: 0, explanation: "'Each' is always singular."),
                GrammarExercise(sentence: "Bread and butter ___ my usual breakfast.", options: ["is", "are", "were", "be"], correctAnswer: 0, explanation: "When items form a single unit/dish, use singular verb.")
            ],
            tips: [
                "Identify the true subject—ignore words between subject and verb",
                "Be careful with 'there is/are'—the subject comes after the verb",
                "Words like 'along with', 'as well as' don't change the subject number"
            ]
        ),

        GrammarLesson(
            title: "Tenses for IELTS",
            explanation: """
            Using the correct tense is crucial for IELTS Writing and Speaking.

            Key tenses you need:

            1. Present Simple: Facts, habits, general truths
               "Water boils at 100°C" / "I study every day"

            2. Present Perfect: Past action with present relevance
               "Technology has changed our lives" / "I have lived here for 5 years"

            3. Past Simple: Completed past actions
               "The industrial revolution began in Britain"

            4. Future forms: Predictions and plans
               "will" for predictions: "Population will increase"
               "going to" for plans: "I am going to study abroad"
            """,
            examples: [
                GrammarExample(incorrect: "I am living here since 2010.", correct: "I have lived here since 2010.", rule: "Use present perfect (not present continuous) with 'since' and 'for'."),
                GrammarExample(incorrect: "Yesterday I have seen a movie.", correct: "Yesterday I saw a movie.", rule: "Use past simple (not present perfect) with specific past time words."),
                GrammarExample(incorrect: "When I will arrive, I will call you.", correct: "When I arrive, I will call you.", rule: "Use present simple (not 'will') in time clauses after 'when', 'after', 'before'."),
                GrammarExample(incorrect: "I am knowing the answer.", correct: "I know the answer.", rule: "State verbs (know, believe, understand) don't use continuous form."),
                GrammarExample(incorrect: "The graph shows that sales increased since 2015.", correct: "The graph shows that sales have increased since 2015.", rule: "Use present perfect for changes that continue to the present.")
            ],
            exercises: [
                GrammarExercise(sentence: "The chart shows that unemployment ___ steadily since 2010.", options: ["rises", "rose", "has risen", "is rising"], correctAnswer: 2, explanation: "'Since 2010' indicates a period from past to present, requiring present perfect."),
                GrammarExercise(sentence: "By 2050, the world population ___ 10 billion.", options: ["reaches", "will reach", "reached", "has reached"], correctAnswer: 1, explanation: "Future prediction with specific future time requires 'will'."),
                GrammarExercise(sentence: "I ___ English for five years now.", options: ["study", "studied", "have studied", "am studying"], correctAnswer: 2, explanation: "'For five years' with 'now' indicates duration up to present."),
                GrammarExercise(sentence: "After I ___ my degree, I will look for a job.", options: ["finish", "will finish", "finished", "have finished"], correctAnswer: 0, explanation: "Use present simple in time clauses after 'after', 'when', 'before'."),
                GrammarExercise(sentence: "In 1990, only 20% of households ___ a computer.", options: ["own", "owns", "owned", "have owned"], correctAnswer: 2, explanation: "Specific past year (1990) requires past simple.")
            ],
            tips: [
                "In IELTS Writing Task 1, use past simple for past data, present perfect for trends continuing to now",
                "In Speaking, use a variety of tenses to show range",
                "Common error: Don't use present perfect with specific past times (yesterday, last week, in 2010)"
            ]
        ),

        GrammarLesson(
            title: "Complex Sentences",
            explanation: """
            Using complex sentences helps you achieve a higher band score in IELTS. Complex sentences contain an independent clause and at least one dependent clause.

            Types of complex sentences:

            1. With subordinating conjunctions:
               because, although, while, if, when, after, before, unless

            2. With relative clauses:
               who, which, that, where, whose

            3. With noun clauses:
               that, what, whether, how

            Example: "Although technology has many benefits, it also has some drawbacks."
            """,
            examples: [
                GrammarExample(incorrect: "Because I was tired. I went to bed early.", correct: "Because I was tired, I went to bed early.", rule: "A dependent clause cannot stand alone as a sentence."),
                GrammarExample(incorrect: "The book who I read was interesting.", correct: "The book that/which I read was interesting.", rule: "Use 'that/which' for things, 'who' for people."),
                GrammarExample(incorrect: "Despite of the rain, we went out.", correct: "Despite the rain, we went out.", rule: "'Despite' is not followed by 'of'. Use 'in spite of' if you want to use 'of'."),
                GrammarExample(incorrect: "I wonder that he will come.", correct: "I wonder whether/if he will come.", rule: "Use 'whether/if' (not 'that') after 'wonder' for yes/no questions."),
                GrammarExample(incorrect: "The reason is because he was late.", correct: "The reason is that he was late.", rule: "After 'reason is', use 'that' not 'because'.")
            ],
            exercises: [
                GrammarExercise(sentence: "___ the weather was bad, we enjoyed the trip.", options: ["Although", "Because", "Therefore", "However"], correctAnswer: 0, explanation: "'Although' shows contrast between bad weather and enjoying the trip."),
                GrammarExercise(sentence: "The city ___ I was born has changed a lot.", options: ["which", "where", "who", "what"], correctAnswer: 1, explanation: "Use 'where' for places."),
                GrammarExercise(sentence: "___ studying abroad is expensive, many students still choose to do it.", options: ["Despite", "Although", "However", "Because"], correctAnswer: 1, explanation: "'Although' introduces a contrast clause and is followed by a subject+verb."),
                GrammarExercise(sentence: "I'm not sure ___ I should accept the offer.", options: ["that", "whether", "what", "which"], correctAnswer: 1, explanation: "'Whether' is used for uncertainty about yes/no situations."),
                GrammarExercise(sentence: "The students, ___ had studied hard, passed the exam.", options: ["that", "who", "which", "whom"], correctAnswer: 1, explanation: "Use 'who' for people. Commas indicate non-defining relative clause.")
            ],
            tips: [
                "Aim for a mix of simple and complex sentences—not all sentences need to be complex",
                "Common conjunctions for IELTS: although, while, whereas, despite, because, since, as",
                "Practice combining two simple sentences into one complex sentence"
            ]
        ),

        GrammarLesson(
            title: "Common IELTS Writing Errors",
            explanation: """
            These are the most common grammatical errors that reduce IELTS scores:

            1. Run-on sentences: Two sentences joined without proper punctuation
            2. Comma splices: Two sentences joined with only a comma
            3. Fragment sentences: Incomplete sentences
            4. Wrong word forms: Using wrong part of speech
            5. Preposition errors: Wrong preposition choice
            """,
            examples: [
                GrammarExample(incorrect: "Technology is useful it helps us communicate.", correct: "Technology is useful. It helps us communicate. / Technology is useful because it helps us communicate.", rule: "Don't join two independent clauses without proper punctuation or conjunction."),
                GrammarExample(incorrect: "Many people use internet, they find it helpful.", correct: "Many people use the internet because they find it helpful.", rule: "Don't join sentences with just a comma (comma splice)."),
                GrammarExample(incorrect: "Such as computers and phones.", correct: "There are many devices, such as computers and phones.", rule: "A sentence must have a subject and a main verb."),
                GrammarExample(incorrect: "Education is very importance.", correct: "Education is very important.", rule: "Use adjectives (important) after 'is', not nouns (importance)."),
                GrammarExample(incorrect: "I am good in English.", correct: "I am good at English.", rule: "The correct preposition is 'good at' not 'good in'.")
            ],
            exercises: [
                GrammarExercise(sentence: "The internet is useful ___ provides information.", options: ["it", "and it", "which", ", it"], correctAnswer: 1, explanation: "Use 'and' to connect two independent clauses, or use 'which'."),
                GrammarExercise(sentence: "There has been a significant ___ in population.", options: ["increasing", "increase", "increased", "increasingly"], correctAnswer: 1, explanation: "After 'a', use a noun (increase), not a verb form."),
                GrammarExercise(sentence: "This essay will discuss ___ pollution is a serious problem.", options: ["that", "what", "why", "how"], correctAnswer: 2, explanation: "'Why' introduces the reason/explanation being discussed."),
                GrammarExercise(sentence: "Many people are interested ___ learning English.", options: ["in", "on", "at", "for"], correctAnswer: 0, explanation: "The correct collocation is 'interested in'."),
                GrammarExercise(sentence: "The ___ of smartphones has increased dramatically.", options: ["popular", "popularity", "popularize", "popularly"], correctAnswer: 1, explanation: "After 'the', we need a noun. 'Popularity' is the noun form.")
            ],
            tips: [
                "Always proofread your writing—save 2-3 minutes at the end",
                "Read your sentences aloud (in your head)—errors often become obvious",
                "Learn common collocations: depend ON, result IN, lead TO, consist OF"
            ]
        )
    ]

    // MARK: - Writing Lessons
    static let writingLessons: [WritingLesson] = [
        WritingLesson(
            title: "Task 2: Opinion Essay",
            type: "Task 2",
            explanation: """
            In an opinion essay, you give your opinion on a topic and support it with reasons and examples.

            Question types:
            • "To what extent do you agree or disagree?"
            • "Do you agree or disagree?"
            • "What is your opinion?"

            Key points:
            • State your opinion clearly in the introduction
            • Give 2-3 main reasons to support your view
            • Use specific examples
            • Restate your opinion in the conclusion
            """,
            structure: [
                "Introduction (40-50 words): Paraphrase topic + State your opinion",
                "Body Paragraph 1 (80-100 words): First reason + Example + Explanation",
                "Body Paragraph 2 (80-100 words): Second reason + Example + Explanation",
                "Body Paragraph 3 (Optional, 60-80 words): Third reason OR Counter-argument",
                "Conclusion (30-40 words): Summarize main points + Restate opinion"
            ],
            sampleQuestion: "Some people believe that unpaid community service should be a compulsory part of high school programs. To what extent do you agree or disagree?",
            sampleAnswer: """
            Many educators argue that mandatory community service should be integrated into high school curricula. I strongly agree with this view, as it offers significant benefits for both students and society.

            Firstly, compulsory community service helps develop essential life skills that cannot be learned in traditional classrooms. When students volunteer at local hospitals or food banks, they learn empathy, teamwork, and responsibility. For instance, a student helping elderly residents at a care home develops patience and communication skills while gaining a deeper understanding of social issues. These experiences shape well-rounded individuals who are better prepared for adult life.

            Secondly, mandatory volunteering strengthens the connection between young people and their communities. Many teenagers today are disconnected from local issues, spending most of their time on digital devices. By requiring them to engage with community organizations, schools can help bridge this gap. Students who clean local parks or tutor younger children develop a sense of civic duty and belonging that stays with them throughout their lives.

            Some may argue that forcing students to volunteer contradicts the spirit of volunteerism. However, research shows that many people who initially volunteer reluctantly develop genuine passion for service work. The mandatory nature simply provides the initial push that many young people need.

            In conclusion, compulsory community service in high schools offers invaluable benefits, from personal development to stronger communities. I firmly believe this should be adopted by schools worldwide.
            """,
            vocabularyList: [
                "compulsory / mandatory / obligatory - বাধ্যতামূলক",
                "curricula (plural of curriculum) - পাঠ্যক্রম",
                "well-rounded - সর্বগুণসম্পন্ন",
                "civic duty - নাগরিক দায়িত্ব",
                "bridge the gap - ফাঁক পূরণ করা",
                "invaluable - অমূল্য",
                "integrate into - অন্তর্ভুক্ত করা",
                "shape (verb) - গঠন করা"
            ],
            tips: [
                "Always clearly state your opinion—don't be vague",
                "Use specific examples, not general statements",
                "Each body paragraph should have ONE main idea",
                "Use linking words: Firstly, Moreover, However, In conclusion",
                "Aim for 270-290 words—don't write too much or too little"
            ]
        ),

        WritingLesson(
            title: "Task 2: Discussion Essay",
            type: "Task 2",
            explanation: """
            In a discussion essay, you discuss BOTH sides of an argument before giving your own opinion (if asked).

            Question types:
            • "Discuss both views and give your own opinion"
            • "Some people think X, others believe Y. Discuss both views."

            Key points:
            • Present both sides fairly
            • Give your opinion at the end (if asked)
            • Don't be biased—show you understand both perspectives
            """,
            structure: [
                "Introduction (40-50 words): Paraphrase topic + Mention both views + (Optional: your opinion)",
                "Body Paragraph 1 (80-100 words): First view + Reasons + Examples",
                "Body Paragraph 2 (80-100 words): Second view + Reasons + Examples",
                "Conclusion (40-50 words): Summarize both views + State your opinion clearly"
            ],
            sampleQuestion: "Some people think that the best way to reduce crime is to give longer prison sentences. Others, however, believe there are better alternative ways of reducing crime. Discuss both views and give your opinion.",
            sampleAnswer: """
            Crime prevention remains a contentious issue in modern society. While some advocate for harsher prison sentences as the primary deterrent, others argue that alternative approaches are more effective. This essay will examine both perspectives before presenting my own view.

            Proponents of longer prison sentences argue that severe punishment deters potential criminals. When individuals face the prospect of spending years behind bars, they may think twice before committing offences. Furthermore, keeping criminals incarcerated for extended periods protects society by preventing repeat offences. Statistics from countries with strict sentencing policies often show lower rates of certain violent crimes.

            On the other hand, many criminologists suggest that addressing root causes of crime is more effective than punishment alone. Poverty, lack of education, and unemployment are significant factors that drive people toward criminal activity. Investment in education, job training programmes, and community development can reduce crime by providing alternatives to illegal activities. Moreover, rehabilitation programmes have shown higher success rates in preventing reoffending compared to simple incarceration.

            In my opinion, while longer sentences may be necessary for serious violent crimes, a comprehensive approach combining prevention and rehabilitation is more effective for reducing overall crime rates. Addressing social inequalities and providing support systems can prevent crime before it occurs, which is ultimately more beneficial for society.

            In conclusion, although stricter sentencing has its merits, tackling the underlying causes of crime through education and social support represents a more sustainable solution to this complex problem.
            """,
            vocabularyList: [
                "contentious issue - বিতর্কিত বিষয়",
                "deterrent - প্রতিরোধক",
                "proponents - সমর্থক",
                "incarcerated - কারাবন্দী",
                "criminologists - অপরাধবিদ",
                "rehabilitation - পুনর্বাসন",
                "reoffending - পুনরায় অপরাধ করা",
                "underlying causes - মূল কারণ"
            ],
            tips: [
                "Give equal treatment to both views—don't be biased in body paragraphs",
                "Save your opinion for the conclusion (or mention briefly in intro)",
                "Use contrast words: However, On the other hand, Conversely, In contrast",
                "Don't introduce new ideas in the conclusion"
            ]
        ),

        WritingLesson(
            title: "Task 1: Line Graph Description",
            type: "Task 1",
            explanation: """
            For Task 1, you describe visual information (graphs, charts, tables, diagrams).

            For line graphs, focus on:
            • Overall trends (increasing, decreasing, fluctuating, stable)
            • Significant changes and turning points
            • Comparisons between different lines
            • Starting and ending points

            Do NOT give opinions or reasons—just describe what you see.
            """,
            structure: [
                "Introduction (20-30 words): Paraphrase what the graph shows",
                "Overview (30-40 words): Describe 2 main trends/features",
                "Body Paragraph 1 (50-70 words): Describe first group of data in detail",
                "Body Paragraph 2 (50-70 words): Describe second group of data in detail"
            ],
            sampleQuestion: "The graph below shows the percentage of households with internet access in three countries from 2000 to 2020.",
            sampleAnswer: """
            The line graph illustrates the proportion of homes with internet connectivity in the USA, UK, and Brazil between 2000 and 2020.

            Overall, all three nations experienced significant growth in internet access over the two decades, with the USA consistently maintaining the highest percentage throughout the period.

            In 2000, approximately 40% of American households had internet access, compared to around 25% in the UK and merely 5% in Brazil. The USA showed steady growth, reaching 70% by 2010 and approximately 90% by 2020. Similarly, the UK demonstrated consistent increases, rising from 25% to 60% in 2010, and eventually reaching about 95% in 2020, surpassing the USA.

            Brazil, despite starting from the lowest point, showed the most dramatic transformation. From just 5% in 2000, internet penetration rose gradually to 40% by 2010. The following decade saw accelerated growth, with the figure climbing to approximately 75% by 2020, narrowing the gap with the other two countries considerably.
            """,
            vocabularyList: [
                "illustrates / shows / depicts - দেখায়",
                "proportion / percentage - অনুপাত / শতাংশ",
                "connectivity / access - সংযোগ / প্রবেশাধিকার",
                "steady growth - স্থির বৃদ্ধি",
                "dramatic transformation - নাটকীয় পরিবর্তন",
                "surpassing - অতিক্রম করা",
                "narrowing the gap - ব্যবধান কমানো",
                "accelerated growth - ত্বরান্বিত বৃদ্ধি"
            ],
            tips: [
                "ALWAYS include an overview—this is essential for a good score",
                "Use a variety of vocabulary: rose, increased, climbed, grew, surged",
                "Include specific data points (numbers, percentages)",
                "Don't describe every single data point—focus on main trends",
                "Word limit is 150 words minimum—aim for 170-190"
            ]
        )
    ]

    // MARK: - Speaking Lessons
    static let speakingLessons: [SpeakingLesson] = [
        SpeakingLesson(
            part: 1,
            topic: "Work and Studies",
            questions: [
                "Do you work or are you a student?",
                "What do you study?",
                "Why did you choose this subject?",
                "What do you like most about your studies?",
                "Do you plan to continue studying in the future?"
            ],
            sampleAnswers: [
                "I'm currently a university student, studying computer science at Dhaka University. I chose this field because technology has always fascinated me, and I believe it offers excellent career opportunities in today's digital world.",
                "What I enjoy most about my studies is the practical aspect—we get to build real applications and solve complex problems. It's incredibly satisfying when a program I've written actually works!",
                "Yes, I definitely plan to pursue further education. I'm considering doing a master's degree abroad, possibly in artificial intelligence, as it's such a rapidly growing field."
            ],
            vocabularyList: [
                "fascinated me - আমাকে মুগ্ধ করেছে",
                "career opportunities - কর্মজীবনের সুযোগ",
                "practical aspect - ব্যবহারিক দিক",
                "pursue further education - উচ্চশিক্ষা গ্রহণ করা",
                "rapidly growing field - দ্রুত বর্ধনশীল ক্ষেত্র"
            ],
            tips: [
                "Give extended answers (2-3 sentences), not just yes/no",
                "Use a variety of tenses naturally",
                "Be enthusiastic—show interest in the topic",
                "It's okay to pause briefly to think, but avoid long silences"
            ]
        ),

        SpeakingLesson(
            part: 2,
            topic: "Describe a skill you would like to learn",
            questions: [
                "What skill is it?",
                "Why do you want to learn it?",
                "How would you learn it?",
                "And explain how this skill would be useful to you."
            ],
            sampleAnswers: [
                """
                I'd like to talk about learning to play the guitar, which is something I've wanted to do for many years.

                I first became interested in playing guitar when I was a teenager. I used to watch music videos and was always amazed by how guitarists could create such beautiful melodies. Since then, I've always dreamed of being able to play my favorite songs myself.

                If I were to learn this skill, I would probably start by taking online lessons, as there are many excellent tutorials available on YouTube. I might also consider joining a local music school for proper guidance. I believe consistency is key, so I would try to practice at least 30 minutes every day.

                This skill would be useful to me in several ways. Firstly, it would be a great way to relax and de-stress after a long day of work or study. Secondly, I could play at family gatherings or with friends, which would be a wonderful way to bond with people. Finally, music is known to improve cognitive abilities, so learning an instrument could actually make me sharper mentally.

                Overall, learning guitar would bring me a lot of joy and help me express myself creatively.
                """
            ],
            vocabularyList: [
                "amazed by - দ্বারা বিস্মিত",
                "consistency is key - ধারাবাহিকতাই মূল",
                "de-stress - চাপ কমানো",
                "bond with people - মানুষের সাথে সম্পর্ক গড়া",
                "cognitive abilities - জ্ঞানীয় ক্ষমতা",
                "express myself creatively - সৃজনশীলভাবে নিজেকে প্রকাশ করা"
            ],
            tips: [
                "You have 1 minute to prepare—use it to make notes",
                "Speak for 1-2 minutes—aim for closer to 2 minutes",
                "Follow the cue card points but expand on them",
                "Use time expressions: When I was..., Since then..., In the future...",
                "Personal stories and examples make your answer more engaging"
            ]
        ),

        SpeakingLesson(
            part: 3,
            topic: "Skills and Learning (Follow-up to Part 2)",
            questions: [
                "What skills are most important for young people to learn today?",
                "Do you think schools teach enough practical skills?",
                "How has technology changed the way people learn new skills?",
                "Why do some people learn skills faster than others?",
                "Should the government provide free skill training programs?"
            ],
            sampleAnswers: [
                "I believe digital literacy and critical thinking are the most essential skills for young people today. In our information age, being able to use technology effectively and evaluate information critically can make a huge difference in both career success and daily life.",
                "To be honest, I think there's room for improvement in how schools approach practical skills. While academic knowledge is important, many young people graduate without knowing basic things like financial management or how to communicate professionally. Schools could benefit from incorporating more real-world applications into their curricula.",
                "Technology has revolutionized learning in remarkable ways. Online platforms like Coursera and YouTube have made it possible to learn almost anything from anywhere. However, this also means people need more self-discipline, as there's no teacher physically present to keep them accountable."
            ],
            vocabularyList: [
                "digital literacy - ডিজিটাল সাক্ষরতা",
                "critical thinking - সমালোচনামূলক চিন্তা",
                "information age - তথ্য যুগ",
                "room for improvement - উন্নতির সুযোগ",
                "real-world applications - বাস্তব-বিশ্ব প্রয়োগ",
                "revolutionized - বিপ্লব ঘটিয়েছে",
                "self-discipline - আত্মশৃঙ্খলা",
                "keep them accountable - তাদের দায়বদ্ধ রাখা"
            ],
            tips: [
                "Part 3 requires deeper, more analytical answers",
                "Give your opinion AND explain why",
                "Use examples from society, not just personal experience",
                "Show range by discussing multiple perspectives",
                "It's okay to say 'That's an interesting question...' while thinking"
            ]
        )
    ]

    // MARK: - Listening Lessons
    static let listeningLessons: [ListeningLesson] = [
        ListeningLesson(
            title: "Section 1: Accommodation Enquiry",
            section: 1,
            transcript: """
            Agent: Good morning, City Apartments. How can I help you?

            Caller: Hi, I'm looking for a flat to rent. I'm a university student and I'll be studying here for the next academic year.

            Agent: Of course. Let me take some details. What's your name, please?

            Caller: It's Sarah Mitchell. That's M-I-T-C-H-E-L-L.

            Agent: And a contact number?

            Caller: My mobile is 07845 329167.

            Agent: Great. Now, what area are you looking in?

            Caller: Ideally somewhere near the university, maybe within walking distance. I don't have a car.

            Agent: We have several properties in the Riverside area, which is about a 15-minute walk from the campus. What's your budget?

            Caller: I can afford up to £600 per month, including bills if possible.

            Agent: Okay. We have a one-bedroom flat on Park Street for £550 per month. Bills are extra, roughly £80 per month.

            Caller: That sounds a bit over my budget with bills included.

            Agent: We also have a studio flat on Queen's Road for £520 including all bills except electricity.

            Caller: That's more like it. When could I view it?

            Agent: We have availability this Thursday at 2 pm or Friday at 10 am.

            Caller: Friday morning works better for me.

            Agent: Perfect. The address is 47 Queen's Road. There's parking available behind the building if you need it in the future. Do you have any pets?

            Caller: No, I don't.

            Agent: Great. Some landlords don't accept pets. One more thing—the flat is available from the 1st of September. Is that suitable?

            Caller: Yes, that's perfect. My course starts on the 15th.

            Agent: Excellent. See you Friday at 10 am then.
            """,
            questions: [
                ListeningQuestion(question: "What is the caller's surname?", answer: "Mitchell", questionType: "Fill blank"),
                ListeningQuestion(question: "What is the caller's mobile number?", answer: "07845 329167", questionType: "Fill blank"),
                ListeningQuestion(question: "How far is Riverside from the university?", answer: "15-minute walk", questionType: "Fill blank"),
                ListeningQuestion(question: "What is the monthly rent of the Park Street flat?", answer: "£550", questionType: "Fill blank"),
                ListeningQuestion(question: "What is included in the £520 rent for Queen's Road?", answer: "All bills except electricity", questionType: "Fill blank"),
                ListeningQuestion(question: "What day and time is the viewing?", answer: "Friday at 10 am", questionType: "Fill blank"),
                ListeningQuestion(question: "What is the flat's address?", answer: "47 Queen's Road", questionType: "Fill blank"),
                ListeningQuestion(question: "When is the flat available from?", answer: "1st of September", questionType: "Fill blank")
            ],
            tips: [
                "Section 1 is usually a conversation about everyday situations",
                "Listen for spellings—names, addresses are often spelled out",
                "Numbers are very common—dates, times, prices, phone numbers",
                "Read questions before listening to know what to listen for",
                "Write answers as you hear them—don't wait"
            ]
        ),

        ListeningLesson(
            title: "Section 2: University Campus Tour",
            section: 2,
            transcript: """
            Welcome to Greenfield University's campus tour. My name is Dr. Patricia Wong, and I'll be showing you around our main facilities today.

            We're currently standing in front of the Main Library, which was built in 1965 and renovated in 2019. It houses over 2 million books and journals, and is open 24 hours during exam periods. The library has five floors: the ground floor has the help desk and computer stations, floors one and two contain general collections, floor three is dedicated to science and technology resources, and the top floor has our special collections and rare books.

            If you look to your right, you'll see the Student Union building. This is where you'll find the cafeteria, which serves meals from 7 am to 9 pm. There's also a coffee shop on the ground floor called "The Bean" that's popular with students. The building also contains meeting rooms available for student clubs and a small convenience store.

            Moving forward, the large modern building ahead is the Science Complex, completed in 2021 at a cost of £45 million. It includes state-of-the-art laboratories for biology, chemistry, and physics. All science students will have their practical sessions here.

            To the left of the Science Complex is the Sports Centre. Membership is free for all registered students. Facilities include an Olympic-sized swimming pool, a fully equipped gym, tennis courts, and a football pitch. The Sports Centre is open from 6 am to 10 pm on weekdays and 8 am to 8 pm on weekends.

            Now, let me tell you about some important services. The Health Centre is located behind the library and offers free medical consultations to all students. It's open Monday to Friday, 9 am to 5 pm. For emergencies outside these hours, there's a 24-hour helpline.

            The Career Services office, which I highly recommend visiting, is on the first floor of the Main Administration building. They offer CV workshops, interview practice, and job placement assistance. Last year, 94% of our graduates found employment within six months of graduating.

            Finally, I'd like to mention accommodation. First-year students are guaranteed a place in halls of residence if they apply before July 31st. The accommodation office is in the Student Services building, next to the Main Library.

            Are there any questions before we continue the tour?
            """,
            questions: [
                ListeningQuestion(question: "When was the Main Library renovated?", answer: "2019", questionType: "Fill blank"),
                ListeningQuestion(question: "What is on the third floor of the library?", answer: "Science and technology resources", questionType: "Fill blank"),
                ListeningQuestion(question: "What are the cafeteria's opening hours?", answer: "7 am to 9 pm", questionType: "Fill blank"),
                ListeningQuestion(question: "How much did the Science Complex cost?", answer: "£45 million", questionType: "Fill blank"),
                ListeningQuestion(question: "What are the Sports Centre's weekend hours?", answer: "8 am to 8 pm", questionType: "Fill blank"),
                ListeningQuestion(question: "What percentage of graduates found jobs within six months?", answer: "94%", questionType: "Fill blank"),
                ListeningQuestion(question: "What is the deadline to apply for halls of residence?", answer: "July 31st", questionType: "Fill blank")
            ],
            tips: [
                "Section 2 is usually a monologue about a non-academic topic",
                "Pay attention to numbers, dates, times, and percentages",
                "Note-taking is essential—you can't remember everything",
                "Listen for signposting words: 'Now', 'Moving on', 'Finally'",
                "Maps and diagrams are common—follow the speaker's directions"
            ]
        ),

        ListeningLesson(
            title: "Section 3: Academic Discussion",
            section: 3,
            transcript: """
            Tutor: Good morning, James and Priya. Let's discuss your research project on renewable energy. How is it progressing?

            James: We've made good progress, Dr. Chen. We decided to focus specifically on solar energy adoption in developing countries.

            Tutor: Interesting choice. What made you narrow it down to that?

            Priya: Well, initially we wanted to cover all renewable sources, but we realized that was too broad. Solar energy seemed most relevant because the technology has become much more affordable recently, making it accessible to developing nations.

            Tutor: That's a sensible approach. What sources have you been using?

            James: We've primarily used academic journals, especially articles from the last five years. We also found some useful data from the International Energy Agency's reports.

            Priya: And we conducted interviews with three experts in the field via video call. That gave us some really valuable insights that weren't in the published literature.

            Tutor: Excellent. Primary research always strengthens a project. What are your main findings so far?

            James: One surprising finding was that government policy matters more than we expected. Countries with strong subsidies and incentives have seen adoption rates increase by up to 300% compared to those without.

            Priya: We also found that community-based projects tend to be more successful than individual installations. When villages work together, they can afford larger systems that are more efficient.

            Tutor: Have you encountered any challenges?

            James: The main challenge has been accessing reliable data from some regions. Not all countries maintain detailed records of energy installations.

            Priya: And some of the academic sources contradicted each other, so we had to be careful about which data to include.

            Tutor: That's a common issue in research. How did you handle the contradictions?

            Priya: We looked for more recent sources and prioritized peer-reviewed articles over news reports or opinion pieces.

            Tutor: Good methodology. What's left to complete?

            James: We need to write the conclusion and recommendations section. We also want to add some case studies to illustrate our points.

            Tutor: When do you think you'll have a complete draft?

            Priya: We're aiming for next Friday, the 15th.

            Tutor: That should give you enough time to revise before the final deadline on the 30th. Any other concerns?

            James: Just the presentation. We're a bit nervous about the Q&A session afterwards.

            Tutor: I can help you prepare for that. Let's schedule a practice session next week. How about Tuesday at 2 pm?

            Both: That works for us. Thank you, Dr. Chen.
            """,
            questions: [
                ListeningQuestion(question: "What is the specific focus of James and Priya's project?", answer: "Solar energy adoption in developing countries", questionType: "Fill blank"),
                ListeningQuestion(question: "Why did they choose to focus on solar energy?", answer: "Technology has become more affordable/accessible", questionType: "Fill blank"),
                ListeningQuestion(question: "How many experts did they interview?", answer: "Three", questionType: "Fill blank"),
                ListeningQuestion(question: "By how much have adoption rates increased in countries with strong subsidies?", answer: "Up to 300%", questionType: "Fill blank"),
                ListeningQuestion(question: "What type of projects tend to be more successful?", answer: "Community-based projects", questionType: "Fill blank"),
                ListeningQuestion(question: "When is the draft deadline?", answer: "The 15th (next Friday)", questionType: "Fill blank"),
                ListeningQuestion(question: "When is the final deadline?", answer: "The 30th", questionType: "Fill blank"),
                ListeningQuestion(question: "When is the practice session scheduled?", answer: "Tuesday at 2 pm", questionType: "Fill blank")
            ],
            tips: [
                "Section 3 involves academic discussion—usually 2-4 speakers",
                "Listen for opinions, agreements, and disagreements",
                "Pay attention to how speakers correct or clarify each other",
                "Questions often ask about reasons, problems, and solutions",
                "Names of speakers help you follow who says what"
            ]
        )
    ]
}
