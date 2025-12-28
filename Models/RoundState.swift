//
//  RoundState.swift
//  ShadowWord
//
//  Current round state tracking
//

import Foundation

struct RoundState: Equatable {
    var phase: GamePhase = .setup
    var players: [Player] = []
    var settings: GameSettings = .default
    var content: RoundContent?
    var startingPlayerIndex: Int = 0
    var currentRevealIndex: Int = 0
    var currentVotingIndex: Int = 0
    var voteResult: VoteResult?
    var outcome: GameOutcome?
    var liarGuessOptions: [String] = []
    var liarGuessCorrect: Bool?
    
    // Non-equatable content wrapper
    static func == (lhs: RoundState, rhs: RoundState) -> Bool {
        lhs.phase == rhs.phase &&
        lhs.players == rhs.players &&
        lhs.settings == rhs.settings &&
        lhs.startingPlayerIndex == rhs.startingPlayerIndex &&
        lhs.currentRevealIndex == rhs.currentRevealIndex &&
        lhs.currentVotingIndex == rhs.currentVotingIndex &&
        lhs.voteResult == rhs.voteResult &&
        lhs.outcome == rhs.outcome &&
        lhs.liarGuessOptions == rhs.liarGuessOptions &&
        lhs.liarGuessCorrect == rhs.liarGuessCorrect
    }
    
    // MARK: - Computed Properties
    
    var currentRevealPlayer: Player? {
        guard currentRevealIndex < players.count else { return nil }
        return players[currentRevealIndex]
    }
    
    var currentVotingPlayer: Player? {
        guard currentVotingIndex < players.count else { return nil }
        return players[currentVotingIndex]
    }
    
    var startingPlayer: Player? {
        guard startingPlayerIndex < players.count else { return nil }
        return players[startingPlayerIndex]
    }
    
    var liars: [Player] {
        players.filter { $0.isLiar }
    }
    
    var innocents: [Player] {
        players.filter { !$0.isLiar }
    }
    
    var categoryName: String {
        content?.category.name ?? "Unknown"
    }
    
    var secretWord: String {
        content?.secretWord ?? ""
    }
    
    var mainQuestion: String {
        content?.mainQuestion ?? ""
    }
    
    var liarQuestion: String {
        content?.liarQuestion ?? ""
    }
    
    var hint: String {
        content?.hint ?? ""
    }
    
    var allPlayersRevealed: Bool {
        players.allSatisfy { $0.hasRevealed }
    }
    
    var allPlayersVoted: Bool {
        players.allSatisfy { $0.hasVoted }
    }
    
    var revealProgress: Double {
        guard !players.isEmpty else { return 0 }
        return Double(players.filter { $0.hasRevealed }.count) / Double(players.count)
    }
    
    var votingProgress: Double {
        guard !players.isEmpty else { return 0 }
        return Double(players.filter { $0.hasVoted }.count) / Double(players.count)
    }
    
    // MARK: - Methods
    
    mutating func resetForNewRound() {
        phase = .roleReveal
        currentRevealIndex = 0
        currentVotingIndex = 0
        voteResult = nil
        outcome = nil
        liarGuessOptions = []
        liarGuessCorrect = nil
        
        // Reset player states but keep names
        for i in players.indices {
            players[i].isLiar = false
            players[i].hasRevealed = false
            players[i].hasVoted = false
            players[i].votedForId = nil
            players[i].votesReceived = 0
        }
    }
    
    mutating func markCurrentPlayerRevealed() {
        guard currentRevealIndex < players.count else { return }
        players[currentRevealIndex].hasRevealed = true
        currentRevealIndex += 1
    }
    
    mutating func recordVote(for playerId: UUID) {
        guard currentVotingIndex < players.count else { return }
        players[currentVotingIndex].hasVoted = true
        players[currentVotingIndex].votedForId = playerId
        
        // Increment vote count for target player
        if let targetIndex = players.firstIndex(where: { $0.id == playerId }) {
            players[targetIndex].votesReceived += 1
        }
        
        currentVotingIndex += 1
    }
    
    mutating func calculateVoteResult() {
        // Find player(s) with most votes
        let maxVotes = players.map { $0.votesReceived }.max() ?? 0
        let mostVoted = players.filter { $0.votesReceived == maxVotes }
        
        if mostVoted.count > 1 {
            // Tie - liar wins
            voteResult = .tie(players: mostVoted, liars: liars)
            outcome = .liarWins
        } else if let votedOut = mostVoted.first {
            if votedOut.isLiar {
                // Liar caught
                voteResult = .liarCaught(liarPlayer: votedOut)
                // Don't set outcome yet - liar gets a chance to guess
            } else {
                // Wrong person voted out
                voteResult = .liarEscaped(votedPlayer: votedOut, liars: liars)
                outcome = .liarWins
            }
        }
    }
    
    mutating func processLiarGuess(selectedWord: String) {
        let isCorrect = selectedWord.lowercased() == secretWord.lowercased()
        liarGuessCorrect = isCorrect
        
        if isCorrect {
            outcome = .liarStolenWin
        } else {
            outcome = .groupWins
        }
    }
}
