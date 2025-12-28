//
//  VotingView.swift
//  ShadowWord
//

import SwiftUI

struct VotingView: View {
    @Bindable var gameVM: GameViewModel
    @State private var isVotingRevealed = false
    @State private var selectedPlayerId: UUID?
    @State private var showConfirmation = false
    @State private var navigateToResults = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: SWSpacing.lg) {
                // Progress
                VStack(spacing: SWSpacing.sm) {
                    ProgressView(value: gameVM.votingProgress)
                        .tint(Color.swGlowPurple)
                        .scaleEffect(y: 2)
                    
                    Text("Vote \(currentVoteNumber) of \(gameVM.players.count)")
                        .font(SWTypography.caption)
                        .foregroundColor(.swTextSecondary)
                }
                .padding(.horizontal, SWSpacing.lg)
                
                if let voter = gameVM.currentVotingPlayer {
                    if !isVotingRevealed {
                        // Pass to voter
                        Spacer()
                        
                        PassToVoterCard(voterName: voter.name) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isVotingRevealed = true
                            }
                            HapticsService.shared.impact(.medium)
                        }
                        
                        Spacer()
                    } else {
                        // Voting interface
                        VStack(spacing: SWSpacing.md) {
                            Text("\(voter.name), who is the liar?")
                                .font(SWTypography.title3)
                                .foregroundColor(.swTextPrimary)
                                .padding(.top, SWSpacing.md)
                            
                            ScrollView {
                                VStack(spacing: SWSpacing.sm) {
                                    ForEach(gameVM.players) { player in
                                        if player.id != voter.id {
                                            PlayerListRow(
                                                player: player,
                                                isSelected: selectedPlayerId == player.id
                                            ) {
                                                selectedPlayerId = player.id
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, SWSpacing.lg)
                            }
                        }
                        
                        Spacer()
                        
                        // Vote Button
                        PrimaryButton(
                            title: "Cast Vote",
                            icon: "checkmark.circle.fill",
                            isDisabled: selectedPlayerId == nil
                        ) {
                            showConfirmation = true
                        }
                        .padding(.horizontal, SWSpacing.lg)
                        .padding(.bottom, SWSpacing.lg)
                    }
                } else {
                    // All votes cast
                    Spacer()
                    
                    VotingCompleteCard()
                    
                    Spacer()
                    
                    PrimaryButton(title: "Reveal Results", icon: "theatermasks.fill") {
                        gameVM.calculateResults()
                        gameVM.proceedToPhase(.results)
                        navigateToResults = true
                    }
                    .padding(.horizontal, SWSpacing.lg)
                    .padding(.bottom, SWSpacing.lg)
                }
            }
        }
        .navigationTitle("Voting")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToResults) {
            ResultsView(gameVM: gameVM)
        }
        .confirmationDialog(
            "Confirm your vote",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            if let id = selectedPlayerId, let player = gameVM.players.first(where: { $0.id == id }) {
                Button("Vote for \(player.name)") {
                    submitVote()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You cannot change your vote after confirming.")
        }
    }
    
    private var currentVoteNumber: Int {
        let voted = gameVM.players.filter { $0.hasVoted }.count
        return min(voted + 1, gameVM.players.count)
    }
    
    private func submitVote() {
        guard let playerId = selectedPlayerId else { return }
        
        HapticsService.shared.voteConfirm()
        gameVM.recordVote(for: playerId)
        
        // Reset state for next voter
        withAnimation(.easeOut(duration: 0.2)) {
            isVotingRevealed = false
            selectedPlayerId = nil
        }
    }
}

struct PassToVoterCard: View {
    let voterName: String
    let onReveal: () -> Void
    
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: SWSpacing.xl) {
            Text("Pass to")
                .font(SWTypography.subheadline)
                .foregroundColor(.swTextSecondary)
            
            PlayerAvatar(name: voterName, size: 80, showBorder: true, borderColor: .swGlowPurple)
                .scaleEffect(pulseAnimation ? 1.05 : 1.0)
            
            Text(voterName)
                .font(SWTypography.title2)
                .foregroundColor(.swTextPrimary)
            
            Text("Time to vote!")
                .font(SWTypography.subheadline)
                .foregroundColor(.swTextSecondary)
            
            Spacer().frame(height: SWSpacing.md)
            
            Button(action: onReveal) {
                VStack(spacing: SWSpacing.sm) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.swGradientPrimary)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    
                    Text("Tap to Vote")
                        .font(SWTypography.headline)
                        .foregroundColor(.swTextPrimary)
                }
                .padding(SWSpacing.lg)
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
        }
        .padding(.horizontal, SWSpacing.xl)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

struct VotingCompleteCard: View {
    @State private var animateCheck = false
    
    var body: some View {
        VStack(spacing: SWSpacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.swGradientPrimary)
                    .frame(width: 100, height: 100)
                    .swGlow(color: .swGlowPurple, radius: 20)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateCheck ? 1 : 0)
            }
            
            Text("All Votes Cast!")
                .font(SWTypography.title2)
                .foregroundColor(.swTextPrimary)
            
            Text("The votes are in. Time to reveal the results...")
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
        VotingView(gameVM: {
            let vm = GameViewModel()
            vm.startNewRound(settings: .default, players: Player.defaultPlayers(count: 4))
            return vm
        }())
    }
}
