//
//  ResultsView.swift
//  ShadowWord
//

import SwiftUI

struct ResultsView: View {
    @Bindable var gameVM: GameViewModel
    @State private var showReveal = false
    @State private var showVotes = false
    @State private var showOutcome = false
    @State private var navigateToLiarGuess = false
    @State private var navigateToWelcome = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: SWSpacing.xl) {
                    Spacer(minLength: SWSpacing.xl)
                    
                    // Liar Reveal
                    if showReveal {
                        LiarRevealCard(liars: gameVM.liars)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Secret Word/Question
                    if showReveal {
                        SecretRevealCard(
                            gameMode: gameVM.settings.gameMode,
                            secretWord: gameVM.secretWord,
                            mainQuestion: gameVM.mainQuestion,
                            categoryName: gameVM.categoryName
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Vote Breakdown
                    if showVotes {
                        VoteBreakdownCard(players: gameVM.players)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Outcome Message
                    if showOutcome, let voteResult = gameVM.voteResult {
                        OutcomeCard(voteResult: voteResult)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer(minLength: 150)
                }
                .padding(.horizontal, SWSpacing.lg)
            }
            
            // Action Buttons
            VStack {
                Spacer()
                
                VStack(spacing: SWSpacing.md) {
                    if showOutcome {
                        if gameVM.shouldShowLiarGuess && gameVM.outcome == nil {
                            PrimaryButton(title: "Liar's Last Chance", icon: "theatermasks.fill", style: .danger) {
                                gameVM.proceedToPhase(.liarGuess)
                                navigateToLiarGuess = true
                            }
                        } else {
                            PrimaryButton(title: "Play Again", icon: "arrow.clockwise") {
                                playAgain()
                            }
                            
                            PrimaryButton(title: "New Game", style: .ghost) {
                                navigateToWelcome = true
                            }
                        }
                    }
                }
                .padding(.horizontal, SWSpacing.lg)
                .padding(.bottom, SWSpacing.lg)
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            animateResults()
        }
        .navigationDestination(isPresented: $navigateToLiarGuess) {
            LiarGuessView(gameVM: gameVM)
        }
        .navigationDestination(isPresented: $navigateToWelcome) {
            WelcomeView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func animateResults() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            showReveal = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8)) {
            showVotes = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.3)) {
            showOutcome = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            if let result = gameVM.voteResult {
                HapticsService.shared.resultReveal(liarWins: result.liarWins)
            }
        }
    }
    
    private func playAgain() {
        HapticsService.shared.impact(.medium)
        gameVM.playAgain()
        
        // Navigate back to reveal
        // Since we're using NavigationStack, we'll create a new game flow
        navigateToWelcome = false
        navigateToLiarGuess = false
    }
}

struct LiarRevealCard: View {
    let liars: [Player]
    
    var body: some View {
        GlassCard(glowColor: .swDanger) {
            VStack(spacing: SWSpacing.lg) {
                Text(liars.count > 1 ? "The Liars Were" : "The Liar Was")
                    .font(SWTypography.headline)
                    .foregroundColor(.swTextSecondary)
                
                ForEach(liars) { liar in
                    HStack(spacing: SWSpacing.md) {
                        PlayerAvatar(name: liar.name, size: 60, showBorder: true, borderColor: .swDanger)
                        
                        Text(liar.name)
                            .font(SWTypography.title2)
                            .foregroundColor(.swDanger)
                    }
                }
                
                Image(systemName: "theatermasks.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.swGradientLiar)
                    .swGlow(color: .swDanger, radius: 15)
            }
        }
    }
}

struct SecretRevealCard: View {
    let gameMode: GameMode
    let secretWord: String
    let mainQuestion: String
    let categoryName: String
    
    var body: some View {
        GlassCard(glowColor: .swSuccess) {
            VStack(spacing: SWSpacing.md) {
                Text(gameMode == .word ? "The Secret Word Was" : "The Question Was")
                    .font(SWTypography.headline)
                    .foregroundColor(.swTextSecondary)
                
                Text(gameMode == .word ? secretWord : mainQuestion)
                    .font(SWTypography.secretWord)
                    .foregroundColor(.swSuccess)
                    .multilineTextAlignment(.center)
                
                Text("Category: \(categoryName)")
                    .font(SWTypography.caption)
                    .foregroundColor(.swTextSecondary)
            }
        }
    }
}

struct VoteBreakdownCard: View {
    let players: [Player]
    
    var sortedPlayers: [Player] {
        players.sorted { $0.votesReceived > $1.votesReceived }
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: SWSpacing.md) {
                Text("Vote Results")
                    .font(SWTypography.headline)
                    .foregroundColor(.swTextPrimary)
                
                ForEach(sortedPlayers) { player in
                    HStack {
                        PlayerAvatar(name: player.name, size: 32)
                        
                        Text(player.name)
                            .font(SWTypography.body)
                            .foregroundColor(.swTextPrimary)
                        
                        if player.isLiar {
                            Image(systemName: "theatermasks.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.swDanger)
                        }
                        
                        Spacer()
                        
                        Text("\(player.votesReceived) vote\(player.votesReceived == 1 ? "" : "s")")
                            .font(SWTypography.subheadline)
                            .foregroundColor(.swTextSecondary)
                    }
                }
            }
        }
    }
}

struct OutcomeCard: View {
    let voteResult: VoteResult
    
    var body: some View {
        GlassCard(glowColor: voteResult.liarWins ? .swDanger : .swSuccess) {
            VStack(spacing: SWSpacing.md) {
                Image(systemName: voteResult.liarWins ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(voteResult.liarWins ? .swDanger : .swSuccess)
                    .swGlow(color: voteResult.liarWins ? .swDanger : .swSuccess, radius: 15)
                
                Text(voteResult.title)
                    .font(SWTypography.title2)
                    .foregroundColor(voteResult.liarWins ? .swDanger : .swSuccess)
                
                Text(voteResult.subtitle)
                    .font(SWTypography.body)
                    .foregroundColor(.swTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResultsView(gameVM: {
            let vm = GameViewModel()
            vm.startNewRound(settings: .default, players: Player.defaultPlayers(count: 4))
            // Simulate votes
            for player in vm.players {
                vm.recordVote(for: vm.players.first!.id)
            }
            vm.calculateResults()
            return vm
        }())
    }
}
