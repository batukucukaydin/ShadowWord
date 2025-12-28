//
//  LiarGuessView.swift
//  ShadowWord
//

import SwiftUI

struct LiarGuessView: View {
    @Bindable var gameVM: GameViewModel
    @State private var selectedWord: String?
    @State private var hasGuessed = false
    @State private var showResult = false
    @State private var navigateToWelcome = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: SWSpacing.xl) {
                Spacer()
                
                if !hasGuessed {
                    // Liar Guess Interface
                    VStack(spacing: SWSpacing.xl) {
                        // Header
                        VStack(spacing: SWSpacing.md) {
                            Image(systemName: "theatermasks.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.swGradientLiar)
                                .swGlow(color: .swDanger, radius: 20)
                            
                            Text("Last Chance!")
                                .font(SWTypography.largeTitle)
                                .foregroundColor(.swTextPrimary)
                            
                            if let liar = gameVM.liars.first {
                                Text("\(liar.name), guess the secret word to steal the win!")
                                    .font(SWTypography.body)
                                    .foregroundColor(.swTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        // Word Options
                        VStack(spacing: SWSpacing.md) {
                            ForEach(gameVM.liarGuessOptions, id: \.self) { word in
                                WordOptionButton(
                                    word: word,
                                    isSelected: selectedWord == word
                                ) {
                                    selectedWord = word
                                    HapticsService.shared.selection()
                                }
                            }
                        }
                        .padding(.horizontal, SWSpacing.lg)
                    }
                    
                    Spacer()
                    
                    // Confirm Button
                    PrimaryButton(
                        title: "Confirm Guess",
                        icon: "checkmark.circle.fill",
                        style: .danger,
                        isDisabled: selectedWord == nil
                    ) {
                        submitGuess()
                    }
                    .padding(.horizontal, SWSpacing.lg)
                } else {
                    // Result
                    if showResult {
                        GuessResultCard(
                            isCorrect: gameVM.liarGuessCorrect ?? false,
                            secretWord: gameVM.secretWord,
                            outcome: gameVM.outcome
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: SWSpacing.md) {
                        PrimaryButton(title: "Play Again", icon: "arrow.clockwise") {
                            playAgain()
                        }
                        
                        PrimaryButton(title: "New Game", style: .ghost) {
                            navigateToWelcome = true
                        }
                    }
                    .padding(.horizontal, SWSpacing.lg)
                }
                
                Spacer(minLength: SWSpacing.xl)
            }
        }
        .navigationTitle("Liar's Guess")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToWelcome) {
            WelcomeView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func submitGuess() {
        guard let word = selectedWord else { return }
        
        HapticsService.shared.impact(.heavy)
        gameVM.processLiarGuess(word)
        hasGuessed = true
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            showResult = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if gameVM.liarGuessCorrect == true {
                HapticsService.shared.warning()
            } else {
                HapticsService.shared.success()
            }
        }
    }
    
    private func playAgain() {
        HapticsService.shared.impact(.medium)
        gameVM.playAgain()
    }
}

struct WordOptionButton: View {
    let word: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(word)
                    .font(SWTypography.title3)
                    .foregroundColor(isSelected ? .white : .swTextPrimary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .swTextSecondary)
            }
            .padding(SWSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: SWRadius.lg)
                    .fill(isSelected 
                        ? AnyShapeStyle(Color.swGradientPrimary) 
                        : AnyShapeStyle(colorScheme == .dark 
                            ? Color.white.opacity(0.1) 
                            : Color.black.opacity(0.05)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: SWRadius.lg)
                    .strokeBorder(
                        isSelected ? Color.swGlowPurple : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .swGlow(color: isSelected ? .swGlowPurple : .clear, radius: isSelected ? 10 : 0)
    }
}

struct GuessResultCard: View {
    let isCorrect: Bool
    let secretWord: String
    let outcome: GameOutcome?
    
    var body: some View {
        VStack(spacing: SWSpacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(isCorrect ? Color.swGradientLiar : Color.swGradientInnocent)
                    .frame(width: 120, height: 120)
                    .swGlow(color: isCorrect ? .swDanger : .swSuccess, radius: 25)
                
                Image(systemName: isCorrect ? "theatermasks.fill" : "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Result Text
            VStack(spacing: SWSpacing.md) {
                Text(isCorrect ? "Correct Guess!" : "Wrong Guess!")
                    .font(SWTypography.largeTitle)
                    .foregroundColor(isCorrect ? .swDanger : .swSuccess)
                
                Text("The word was: \(secretWord)")
                    .font(SWTypography.title3)
                    .foregroundColor(.swTextPrimary)
                
                if let outcome = outcome {
                    GlassCard(glowColor: outcome.isLiarVictory ? .swDanger : .swSuccess) {
                        VStack(spacing: SWSpacing.sm) {
                            Text(outcome.title)
                                .font(SWTypography.title2)
                                .foregroundColor(outcome.isLiarVictory ? .swDanger : .swSuccess)
                            
                            Text(outcome.subtitle)
                                .font(SWTypography.body)
                                .foregroundColor(.swTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, SWSpacing.lg)
                }
            }
        }
        .padding(.horizontal, SWSpacing.xl)
    }
}

#Preview {
    NavigationStack {
        LiarGuessView(gameVM: {
            let vm = GameViewModel()
            vm.startNewRound(settings: .default, players: Player.defaultPlayers(count: 4))
            return vm
        }())
    }
}
