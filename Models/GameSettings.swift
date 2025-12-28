//
//  GameSettings.swift
//  ShadowWord
//
//  Game configuration settings
//

import Foundation

// MARK: - Game Mode

enum GameMode: String, Codable, CaseIterable, CustomStringConvertible {
    case word = "word"
    case question = "question"
    
    var description: String {
        switch self {
        case .word: return "Word"
        case .question: return "Question"
        }
    }
    
    var displayName: String {
        switch self {
        case .word: return "Word Mode"
        case .question: return "Find the Liar"
        }
    }
    
    var icon: String {
        switch self {
        case .word: return "textformat.abc"
        case .question: return "questionmark.bubble.fill"
        }
    }
    
    var subtitle: String {
        switch self {
        case .word: return "Everyone gets the same secret word"
        case .question: return "Liar gets a different question"
        }
    }
}

// MARK: - Difficulty

enum Difficulty: String, Codable, CaseIterable, CustomStringConvertible {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var description: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var subtitle: String {
        switch self {
        case .easy: return "Words are more distinct"
        case .medium: return "Balanced difficulty"
        case .hard: return "Words are very similar"
        }
    }
}

// MARK: - Liar Count Mode

enum LiarCountMode: String, Codable {
    case fixed = "fixed"
    case random = "random"
}

// MARK: - Game Settings

struct GameSettings: Codable, Equatable {
    var playerCount: Int = 4
    var liarCountMode: LiarCountMode = .fixed
    var fixedLiarCount: Int = 1
    var gameMode: GameMode = .word
    var selectedCategories: Set<String> = []
    var difficulty: Difficulty = .medium
    var showCategoryToLiar: Bool = true
    var showHintToLiar: Bool = false
    var liarNeverGoesFirst: Bool = true
    
    // Computed properties
    var maxLiarCount: Int {
        max(1, playerCount / 3)
    }
    
    var recommendedLiarRange: ClosedRange<Int> {
        1...min(3, maxLiarCount)
    }
    
    var actualLiarCount: Int {
        switch liarCountMode {
        case .fixed:
            return min(fixedLiarCount, maxLiarCount)
        case .random:
            let range = recommendedLiarRange
            return Int.random(in: range)
        }
    }
    
    var isValid: Bool {
        playerCount >= 3 && 
        fixedLiarCount >= 1 && 
        fixedLiarCount <= maxLiarCount &&
        !selectedCategories.isEmpty
    }
    
    // Default settings
    static let `default` = GameSettings()
    
    // Helper to update liar count when player count changes
    mutating func adjustLiarCount() {
        if fixedLiarCount > maxLiarCount {
            fixedLiarCount = maxLiarCount
        }
    }
}

// MARK: - Settings Keys for UserDefaults

extension GameSettings {
    private static let userDefaultsKey = "shadowword.settings"
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
        }
    }
    
    static func load() -> GameSettings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(GameSettings.self, from: data) else {
            return .default
        }
        return settings
    }
    
    static func reset() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
