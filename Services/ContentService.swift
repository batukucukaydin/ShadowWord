//
//  ContentService.swift
//  ShadowWord
//

import Foundation

final class ContentService {
    static let shared = ContentService()
    
    private(set) var content: GameContent?
    
    private init() {
        loadContent()
    }
    
    private func loadContent() {
        // Try loading from bundle JSON first
        if let url = Bundle.main.url(forResource: "GameContent", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(GameContent.self, from: data) {
            content = decoded
            return
        }
        // Fall back to embedded content
        content = Self.embeddedContent
    }
    
    var categories: [Category] {
        content?.categories ?? []
    }
    
    var categoryNames: [String] {
        categories.map { $0.name }
    }
    
    func randomWord(from categoryNames: Set<String>, difficulty: Difficulty) -> (Category, WordItem)? {
        let filtered = categories.filter { categoryNames.isEmpty || categoryNames.contains($0.name) }
        guard let category = filtered.randomElement() else { return nil }
        let words = category.words(for: difficulty)
        guard let word = words.randomElement() else { return nil }
        return (category, word)
    }
    
    func randomQuestionPair(from categoryNames: Set<String>, difficulty: Difficulty) -> (Category, QuestionPair)? {
        let filtered = categories.filter { categoryNames.isEmpty || categoryNames.contains($0.name) }
        guard let category = filtered.randomElement() else { return nil }
        let questions = category.questions(for: difficulty)
        guard let pair = questions.randomElement() else { return nil }
        return (category, pair)
    }
    
    func selectContent(settings: GameSettings) -> RoundContent? {
        switch settings.gameMode {
        case .word:
            guard let (cat, word) = randomWord(from: settings.selectedCategories, difficulty: settings.difficulty) else { return nil }
            return RoundContent(category: cat, word: word, questionPair: nil)
        case .question:
            guard let (cat, pair) = randomQuestionPair(from: settings.selectedCategories, difficulty: settings.difficulty) else { return nil }
            return RoundContent(category: cat, word: nil, questionPair: pair)
        }
    }
    
    func getAllWords(from categoryNames: Set<String>) -> [WordItem] {
        let filtered = categories.filter { categoryNames.isEmpty || categoryNames.contains($0.name) }
        return filtered.flatMap { $0.words }
    }
}
