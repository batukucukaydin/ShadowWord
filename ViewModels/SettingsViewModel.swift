//
//  SettingsViewModel.swift
//  ShadowWord
//

import Foundation
import SwiftUI

@Observable
final class SettingsViewModel {
    var settings: GameSettings
    var availableCategories: [Category] = []
    
    init() {
        self.settings = PersistenceService.shared.loadSettings()
        self.availableCategories = ContentService.shared.categories
        
        // If no categories selected, select all
        if settings.selectedCategories.isEmpty {
            settings.selectedCategories = Set(availableCategories.map { $0.name })
        }
    }
    
    var playerCount: Int {
        get { settings.playerCount }
        set {
            settings.playerCount = max(3, min(100, newValue))
            settings.adjustLiarCount()
            save()
        }
    }
    
    var liarCount: Int {
        get { settings.fixedLiarCount }
        set {
            settings.fixedLiarCount = max(1, min(settings.maxLiarCount, newValue))
            save()
        }
    }
    
    var maxLiarCount: Int {
        settings.maxLiarCount
    }
    
    var isRandomLiarCount: Bool {
        get { settings.liarCountMode == .random }
        set {
            settings.liarCountMode = newValue ? .random : .fixed
            save()
        }
    }
    
    var gameMode: GameMode {
        get { settings.gameMode }
        set {
            settings.gameMode = newValue
            save()
        }
    }
    
    var difficulty: Difficulty {
        get { settings.difficulty }
        set {
            settings.difficulty = newValue
            save()
        }
    }
    
    var showCategoryToLiar: Bool {
        get { settings.showCategoryToLiar }
        set {
            settings.showCategoryToLiar = newValue
            save()
        }
    }
    
    var showHintToLiar: Bool {
        get { settings.showHintToLiar }
        set {
            settings.showHintToLiar = newValue
            save()
        }
    }
    
    var liarNeverGoesFirst: Bool {
        get { settings.liarNeverGoesFirst }
        set {
            settings.liarNeverGoesFirst = newValue
            save()
        }
    }
    
    var selectedCategories: Set<String> {
        get { settings.selectedCategories }
        set {
            settings.selectedCategories = newValue
            save()
        }
    }
    
    var selectedCategoryCount: Int {
        settings.selectedCategories.count
    }
    
    var allCategoriesSelected: Bool {
        settings.selectedCategories.count == availableCategories.count
    }
    
    var isValid: Bool {
        settings.isValid
    }
    
    func toggleCategory(_ name: String) {
        if settings.selectedCategories.contains(name) {
            settings.selectedCategories.remove(name)
        } else {
            settings.selectedCategories.insert(name)
        }
        save()
    }
    
    func selectAllCategories() {
        settings.selectedCategories = Set(availableCategories.map { $0.name })
        save()
    }
    
    func deselectAllCategories() {
        settings.selectedCategories.removeAll()
        save()
    }
    
    func isCategorySelected(_ name: String) -> Bool {
        settings.selectedCategories.contains(name)
    }
    
    func save() {
        PersistenceService.shared.saveSettings(settings)
    }
    
    func resetToDefaults() {
        settings = .default
        settings.selectedCategories = Set(availableCategories.map { $0.name })
        save()
    }
}
