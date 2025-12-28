//
//  PlayersViewModel.swift
//  ShadowWord
//

import Foundation

@Observable
final class PlayersViewModel {
    var players: [Player] = []
    
    init() {}
    
    func setupPlayers(count: Int) {
        // Try to load saved names
        if let savedNames = PersistenceService.shared.loadPlayerNames(), savedNames.count == count {
            players = savedNames.enumerated().map { index, name in
                Player(name: name)
            }
        } else {
            players = Player.defaultPlayers(count: count)
        }
    }
    
    func updatePlayerName(at index: Int, name: String) {
        guard index < players.count else { return }
        players[index].name = name.isEmpty ? "Player \(index + 1)" : name
        saveNames()
    }
    
    func addPlayer() {
        let newNumber = players.count + 1
        players.append(Player(name: "Player \(newNumber)"))
        saveNames()
    }
    
    func removePlayer(at index: Int) {
        guard players.count > 3 else { return }
        players.remove(at: index)
        saveNames()
    }
    
    private func saveNames() {
        PersistenceService.shared.savePlayerNames(players.map { $0.name })
    }
    
    var playerCount: Int {
        players.count
    }
}
