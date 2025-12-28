//
//  GlassCard.swift
//  ShadowWord
//
//  Reusable glassmorphism card component
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = SWRadius.xl
    var padding: CGFloat = SWSpacing.lg
    var glowColor: Color? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        cornerRadius: CGFloat = SWRadius.xl,
        padding: CGFloat = SWSpacing.lg,
        glowColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.glowColor = glowColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Base blur material
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(colorScheme == .dark 
                            ? .ultraThinMaterial 
                            : .thinMaterial)
                    
                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.1 : 0.5),
                                    Color.white.opacity(colorScheme == .dark ? 0.02 : 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.3 : 0.6),
                                    Color.white.opacity(colorScheme == .dark ? 0.1 : 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 10, x: 0, y: 5)
            .overlay(
                Group {
                    if let glow = glowColor {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(glow.opacity(0.5), lineWidth: 2)
                            .blur(radius: 4)
                    }
                }
            )
    }
}

// MARK: - Specialized Glass Cards

struct RoleCard: View {
    let isLiar: Bool
    let content: String
    let subtitle: String?
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: SWSpacing.lg) {
            // Role icon
            Image(systemName: isLiar ? "theatermasks.fill" : "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(isLiar ? Color.swGradientLiar : Color.swGradientInnocent)
                .swGlow(color: isLiar ? .swDanger : .swSuccess, radius: 20)
            
            // Role title
            Text(isLiar ? "You Are The Liar" : "You Are Innocent")
                .font(SWTypography.title2)
                .foregroundColor(isLiar ? .swDanger : .swSuccess)
            
            // Content (word/question or liar info)
            Text(content)
                .font(SWTypography.secretWord)
                .foregroundColor(.swTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, SWSpacing.sm)
            
            // Optional subtitle (category/hint for liar)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(SWTypography.subheadline)
                    .foregroundColor(.swTextSecondary)
            }
        }
        .padding(SWSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: SWRadius.xxl)
                    .fill(colorScheme == .dark ? .ultraThinMaterial : .thinMaterial)
                
                RoundedRectangle(cornerRadius: SWRadius.xxl)
                    .fill(
                        LinearGradient(
                            colors: [
                                (isLiar ? Color.swDanger : Color.swSuccess).opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                RoundedRectangle(cornerRadius: SWRadius.xxl)
                    .strokeBorder(
                        (isLiar ? Color.swDanger : Color.swSuccess).opacity(0.3),
                        lineWidth: 2
                    )
            }
        )
        .swGlow(color: isLiar ? .swDanger : .swSuccess, radius: 25)
    }
}

#Preview {
    ZStack {
        Color.swBackground.ignoresSafeArea()
        
        VStack(spacing: SWSpacing.lg) {
            GlassCard {
                VStack(alignment: .leading, spacing: SWSpacing.sm) {
                    Text("Settings Card")
                        .font(SWTypography.headline)
                        .foregroundColor(.swTextPrimary)
                    Text("This is a glass card example")
                        .font(SWTypography.body)
                        .foregroundColor(.swTextSecondary)
                }
            }
            
            RoleCard(
                isLiar: false,
                content: "Elephant",
                subtitle: "Category: Animals"
            )
            
            RoleCard(
                isLiar: true,
                content: "Blend in...",
                subtitle: "Category: Animals"
            )
            .scaleEffect(0.8)
        }
        .padding()
    }
}
