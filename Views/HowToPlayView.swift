//
//  HowToPlayView.swift
//  ShadowWord
//

import SwiftUI

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: GameMode = .word
    
    var body: some View {
        ZStack {
            AnimatedBackground(showParticles: false)
            
            ScrollView {
                VStack(spacing: SWSpacing.xl) {
                    // Mode Selector
                    HStack(spacing: SWSpacing.sm) {
                        ForEach(GameMode.allCases, id: \.self) { mode in
                            ChipButton(
                                title: mode.displayName,
                                icon: mode.icon,
                                isSelected: selectedMode == mode
                            ) {
                                withAnimation { selectedMode = mode }
                            }
                        }
                    }
                    .padding(.top, SWSpacing.md)
                    
                    // Mode Description
                    GlassCard {
                        VStack(alignment: .leading, spacing: SWSpacing.md) {
                            HStack {
                                Image(systemName: selectedMode.icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color.swGradientPrimary)
                                
                                Text(selectedMode.displayName)
                                    .font(SWTypography.title2)
                                    .foregroundColor(.swTextPrimary)
                            }
                            
                            Text(selectedMode == .word 
                                ? "Everyone sees the same secret word, except the liar who must blend in without knowing it."
                                : "Everyone gets the same question, but the liar receives a slightly different one."
                            )
                            .font(SWTypography.body)
                            .foregroundColor(.swTextSecondary)
                        }
                    }
                    
                    // Steps
                    VStack(spacing: SWSpacing.md) {
                        StepCard(
                            number: 1,
                            title: "Setup",
                            description: "Choose the number of players and liars. Select categories and difficulty.",
                            icon: "gearshape.fill"
                        )
                        
                        StepCard(
                            number: 2,
                            title: "Role Reveal",
                            description: "Pass the phone around. Each player taps to see if they're innocent or the liar.",
                            icon: "eye.fill"
                        )
                        
                        StepCard(
                            number: 3,
                            title: selectedMode == .word ? "Give Clues" : "Answer Questions",
                            description: selectedMode == .word 
                                ? "Take turns giving ONE clue about the word. Don't be too obvious, or the liar will catch on!" 
                                : "Everyone answers the question. The liar must blend in despite having a different question!",
                            icon: "bubble.left.fill"
                        )
                        
                        StepCard(
                            number: 4,
                            title: "Discussion",
                            description: "Discuss who you think the liar is. Watch for suspicious behavior!",
                            icon: "person.3.fill"
                        )
                        
                        StepCard(
                            number: 5,
                            title: "Vote",
                            description: "Everyone votes. The player with the most votes is eliminated!",
                            icon: "hand.raised.fill"
                        )
                        
                        StepCard(
                            number: 6,
                            title: "Reveal",
                            description: selectedMode == .word
                                ? "If the liar is caught, they get one last chance to guess the word!"
                                : "See if the group found the right person!",
                            icon: "theatermasks.fill"
                        )
                    }
                    
                    // Pro Tips
                    GlassCard(glowColor: .swGlowPurple) {
                        VStack(alignment: .leading, spacing: SWSpacing.sm) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.swWarning)
                                Text("Pro Tips")
                                    .font(SWTypography.headline)
                                    .foregroundColor(.swTextPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: SWSpacing.xs) {
                                TipRow(text: "As the liar, give vague clues that could fit many words")
                                TipRow(text: "Watch for players who give overly generic clues")
                                TipRow(text: "The liar wins ties, so create confusion!")
                                TipRow(text: "Don't give clues that are too obvious")
                            }
                        }
                    }
                    
                    Spacer(minLength: SWSpacing.xxxl)
                }
                .padding(.horizontal, SWSpacing.lg)
            }
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StepCard: View {
    let number: Int
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        GlassCard(padding: SWSpacing.md) {
            HStack(alignment: .top, spacing: SWSpacing.md) {
                // Step number
                ZStack {
                    Circle()
                        .fill(Color.swGradientPrimary)
                        .frame(width: 36, height: 36)
                    
                    Text("\(number)")
                        .font(SWTypography.headline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: SWSpacing.xxs) {
                    HStack {
                        Text(title)
                            .font(SWTypography.headline)
                            .foregroundColor(.swTextPrimary)
                        
                        Spacer()
                        
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(.swTextSecondary)
                    }
                    
                    Text(description)
                        .font(SWTypography.subheadline)
                        .foregroundColor(.swTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: SWSpacing.xs) {
            Text("•")
                .foregroundColor(.swGlowPurple)
            Text(text)
                .font(SWTypography.subheadline)
                .foregroundColor(.swTextSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        HowToPlayView()
    }
}
