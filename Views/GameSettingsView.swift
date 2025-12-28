//
//  GameSettingsView.swift
//  ShadowWord
//

import SwiftUI

struct GameSettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var showCategorySelection = false
    @State private var showResetAlert = false
    
    var body: some View {
        ZStack {
            AnimatedBackground(showParticles: false)
            
            ScrollView {
                VStack(spacing: SWSpacing.lg) {
                    // Player Count
                    CounterView(
                        title: "Players",
                        value: $viewModel.settings.playerCount,
                        range: 3...100,
                        subtitle: "Minimum 3 players required",
                        icon: "person.3.fill"
                    )
                    .onChange(of: viewModel.settings.playerCount) { _, _ in
                        viewModel.settings.adjustLiarCount()
                        viewModel.save()
                    }
                    
                    // Liar Count
                    CounterView(
                        title: "Liars",
                        value: $viewModel.settings.fixedLiarCount,
                        range: 1...viewModel.maxLiarCount,
                        subtitle: "Max \(viewModel.maxLiarCount) for \(viewModel.playerCount) players",
                        icon: "theatermasks.fill"
                    )
                    .onChange(of: viewModel.settings.fixedLiarCount) { _, _ in
                        viewModel.save()
                    }
                    
                    // Random Liar Toggle
                    ToggleCard(
                        title: "Random Liar Count",
                        isOn: Binding(
                            get: { viewModel.isRandomLiarCount },
                            set: { viewModel.isRandomLiarCount = $0 }
                        ),
                        subtitle: "Randomize liars each round (1-\(min(3, viewModel.maxLiarCount)))",
                        icon: "dice.fill"
                    )
                    
                    // Game Mode
                    GlassCard(padding: SWSpacing.md) {
                        VStack(alignment: .leading, spacing: SWSpacing.md) {
                            HStack(spacing: SWSpacing.xs) {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.swGradientPrimary)
                                
                                Text("Game Mode")
                                    .font(SWTypography.headline)
                                    .foregroundColor(.swTextPrimary)
                            }
                            
                            ForEach(GameMode.allCases, id: \.self) { mode in
                                GameModeRow(
                                    mode: mode,
                                    isSelected: viewModel.gameMode == mode
                                ) {
                                    viewModel.gameMode = mode
                                }
                            }
                        }
                    }
                    
                    // Categories
                    Button(action: { showCategorySelection = true }) {
                        GlassCard(padding: SWSpacing.md) {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.swGradientPrimary)
                                
                                VStack(alignment: .leading, spacing: SWSpacing.xxs) {
                                    Text("Categories")
                                        .font(SWTypography.headline)
                                        .foregroundColor(.swTextPrimary)
                                    
                                    Text("\(viewModel.selectedCategoryCount) of \(viewModel.availableCategories.count) selected")
                                        .font(SWTypography.caption)
                                        .foregroundColor(.swTextSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.swTextSecondary)
                            }
                        }
                    }
                    
                    // Difficulty
                    GlassCard(padding: SWSpacing.md) {
                        VStack(alignment: .leading, spacing: SWSpacing.md) {
                            HStack(spacing: SWSpacing.xs) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.swGradientPrimary)
                                
                                Text("Difficulty")
                                    .font(SWTypography.headline)
                                    .foregroundColor(.swTextPrimary)
                            }
                            
                            HStack(spacing: SWSpacing.sm) {
                                ForEach(Difficulty.allCases, id: \.self) { diff in
                                    ChipButton(
                                        title: diff.description,
                                        isSelected: viewModel.difficulty == diff
                                    ) {
                                        viewModel.difficulty = diff
                                    }
                                }
                            }
                            
                            Text(viewModel.difficulty.subtitle)
                                .font(SWTypography.caption)
                                .foregroundColor(.swTextSecondary)
                        }
                    }
                    
                    // Liar Options (Word Mode only)
                    if viewModel.gameMode == .word {
                        VStack(spacing: SWSpacing.sm) {
                            ToggleCard(
                                title: "Show Category to Liar",
                                isOn: Binding(
                                    get: { viewModel.showCategoryToLiar },
                                    set: { viewModel.showCategoryToLiar = $0 }
                                ),
                                subtitle: "Liar sees the category name",
                                icon: "tag"
                            )
                            
                            ToggleCard(
                                title: "Show Hint to Liar",
                                isOn: Binding(
                                    get: { viewModel.showHintToLiar },
                                    set: { viewModel.showHintToLiar = $0 }
                                ),
                                subtitle: "Liar sees a vague hint",
                                icon: "lightbulb"
                            )
                        }
                    }
                    
                    // Liar Never Goes First
                    ToggleCard(
                        title: "Liar Never Goes First",
                        isOn: Binding(
                            get: { viewModel.liarNeverGoesFirst },
                            set: { viewModel.liarNeverGoesFirst = $0 }
                        ),
                        subtitle: "Starting player is always innocent",
                        icon: "arrow.right.circle"
                    )
                    
                    // Reset Button
                    Button(action: { showResetAlert = true }) {
                        Text("Reset to Defaults")
                            .font(SWTypography.subheadline)
                            .foregroundColor(.swDanger)
                    }
                    .padding(.top, SWSpacing.md)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, SWSpacing.lg)
                .padding(.top, SWSpacing.md)
            }
            
            // Start Game Button
            VStack {
                Spacer()
                
                NavigationLink(destination: PlayerNamesView(
                    playerCount: viewModel.playerCount,
                    settings: viewModel.settings
                )) {
                    PrimaryButtonContent(title: "Continue", icon: "arrow.right")
                }
                .disabled(!viewModel.isValid)
                .opacity(viewModel.isValid ? 1 : 0.5)
                .padding(.horizontal, SWSpacing.lg)
                .padding(.bottom, SWSpacing.lg)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.swBackground],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .allowsHitTesting(false)
                )
            }
        }
        .navigationTitle("Game Setup")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCategorySelection) {
            CategorySelectionView(viewModel: viewModel)
        }
        .alert("Reset Settings", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetToDefaults()
            }
        } message: {
            Text("This will reset all settings to their default values.")
        }
    }
}

struct GameModeRow: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SWSpacing.md) {
                Image(systemName: mode.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .swGlowPurple : .swTextSecondary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: SWSpacing.xxxs) {
                    Text(mode.displayName)
                        .font(SWTypography.headline)
                        .foregroundColor(.swTextPrimary)
                    
                    Text(mode.subtitle)
                        .font(SWTypography.caption)
                        .foregroundColor(.swTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .swGlowPurple : .swTextSecondary.opacity(0.5))
            }
            .padding(SWSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: SWRadius.md)
                    .fill(isSelected 
                        ? (colorScheme == .dark ? Color.white.opacity(0.08) : Color.swGlowPurple.opacity(0.08))
                        : Color.clear
                    )
            )
        }
    }
}

#Preview {
    NavigationStack {
        GameSettingsView()
    }
}
