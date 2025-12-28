//
//  ShadowWordApp.swift
//  ShadowWord
//
//  A party game of clues, bluffing & deduction
//

import SwiftUI

@main
struct ShadowWordApp: App {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    
    init() {
        // Prepare haptics on launch
        HapticsService.shared.prepare()
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .preferredColorScheme(appTheme.colorScheme)
        }
    }
}

// MARK: - App Store Description
/*
 ShadowWord - The Ultimate Party Bluffing Game
 
 Who's the liar? Give clues, bluff your way through — the perfect party game
 for friends, family, and school!
 
 Features:
 • Two exciting game modes: Word Mode and Find the Liar
 • Support for 3-100 players
 • 10 categories with 300+ words and questions
 • Beautiful glassmorphism design
 • Works completely offline
 • Adjustable difficulty levels
 • Pass-and-play voting system
 
 How to Play:
 1. Everyone sees the same secret word, except the liar
 2. Take turns giving clues without being too obvious
 3. Discuss and find the suspicious player
 4. Vote on who you think is the liar
 5. If caught, the liar gets one last chance to guess the word!
 
 Perfect for:
 • House parties
 • Family game nights
 • Team building events
 • School activities
 • Road trips
 
 Playable offline, quick to start, endless fun!
 */
