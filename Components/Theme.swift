//
//  Theme.swift
//  ShadowWord
//
//  Design system for ShadowWord app
//

import SwiftUI

// MARK: - Color Palette
extension Color {
    // Primary accent colors
    static let swAccentPrimary = Color("AccentPrimary", bundle: nil)
    static let swAccentSecondary = Color("AccentSecondary", bundle: nil)
    
    // Adaptive colors for both themes
    static var swBackground: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1)
                : UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1)
        })
    }
    
    static var swCardBackground: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 0.7)
                : UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        })
    }
    
    static var swTextPrimary: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1)
        })
    }
    
    static var swTextSecondary: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.7, alpha: 1)
                : UIColor(white: 0.4, alpha: 1)
        })
    }
    
    static var swGlowPurple: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.6, green: 0.4, blue: 1, alpha: 1)
                : UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1)
        })
    }
    
    static var swGlowBlue: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.3, green: 0.5, blue: 1, alpha: 1)
                : UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1)
        })
    }
    
    static var swSuccess: Color {
        Color(red: 0.3, green: 0.85, blue: 0.5)
    }
    
    static var swDanger: Color {
        Color(red: 1, green: 0.35, blue: 0.4)
    }
    
    static var swWarning: Color {
        Color(red: 1, green: 0.75, blue: 0.3)
    }
    
    // Gradient presets
    static var swGradientPrimary: LinearGradient {
        LinearGradient(
            colors: [swGlowPurple, swGlowBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var swGradientBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(uiColor: UIColor { traits in
                    traits.userInterfaceStyle == .dark
                        ? UIColor(red: 0.08, green: 0.05, blue: 0.15, alpha: 1)
                        : UIColor(red: 0.92, green: 0.90, blue: 0.98, alpha: 1)
                }),
                Color(uiColor: UIColor { traits in
                    traits.userInterfaceStyle == .dark
                        ? UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1)
                        : UIColor(red: 0.98, green: 0.98, blue: 1, alpha: 1)
                })
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var swGradientLiar: LinearGradient {
        LinearGradient(
            colors: [swDanger, Color(red: 0.8, green: 0.2, blue: 0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var swGradientInnocent: LinearGradient {
        LinearGradient(
            colors: [swSuccess, Color(red: 0.2, green: 0.7, blue: 0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Typography
struct SWTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    
    // Special styles
    static let secretWord = Font.system(size: 32, weight: .bold, design: .rounded)
    static let roleTitle = Font.system(size: 40, weight: .heavy, design: .rounded)
    static let buttonTitle = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let counter = Font.system(size: 48, weight: .bold, design: .monospaced)
}

// MARK: - Spacing
struct SWSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius
struct SWRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 18
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let full: CGFloat = 100
}

// MARK: - Shadows
struct SWShadow {
    static func glow(color: Color = .swGlowPurple, radius: CGFloat = 20) -> some View {
        EmptyView().shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
    }
    
    static let cardShadow = Shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    static let buttonShadow = Shadow(color: .swGlowPurple.opacity(0.4), radius: 15, x: 0, y: 5)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    func swShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func swGlow(color: Color = .swGlowPurple, radius: CGFloat = 15) -> some View {
        self.shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
    }
}
