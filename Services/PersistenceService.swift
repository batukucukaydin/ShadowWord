//
//  PersistenceService.swift
//  ShadowWord
//

import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let settings = "shadowword.settings"
        static let playerNames = "shadowword.playerNames"
        static let favoriteCategories = "shadowword.favoriteCategories"
    }
    
    private init() {}
    
    func saveSettings(_ settings: GameSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: Keys.settings)
        }
    }
    
    func loadSettings() -> GameSettings {
        guard let data = defaults.data(forKey: Keys.settings),
              let settings = try? JSONDecoder().decode(GameSettings.self, from: data) else {
            return .default
        }
        return settings
    }
    
    func resetSettings() {
        defaults.removeObject(forKey: Keys.settings)
    }
    
    func savePlayerNames(_ names: [String]) {
        defaults.set(names, forKey: Keys.playerNames)
    }
    
    func loadPlayerNames() -> [String]? {
        defaults.stringArray(forKey: Keys.playerNames)
    }
    
    func saveFavoriteCategories(_ categories: Set<String>) {
        defaults.set(Array(categories), forKey: Keys.favoriteCategories)
    }
    
    func loadFavoriteCategories() -> Set<String> {
        Set(defaults.stringArray(forKey: Keys.favoriteCategories) ?? [])
    }
    
    func resetAll() {
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}
