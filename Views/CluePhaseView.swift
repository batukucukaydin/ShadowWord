//
//  CluePhaseView.swift
//  ShadowWord
//

import SwiftUI

struct CluePhaseView: View {
    @Bindable var gameVM: GameViewModel
    @State private var navigateToVoting = false
    @State private var showInstructions = true
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: SWSpacing.xl) {
                Spacer()
                
                // Phase Title
                VStack(spacing: SWSpacing.md) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.swGradientPrimary)
                        .swGlow(color: .swGlowPurple, radius: 15)
                    
                    Text("Discussion Time")
                        .font(SWTypography.largeTitle)
                        .foregroundColor(.swTextPrimary)
                }
                
                Spacer()
                
                // Starting Player
                if let startingPlayer = gameVM.startingPlayer {
                    GlassCard {
                        VStack(spacing: SWSpacing.md) {
                            Text("Starting Player")
                                .font(SWTypography.caption)
                                .foregroundColor(.swTextSecondary)
                            
                            HStack(spacing: SWSpacing.md) {
                                PlayerAvatar(name: startingPlayer.name, size: 50, showBorder: true, borderColor: .swGlowPurple)
                                
                                Text(startingPlayer.name)
                                    .font(SWTypography.title3)
                                    .foregroundColor(.swTextPrimary)
                            }
                            
                            Text("goes first!")
                                .font(SWTypography.subheadline)
                                .foregroundColor(.swTextSecondary)
                        }
                    }
                    .padding(.horizontal, SWSpacing.lg)
                }
                
                // Instructions
                if gameVM.settings.gameMode == .word {
                    GlassCard(padding: SWSpacing.lg) {
                        VStack(spacing: SWSpacing.md) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.swGlowPurple)
                                Text("How to Play")
                                    .font(SWTypography.headline)
                                    .foregroundColor(.swTextPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: SWSpacing.sm) {
                                InstructionRow(number: 1, text: "Each player says ONE clue about the word")
                                InstructionRow(number: 2, text: "Don't be too obvious or the liar will catch on")
                                InstructionRow(number: 3, text: "Watch for vague or suspicious clues")
                                InstructionRow(number: 4, text: "Discuss who you think is the liar")
                            }
                        }
                    }
                    .padding(.horizontal, SWSpacing.lg)
                } else {
                    GlassCard(padding: SWSpacing.lg) {
                        VStack(spacing: SWSpacing.md) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.swGlowPurple)
                                Text("How to Play")
                                    .font(SWTypography.headline)
                                    .foregroundColor(.swTextPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: SWSpacing.sm) {
                                InstructionRow(number: 1, text: "Each player answers their question out loud")
                                InstructionRow(number: 2, text: "The liar has a different question!")
                                InstructionRow(number: 3, text: "Watch for answers that don't quite fit")
                                InstructionRow(number: 4, text: "Discuss and find the odd one out")
                            }
                        }
                    }
                    .padding(.horizontal, SWSpacing.lg)
                }
                
                Spacer()
                
                // Voting Button
                PrimaryButton(title: "Begin Voting", icon: "hand.raised.fill") {
                    HapticsService.shared.impact(.medium)
                    gameVM.proceedToPhase(.voting)
                    navigateToVoting = true
                }
                .padding(.horizontal, SWSpacing.lg)
                
                Spacer(minLength: SWSpacing.xl)
            }
        }
        .navigationTitle("Discussion")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToVoting) {
            VotingView(gameVM: gameVM)
        }
    }
}

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: SWSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.swGlowPurple.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Text("\(number)")
                    .font(SWTypography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.swGlowPurple)
            }
            
            Text(text)
                .font(SWTypography.subheadline)
                .foregroundColor(.swTextSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        CluePhaseView(gameVM: {
            let vm = GameViewModel()
            vm.startNewRound(settings: .default, players: Player.defaultPlayers(count: 4))
            return vm
        }())
    }
}
