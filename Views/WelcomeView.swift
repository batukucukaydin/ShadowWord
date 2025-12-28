//
//  WelcomeView.swift
//  ShadowWord
//

import SwiftUI

struct WelcomeView: View {
    @State private var showSettings = false
    @State private var showHowToPlay = false
    @State private var animateTitle = false
    @State private var animateButtons = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                VStack(spacing: SWSpacing.xl) {
                    Spacer()
                    
                    // App Logo & Title
                    VStack(spacing: SWSpacing.md) {
                        // Logo placeholder
                        ZStack {
                            Circle()
                                .fill(Color.swGradientPrimary)
                                .frame(width: 120, height: 120)
                                .swGlow(color: .swGlowPurple, radius: 30)
                            
                            Image(systemName: "theatermasks.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animateTitle ? 1 : 0.8)
                        .opacity(animateTitle ? 1 : 0)
                        
                        Text("ShadowWord")
                            .font(SWTypography.largeTitle)
                            .foregroundColor(.swTextPrimary)
                            .opacity(animateTitle ? 1 : 0)
                            .offset(y: animateTitle ? 0 : 20)
                        
                        Text("A party game of clues, bluffing & deduction")
                            .font(SWTypography.subheadline)
                            .foregroundColor(.swTextSecondary)
                            .multilineTextAlignment(.center)
                            .opacity(animateTitle ? 1 : 0)
                            .offset(y: animateTitle ? 0 : 10)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: SWSpacing.md) {
                        NavigationLink(destination: GameSettingsView()) {
                            PrimaryButtonContent(title: "Get Started", icon: "play.fill")
                        }
                        .opacity(animateButtons ? 1 : 0)
                        .offset(y: animateButtons ? 0 : 30)
                        
                        NavigationLink(destination: HowToPlayView()) {
                            PrimaryButtonContent(title: "How to Play", icon: "questionmark.circle.fill", style: .ghost)
                        }
                        .opacity(animateButtons ? 1 : 0)
                        .offset(y: animateButtons ? 0 : 30)
                    }
                    .padding(.horizontal, SWSpacing.lg)
                    .padding(.bottom, SWSpacing.xxl)
                }
                
                // Theme Toggle Button
                VStack {
                    HStack {
                        Spacer()
                        ThemeToggleButton(currentTheme: $appTheme)
                            .padding(.trailing, SWSpacing.lg)
                            .padding(.top, SWSpacing.md)
                    }
                    Spacer()
                }
            }
            .preferredColorScheme(appTheme.colorScheme)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                    animateTitle = true
                }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.5)) {
                    animateButtons = true
                }
            }
        }
    }
}

// MARK: - Theme Toggle

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    var next: AppTheme {
        switch self {
        case .system: return .light
        case .light: return .dark
        case .dark: return .system
        }
    }
}

struct ThemeToggleButton: View {
    @Binding var currentTheme: AppTheme
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            HapticsService.shared.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentTheme = currentTheme.next
            }
        }) {
            Image(systemName: currentTheme.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.swTextPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.2 : 0.4), lineWidth: 1)
                )
        }
        .accessibilityLabel("Toggle theme")
        .accessibilityHint("Current theme: \(currentTheme.rawValue)")
    }
}

// Helper view for NavigationLink styled buttons
struct PrimaryButtonContent: View {
    let title: String
    var icon: String? = nil
    var style: PrimaryButton.ButtonStyle = .primary
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: SWSpacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Text(title)
                .font(SWTypography.buttonTitle)
        }
        .foregroundColor(foregroundColor)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: SWRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: SWRadius.lg)
                .strokeBorder(borderColor, lineWidth: style == .ghost ? 2 : 0)
        )
        .shadow(
            color: shadowColor,
            radius: style == .ghost ? 0 : 15,
            x: 0,
            y: style == .ghost ? 0 : 5
        )
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [Color.swGlowPurple, Color.swGlowBlue],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .ghost:
            Color.clear
        default:
            Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .ghost:
            return .swGlowPurple
        default:
            return .swTextPrimary
        }
    }
    
    private var borderColor: Color {
        style == .ghost ? .swGlowPurple.opacity(0.5) : .clear
    }
    
    private var shadowColor: Color {
        style == .primary ? .swGlowPurple.opacity(0.4) : .clear
    }
}

#Preview {
    WelcomeView()
}
