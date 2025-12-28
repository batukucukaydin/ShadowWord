//
//  Player.swift
//  ShadowWord
//
//  Player model for the game
//

import Foundation

struct Player: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    var name: String
    var isLiar: Bool = false
    var hasRevealed: Bool = false
    var hasVoted: Bool = false
    var votedForId: UUID? = nil
    var votesReceived: Int = 0
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Create default players
    static func defaultPlayers(count: Int) -> [Player] {
        (1...count).map { Player(name: "Player \($0)") }
    }
}

// MARK: - Player Extensions

extension Array where Element == Player {
    var liars: [Player] {
        filter { $0.isLiar }
    }
    
    var innocents: [Player] {
        filter { !$0.isLiar }
    }
    
    var allRevealed: Bool {
        allSatisfy { $0.hasRevealed }
    }
    
    var allVoted: Bool {
        allSatisfy { $0.hasVoted }
    }
    
    func player(withId id: UUID) -> Player? {
        first { $0.id == id }
    }
    
    mutating func updatePlayer(_ player: Player) {
        if let index = firstIndex(where: { $0.id == player.id }) {
            self[index] = player
        }
    }
}
