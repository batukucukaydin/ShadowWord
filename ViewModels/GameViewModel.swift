//
//  GameViewModel.swift
//  ShadowWord
//

import Foundation

@Observable
final class GameViewModel {
    private(set) var roundState = RoundState()
    private let contentService = ContentService.shared
    
    // MARK: - Setup
    
    func startNewRound(settings: GameSettings, players: [Player]) {
        roundState.settings = settings
        roundState.players = players
        roundState.resetForNewRound()
        
        // Select content
        if let content = contentService.selectContent(settings: settings) {
            roundState.content = content
        }
        
        // Assign liars
        assignLiars()
        
        // Determine starting player
        selectStartingPlayer()
        
        // Generate liar guess options if word mode
        if settings.gameMode == .word {
            generateLiarGuessOptions()
        }
    }
    
    private func assignLiars() {
        let liarCount = roundState.settings.actualLiarCount
        var indices = Array(0..<roundState.players.count)
        indices.shuffle()
        
        let liarIndices = Set(indices.prefix(liarCount))
        
        for i in roundState.players.indices {
            roundState.players[i].isLiar = liarIndices.contains(i)
        }
    }
    
    private func selectStartingPlayer() {
        var possibleIndices = Array(0..<roundState.players.count)
        
        if roundState.settings.liarNeverGoesFirst {
            possibleIndices = possibleIndices.filter { !roundState.players[$0].isLiar }
        }
        
        roundState.startingPlayerIndex = possibleIndices.randomElement() ?? 0
    }
    
    private func generateLiarGuessOptions() {
        guard let content = roundState.content, let word = content.word else { return }
        let allWords = contentService.getAllWords(from: roundState.settings.selectedCategories)
        roundState.liarGuessOptions = content.generateGuessOptions(from: allWords, correctWord: word.word)
    }
    
    // MARK: - Phase Transitions
    
    func proceedToPhase(_ phase: GamePhase) {
        roundState.phase = phase
    }
    
    // MARK: - Reveal Flow
    
    var currentRevealPlayer: Player? {
        roundState.currentRevealPlayer
    }
    
    var allPlayersRevealed: Bool {
        roundState.allPlayersRevealed
    }
    
    var revealProgress: Double {
        roundState.revealProgress
    }
    
    func getRevealContent(for player: Player) -> (isLiar: Bool, content: String, subtitle: String?) {
        if player.isLiar {
            var subtitle: String? = nil
            
            switch roundState.settings.gameMode {
            case .word:
                if roundState.settings.showCategoryToLiar {
                    subtitle = "Category: \(roundState.categoryName)"
                }
                if roundState.settings.showHintToLiar {
                    let hint = roundState.hint
                    if !hint.isEmpty {
                        subtitle = (subtitle ?? "") + (subtitle != nil ? "\n" : "") + "Hint: \(hint)"
                    }
                }
                return (true, "Blend in with the group...", subtitle)
                
            case .question:
                return (true, roundState.liarQuestion, "Your question is different!")
            }
        } else {
            switch roundState.settings.gameMode {
            case .word:
                return (false, roundState.secretWord, "Category: \(roundState.categoryName)")
            case .question:
                return (false, roundState.mainQuestion, nil)
            }
        }
    }
    
    func markCurrentPlayerRevealed() {
        roundState.markCurrentPlayerRevealed()
    }
    
    // MARK: - Discussion
    
    var startingPlayer: Player? {
        roundState.startingPlayer
    }
    
    // MARK: - Voting Flow
    
    var currentVotingPlayer: Player? {
        roundState.currentVotingPlayer
    }
    
    var allPlayersVoted: Bool {
        roundState.allPlayersVoted
    }
    
    var votingProgress: Double {
        roundState.votingProgress
    }
    
    func recordVote(for playerId: UUID) {
        roundState.recordVote(for: playerId)
    }
    
    func calculateResults() {
        roundState.calculateVoteResult()
    }
    
    // MARK: - Results
    
    var voteResult: VoteResult? {
        roundState.voteResult
    }
    
    var outcome: GameOutcome? {
        roundState.outcome
    }
    
    var liars: [Player] {
        roundState.liars
    }
    
    var secretWord: String {
        roundState.secretWord
    }
    
    var mainQuestion: String {
        roundState.mainQuestion
    }
    
    var players: [Player] {
        roundState.players
    }
    
    var settings: GameSettings {
        roundState.settings
    }
    
    var categoryName: String {
        roundState.categoryName
    }
    
    // MARK: - Liar Guess
    
    var liarGuessOptions: [String] {
        roundState.liarGuessOptions
    }
    
    var shouldShowLiarGuess: Bool {
        // Only show if liar was caught and we're in word mode
        if case .liarCaught = roundState.voteResult {
            return roundState.settings.gameMode == .word
        }
        return false
    }
    
    func processLiarGuess(_ word: String) {
        roundState.processLiarGuess(selectedWord: word)
    }
    
    var liarGuessCorrect: Bool? {
        roundState.liarGuessCorrect
    }
    
    // MARK: - Play Again
    
    func playAgain() {
        let savedSettings = roundState.settings
        let savedPlayers = roundState.players.map { Player(id: $0.id, name: $0.name) }
        startNewRound(settings: savedSettings, players: savedPlayers)
    }
}
