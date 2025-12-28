//
//  PlayerNamesView.swift
//  ShadowWord
//

import SwiftUI

struct PlayerNamesView: View {
    let playerCount: Int
    let settings: GameSettings
    
    @State private var playersVM = PlayersViewModel()
    @State private var gameVM = GameViewModel()
    @State private var navigateToGame = false
    @FocusState private var focusedPlayerIndex: Int?
    
    var body: some View {
        ZStack {
            AnimatedBackground(showParticles: false)
            
            ScrollView {
                VStack(spacing: SWSpacing.md) {
                    // Header
                    GlassCard {
                        VStack(spacing: SWSpacing.sm) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.swGradientPrimary)
                            
                            Text("Enter Player Names")
                                .font(SWTypography.title3)
                                .foregroundColor(.swTextPrimary)
                            
                            Text("Tap a name to edit. Names are saved automatically.")
                                .font(SWTypography.caption)
                                .foregroundColor(.swTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Player List
                    ForEach(Array(playersVM.players.enumerated()), id: \.element.id) { index, player in
                        PlayerNameRow(
                            playerNumber: index + 1,
                            name: Binding(
                                get: { player.name },
                                set: { playersVM.updatePlayerName(at: index, name: $0) }
                            ),
                            isFocused: focusedPlayerIndex == index,
                            onFocus: { focusedPlayerIndex = index },
                            canDelete: playersVM.players.count > 3,
                            onDelete: { playersVM.removePlayer(at: index) }
                        )
                        .focused($focusedPlayerIndex, equals: index)
                    }
                    
                    // Add Player Button
                    if playersVM.players.count < 100 {
                        Button(action: {
                            playersVM.addPlayer()
                            HapticsService.shared.impact(.light)
                        }) {
                            GlassCard(padding: SWSpacing.md) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.swGradientPrimary)
                                    
                                    Text("Add Player")
                                        .font(SWTypography.headline)
                                        .foregroundColor(.swTextPrimary)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, SWSpacing.lg)
                .padding(.top, SWSpacing.md)
            }
            
            // Start Game Button
            VStack {
                Spacer()
                
                PrimaryButton(title: "Start Game", icon: "play.fill") {
                    startGame()
                }
                .padding(.horizontal, SWSpacing.lg)
                .padding(.bottom, SWSpacing.lg)
            }
        }
        .navigationTitle("Players")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            playersVM.setupPlayers(count: playerCount)
        }
        .navigationDestination(isPresented: $navigateToGame) {
            PassRevealView(gameVM: gameVM)
        }
        .onTapGesture {
            focusedPlayerIndex = nil
        }
    }
    
    private func startGame() {
        HapticsService.shared.impact(.medium)
        gameVM.startNewRound(settings: settings, players: playersVM.players)
        navigateToGame = true
    }
}

struct PlayerNameRow: View {
    let playerNumber: Int
    @Binding var name: String
    let isFocused: Bool
    let onFocus: () -> Void
    let canDelete: Bool
    let onDelete: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GlassCard(padding: SWSpacing.md) {
            HStack(spacing: SWSpacing.md) {
                // Player Number
                ZStack {
                    Circle()
                        .fill(Color.swGradientPrimary)
                        .frame(width: 36, height: 36)
                    
                    Text("\(playerNumber)")
                        .font(SWTypography.headline)
                        .foregroundColor(.white)
                }
                
                // Name TextField
                TextField("Player \(playerNumber)", text: $name)
                    .font(SWTypography.body)
                    .foregroundColor(.swTextPrimary)
                    .textFieldStyle(.plain)
                    .onTapGesture { onFocus() }
                
                Spacer()
                
                // Delete Button
                if canDelete {
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        onDelete()
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.swDanger.opacity(0.8))
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: SWRadius.xl)
                .strokeBorder(
                    isFocused ? Color.swGlowPurple : Color.clear,
                    lineWidth: 2
                )
        )
    }
}

#Preview {
    NavigationStack {
        PlayerNamesView(playerCount: 5, settings: .default)
    }
}
