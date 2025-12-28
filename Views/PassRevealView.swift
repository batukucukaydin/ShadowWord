//
//  PassRevealView.swift
//  ShadowWord
//

import SwiftUI

struct PassRevealView: View {
    @Bindable var gameVM: GameViewModel
    @State private var isRevealed = false
    @State private var showCard = false
    @State private var navigateToCluePhase = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: SWSpacing.xl) {
                // Progress
                VStack(spacing: SWSpacing.sm) {
                    ProgressView(value: gameVM.revealProgress)
                        .tint(Color.swGlowPurple)
                        .scaleEffect(y: 2)
                    
                    Text("Player \(currentPlayerNumber) of \(gameVM.players.count)")
                        .font(SWTypography.caption)
                        .foregroundColor(.swTextSecondary)
                }
                .padding(.horizontal, SWSpacing.lg)
                
                Spacer()
                
                if let player = gameVM.currentRevealPlayer {
                    if !isRevealed {
                        // Pass instruction
                        PassToPlayerCard(playerName: player.name) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isRevealed = true
                                showCard = true
                            }
                            HapticsService.shared.roleReveal(isLiar: player.isLiar)
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Role reveal
                        let revealContent = gameVM.getRevealContent(for: player)
                        
                        RoleCard(
                            isLiar: revealContent.isLiar,
                            content: revealContent.content,
                            subtitle: revealContent.subtitle
                        )
                        .scaleEffect(showCard ? 1 : 0.8)
                        .opacity(showCard ? 1 : 0)
                        .padding(.horizontal, SWSpacing.lg)
                        .transition(.scale.combined(with: .opacity))
                    }
                } else {
                    // All revealed - show completion
                    AllRevealedCard()
                }
                
                Spacer()
                
                // Action Button
                if let _ = gameVM.currentRevealPlayer {
                    if isRevealed {
                        PrimaryButton(title: "Hide & Pass", icon: "eye.slash.fill") {
                            hideAndPass()
                        }
                        .padding(.horizontal, SWSpacing.lg)
                    }
                } else {
                    PrimaryButton(title: "Begin Discussion", icon: "bubble.left.and.bubble.right.fill") {
                        gameVM.proceedToPhase(.discussion)
                        navigateToCluePhase = true
                    }
                    .padding(.horizontal, SWSpacing.lg)
                }
                
                Spacer(minLength: SWSpacing.xl)
            }
        }
        .navigationTitle("Role Reveal")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToCluePhase) {
            CluePhaseView(gameVM: gameVM)
        }
    }
    
    private var currentPlayerNumber: Int {
        let revealed = gameVM.players.filter { $0.hasRevealed }.count
        return min(revealed + 1, gameVM.players.count)
    }
    
    private func hideAndPass() {
        HapticsService.shared.impact(.light)
        
        withAnimation(.easeOut(duration: 0.2)) {
            showCard = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            gameVM.markCurrentPlayerRevealed()
            isRevealed = false
        }
    }
}

struct PassToPlayerCard: View {
    let playerName: String
    let onReveal: () -> Void
    
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: SWSpacing.xl) {
            Text("Pass to")
                .font(SWTypography.subheadline)
                .foregroundColor(.swTextSecondary)
            
            PlayerAvatar(name: playerName, size: 100, showBorder: true, borderColor: .swGlowPurple)
                .scaleEffect(pulseAnimation ? 1.05 : 1.0)
            
            Text(playerName)
                .font(SWTypography.title1)
                .foregroundColor(.swTextPrimary)
            
            Spacer().frame(height: SWSpacing.lg)
            
            Button(action: onReveal) {
                VStack(spacing: SWSpacing.sm) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.swGradientPrimary)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    
                    Text("Tap to Reveal Your Role")
                        .font(SWTypography.headline)
                        .foregroundColor(.swTextPrimary)
                }
                .padding(SWSpacing.xl)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: SWRadius.xl)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: SWRadius.xl)
                        .strokeBorder(Color.swGlowPurple.opacity(0.5), lineWidth: 2)
                )
            }
            .swGlow(color: .swGlowPurple, radius: 15)
        }
        .padding(.horizontal, SWSpacing.lg)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

struct AllRevealedCard: View {
    @State private var animateCheck = false
    
    var body: some View {
        VStack(spacing: SWSpacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.swGradientInnocent)
                    .frame(width: 100, height: 100)
                    .swGlow(color: .swSuccess, radius: 20)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateCheck ? 1 : 0)
            }
            
            Text("All Players Ready!")
                .font(SWTypography.title2)
                .foregroundColor(.swTextPrimary)
            
            Text("Everyone has seen their role. Time to find the liar!")
                .font(SWTypography.body)
                .foregroundColor(.swTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SWSpacing.xl)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                animateCheck = true
            }
            HapticsService.shared.success()
        }
    }
}

#Preview {
    NavigationStack {
        PassRevealView(gameVM: {
            let vm = GameViewModel()
            vm.startNewRound(settings: .default, players: Player.defaultPlayers(count: 4))
            return vm
        }())
    }
}
