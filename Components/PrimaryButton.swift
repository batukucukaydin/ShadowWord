//
//  PrimaryButton.swift
//  ShadowWord
//
//  Reusable button components
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    enum ButtonStyle {
        case primary
        case secondary
        case danger
        case success
        case ghost
    }
    
    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                HapticsService.shared.impact(.medium)
                action()
            }
        }) {
            HStack(spacing: SWSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    Text(title)
                        .font(SWTypography.buttonTitle)
                }
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
            .opacity(isDisabled ? 0.5 : 1)
        }
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isDisabled ? "Button disabled" : "Double tap to activate")
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
        case .secondary:
            colorScheme == .dark
                ? Color.white.opacity(0.15)
                : Color.black.opacity(0.08)
        case .danger:
            Color.swGradientLiar
        case .success:
            Color.swGradientInnocent
        case .ghost:
            Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .danger, .success:
            return .white
        case .secondary:
            return .swTextPrimary
        case .ghost:
            return .swGlowPurple
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .ghost:
            return .swGlowPurple.opacity(0.5)
        default:
            return .clear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return .swGlowPurple.opacity(0.4)
        case .danger:
            return .swDanger.opacity(0.4)
        case .success:
            return .swSuccess.opacity(0.4)
        default:
            return .clear
        }
    }
}

// MARK: - Icon Button

struct IconButton: View {
    let icon: String
    var size: CGFloat = 44
    var style: PrimaryButton.ButtonStyle = .secondary
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(style == .primary ? .white : .swTextPrimary)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(
                            style == .primary
                                ? AnyShapeStyle(Color.swGradientPrimary)
                                : AnyShapeStyle(colorScheme == .dark 
                                    ? Color.white.opacity(0.1) 
                                    : Color.black.opacity(0.05))
                        )
                )
                .overlay(
                    Circle()
                        .strokeBorder(
                            Color.white.opacity(colorScheme == .dark ? 0.2 : 0.5),
                            lineWidth: 1
                        )
                )
        }
        .accessibilityLabel(icon)
    }
}

// MARK: - Chip Button

struct ChipButton: View {
    let title: String
    var icon: String? = nil
    var isSelected: Bool = false
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            HapticsService.shared.selection()
            action()
        }) {
            HStack(spacing: SWSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                
                Text(title)
                    .font(SWTypography.subheadline)
            }
            .foregroundColor(isSelected ? .white : .swTextPrimary)
            .padding(.horizontal, SWSpacing.md)
            .padding(.vertical, SWSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected 
                        ? AnyShapeStyle(Color.swGradientPrimary) 
                        : AnyShapeStyle(colorScheme == .dark 
                            ? Color.white.opacity(0.1) 
                            : Color.black.opacity(0.05)))
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected 
                            ? Color.swGlowPurple.opacity(0.5) 
                            : Color.white.opacity(colorScheme == .dark ? 0.2 : 0.3),
                        lineWidth: 1
                    )
            )
        }
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ZStack {
        Color.swBackground.ignoresSafeArea()
        
        VStack(spacing: SWSpacing.lg) {
            PrimaryButton(title: "Get Started", icon: "play.fill") {
                print("Tapped")
            }
            
            PrimaryButton(title: "Settings", style: .secondary) {
                print("Tapped")
            }
            
            PrimaryButton(title: "Danger Zone", style: .danger) {
                print("Tapped")
            }
            
            PrimaryButton(title: "Ghost Button", style: .ghost) {
                print("Tapped")
            }
            
            PrimaryButton(title: "Loading...", isLoading: true) {
                print("Tapped")
            }
            
            HStack(spacing: SWSpacing.md) {
                IconButton(icon: "gear") {}
                IconButton(icon: "info.circle", style: .primary) {}
            }
            
            HStack(spacing: SWSpacing.sm) {
                ChipButton(title: "Easy", isSelected: true) {}
                ChipButton(title: "Medium") {}
                ChipButton(title: "Hard") {}
            }
        }
        .padding()
    }
}
