//
//  PlayerAvatar.swift
//  ShadowWord
//
//  Player avatar and list item components
//

import SwiftUI

struct PlayerAvatar: View {
    let name: String
    var size: CGFloat = 48
    var showBorder: Bool = false
    var borderColor: Color = .swGlowPurple
    var isHighlighted: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var initials: String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    
    private var backgroundColor: Color {
        // Generate consistent color based on name
        let hash = abs(name.hashValue)
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.6, brightness: colorScheme == .dark ? 0.7 : 0.8)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            backgroundColor,
                            backgroundColor.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(initials)
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .overlay(
            Circle()
                .strokeBorder(
                    showBorder ? borderColor : Color.clear,
                    lineWidth: 3
                )
        )
        .shadow(
            color: isHighlighted ? borderColor.opacity(0.5) : .clear,
            radius: isHighlighted ? 10 : 0
        )
    }
}

// MARK: - Player List Row

struct PlayerListRow: View {
    let player: Player
    var showVoteCount: Bool = false
    var voteCount: Int = 0
    var isSelected: Bool = false
    var isRevealed: Bool = false
    var isLiar: Bool = false
    var onTap: (() -> Void)? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            HapticsService.shared.selection()
            onTap?()
        }) {
            HStack(spacing: SWSpacing.md) {
                PlayerAvatar(
                    name: player.name,
                    size: 44,
                    showBorder: isSelected,
                    borderColor: isSelected ? .swGlowPurple : .clear
                )
                
                VStack(alignment: .leading, spacing: SWSpacing.xxs) {
                    Text(player.name)
                        .font(SWTypography.headline)
                        .foregroundColor(.swTextPrimary)
                    
                    if isRevealed {
                        Text(isLiar ? "🎭 The Liar" : "✓ Innocent")
                            .font(SWTypography.caption)
                            .foregroundColor(isLiar ? .swDanger : .swSuccess)
                    }
                }
                
                Spacer()
                
                if showVoteCount {
                    Text("\(voteCount)")
                        .font(SWTypography.title3)
                        .foregroundColor(.swTextSecondary)
                        .frame(width: 32)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.swGradientPrimary)
                }
            }
            .padding(.horizontal, SWSpacing.md)
            .padding(.vertical, SWSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: SWRadius.lg)
                    .fill(
                        isSelected
                            ? (colorScheme == .dark 
                                ? Color.white.opacity(0.1) 
                                : Color.swGlowPurple.opacity(0.1))
                            : Color.clear
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: SWRadius.lg)
                    .strokeBorder(
                        isSelected 
                            ? Color.swGlowPurple.opacity(0.5) 
                            : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .disabled(onTap == nil)
    }
}

// MARK: - Compact Player Chip

struct PlayerChip: View {
    let name: String
    var isLiar: Bool = false
    var showRole: Bool = false
    
    var body: some View {
        HStack(spacing: SWSpacing.xs) {
            PlayerAvatar(name: name, size: 28)
            
            Text(name)
                .font(SWTypography.subheadline)
                .foregroundColor(.swTextPrimary)
            
            if showRole && isLiar {
                Image(systemName: "theatermasks.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.swDanger)
            }
        }
        .padding(.horizontal, SWSpacing.sm)
        .padding(.vertical, SWSpacing.xs)
        .background(
            Capsule()
                .fill(Color.swCardBackground)
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    isLiar && showRole 
                        ? Color.swDanger.opacity(0.5) 
                        : Color.white.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        
        VStack(spacing: SWSpacing.lg) {
            HStack(spacing: SWSpacing.md) {
                PlayerAvatar(name: "Alice", size: 64)
                PlayerAvatar(name: "Bob Johnson", size: 64, showBorder: true)
                PlayerAvatar(name: "Charlie", size: 64, borderColor: .swSuccess, isHighlighted: true)
            }
            
            GlassCard {
                VStack(spacing: SWSpacing.sm) {
                    PlayerListRow(
                        player: Player(id: UUID(), name: "Alice"),
                        isSelected: true
                    ) {}
                    
                    Divider()
                    
                    PlayerListRow(
                        player: Player(id: UUID(), name: "Bob"),
                        showVoteCount: true,
                        voteCount: 3
                    ) {}
                    
                    Divider()
                    
                    PlayerListRow(
                        player: Player(id: UUID(), name: "Charlie"),
                        isRevealed: true,
                        isLiar: true
                    ) {}
                }
            }
            
            HStack {
                PlayerChip(name: "Alice")
                PlayerChip(name: "Bob", isLiar: true, showRole: true)
            }
        }
        .padding()
    }
}
