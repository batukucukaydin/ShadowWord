//
//  GameContent.swift
//  ShadowWord
//
//  Content models for words, questions, and categories
//

import Foundation

// MARK: - Word Item

struct WordItem: Codable, Identifiable, Hashable {
    var id: String { word }
    let word: String
    let hint: String
    let difficulty: String // "easy", "medium", "hard"
    
    var difficultyLevel: Difficulty {
        Difficulty(rawValue: difficulty) ?? .medium
    }
}

// MARK: - Question Pair

struct QuestionPair: Codable, Identifiable, Hashable {
    var id: String { mainQuestion }
    let mainQuestion: String
    let liarQuestion: String
    let difficulty: String
    
    var difficultyLevel: Difficulty {
        Difficulty(rawValue: difficulty) ?? .medium
    }
}

// MARK: - Category

struct Category: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let icon: String
    let words: [WordItem]
    let questionPairs: [QuestionPair]
    
    var wordCount: Int { words.count }
    var questionCount: Int { questionPairs.count }
    
    func words(for difficulty: Difficulty) -> [WordItem] {
        // Include current difficulty and easier
        switch difficulty {
        case .easy:
            return words.filter { $0.difficultyLevel == .easy }
        case .medium:
            return words.filter { $0.difficultyLevel == .easy || $0.difficultyLevel == .medium }
        case .hard:
            return words
        }
    }
    
    func questions(for difficulty: Difficulty) -> [QuestionPair] {
        switch difficulty {
        case .easy:
            return questionPairs.filter { $0.difficultyLevel == .easy }
        case .medium:
            return questionPairs.filter { $0.difficultyLevel == .easy || $0.difficultyLevel == .medium }
        case .hard:
            return questionPairs
        }
    }
}

// MARK: - Game Content (Root)

struct GameContent: Codable {
    let categories: [Category]
    
    var categoryNames: [String] {
        categories.map { $0.name }
    }
    
    func category(named name: String) -> Category? {
        categories.first { $0.name == name }
    }
    
    func categories(named names: Set<String>) -> [Category] {
        if names.isEmpty {
            return categories
        }
        return categories.filter { names.contains($0.name) }
    }
}

// MARK: - Round Content Selection

struct RoundContent {
    let category: Category
    let word: WordItem?          // For Word Mode
    let questionPair: QuestionPair?  // For Question Mode
    
    var secretWord: String {
        word?.word ?? ""
    }
    
    var hint: String {
        word?.hint ?? ""
    }
    
    var mainQuestion: String {
        questionPair?.mainQuestion ?? ""
    }
    
    var liarQuestion: String {
        questionPair?.liarQuestion ?? ""
    }
    
    // Generate wrong options for liar guess (for Word Mode)
    func generateGuessOptions(from allWords: [WordItem], correctWord: String) -> [String] {
        var options = [correctWord]
        let otherWords = allWords.filter { $0.word != correctWord }.shuffled()
        
        for word in otherWords.prefix(3) {
            options.append(word.word)
        }
        
        // If we don't have enough words, add some generic options
        while options.count < 4 {
            options.append("Unknown \(options.count)")
        }
        
        return options.shuffled()
    }
}
