//
//  GamePhase.swift
//  ShadowWord
//
//  Game state phases
//

import Foundation

enum GamePhase: String, Codable, Equatable {
    case setup           // Setting up the game
    case playerNames     // Entering player names
    case roleReveal      // Pass-and-play role reveal
    case discussion      // Clue-giving phase
    case voting          // Voting phase
    case results         // Showing results
    case liarGuess       // Liar's chance to guess the word
    case gameOver        // Final results
    
    var displayTitle: String {
        switch self {
        case .setup: return "Setup"
        case .playerNames: return "Players"
        case .roleReveal: return "Reveal Roles"
        case .discussion: return "Discussion"
        case .voting: return "Voting"
        case .results: return "Results"
        case .liarGuess: return "Last Chance"
        case .gameOver: return "Game Over"
        }
    }
    
    var instruction: String {
        switch self {
        case .setup:
            return "Configure your game settings"
        case .playerNames:
            return "Enter player names"
        case .roleReveal:
            return "Pass the device to see your role"
        case .discussion:
            return "Give clues and find the liar!"
        case .voting:
            return "Vote for who you think is the liar"
        case .results:
            return "See who got caught!"
        case .liarGuess:
            return "The liar gets one last chance..."
        case .gameOver:
            return "Game complete!"
        }
    }
}

// MARK: - Vote Result

enum VoteResult: Equatable {
    case liarCaught(liarPlayer: Player)
    case liarEscaped(votedPlayer: Player?, liars: [Player])
    case tie(players: [Player], liars: [Player])
    
    var liarWins: Bool {
        switch self {
        case .liarCaught: return false
        case .liarEscaped: return true
        case .tie: return true // Default: ties favor the liar
        }
    }
    
    var title: String {
        switch self {
        case .liarCaught:
            return "Liar Caught!"
        case .liarEscaped:
            return "Liar Escaped!"
        case .tie:
            return "It's a Tie!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .liarCaught(let player):
            return "\(player.name) was the liar and got caught!"
        case .liarEscaped(let voted, let liars):
            let liarNames = liars.map { $0.name }.joined(separator: ", ")
            if let voted = voted {
                return "\(voted.name) was innocent! The liar was \(liarNames)."
            }
            return "The liar \(liarNames) got away!"
        case .tie(_, let liars):
            let liarNames = liars.map { $0.name }.joined(separator: ", ")
            return "Votes were tied! The liar \(liarNames) wins!"
        }
    }
}

// MARK: - Game Outcome

enum GameOutcome: Equatable {
    case groupWins
    case liarWins
    case liarStolenWin // Liar guessed the word correctly after being caught
    
    var title: String {
        switch self {
        case .groupWins:
            return "Group Wins! 🎉"
        case .liarWins:
            return "Liar Wins! 🎭"
        case .liarStolenWin:
            return "Liar Steals the Win! 🎭"
        }
    }
    
    var subtitle: String {
        switch self {
        case .groupWins:
            return "The group successfully identified the liar!"
        case .liarWins:
            return "The liar successfully blended in!"
        case .liarStolenWin:
            return "The liar was caught but guessed the word correctly!"
        }
    }
    
    var isLiarVictory: Bool {
        self == .liarWins || self == .liarStolenWin
    }
}
