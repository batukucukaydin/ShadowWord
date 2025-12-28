//
//  CounterView.swift
//  ShadowWord
//
//  Number counter/stepper component
//

import SwiftUI

struct CounterView: View {
    let title: String
    @Binding var value: Int
    var range: ClosedRange<Int>
    var subtitle: String? = nil
    var icon: String? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GlassCard(padding: SWSpacing.md) {
            HStack {
                // Label section
                VStack(alignment: .leading, spacing: SWSpacing.xxs) {
                    HStack(spacing: SWSpacing.xs) {
                        if let icon = icon {
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.swGradientPrimary)
                        }
                        
                        Text(title)
                            .font(SWTypography.headline)
                            .foregroundColor(.swTextPrimary)
                    }
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(SWTypography.caption)
                            .foregroundColor(.swTextSecondary)
                    }
                }
                
                Spacer()
                
                // Counter controls
                HStack(spacing: SWSpacing.md) {
                    // Decrease button
                    Button(action: {
                        if value > range.lowerBound {
                            value -= 1
                            HapticsService.shared.impact(.light)
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(value > range.lowerBound ? .swTextPrimary : .swTextSecondary.opacity(0.5))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark 
                                        ? Color.white.opacity(0.1) 
                                        : Color.black.opacity(0.05))
                            )
                    }
                    .disabled(value <= range.lowerBound)
                    
                    // Value display
                    Text("\(value)")
                        .font(SWTypography.counter)
                        .foregroundStyle(Color.swGradientPrimary)
                        .frame(minWidth: 50)
                        .contentTransition(.numericText())
                    
                    // Increase button
                    Button(action: {
                        if value < range.upperBound {
                            value += 1
                            HapticsService.shared.impact(.light)
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(value < range.upperBound ? .swTextPrimary : .swTextSecondary.opacity(0.5))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark 
                                        ? Color.white.opacity(0.1) 
                                        : Color.black.opacity(0.05))
                            )
                    }
                    .disabled(value >= range.upperBound)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                if value < range.upperBound { value += 1 }
            case .decrement:
                if value > range.lowerBound { value -= 1 }
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Toggle Card

struct ToggleCard: View {
    let title: String
    @Binding var isOn: Bool
    var subtitle: String? = nil
    var icon: String? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GlassCard(padding: SWSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: SWSpacing.xxs) {
                    HStack(spacing: SWSpacing.xs) {
                        if let icon = icon {
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.swGradientPrimary)
                        }
                        
                        Text(title)
                            .font(SWTypography.headline)
                            .foregroundColor(.swTextPrimary)
                    }
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(SWTypography.caption)
                            .foregroundColor(.swTextSecondary)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .tint(Color.swGlowPurple)
                    .labelsHidden()
                    .onChange(of: isOn) { _, _ in
                        HapticsService.shared.selection()
                    }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(isOn ? "on" : "off")")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            isOn.toggle()
        }
    }
}

// MARK: - Selector Card

struct SelectorCard<T: Hashable & CustomStringConvertible>: View {
    let title: String
    let options: [T]
    @Binding var selection: T
    var subtitle: String? = nil
    var icon: String? = nil
    
    var body: some View {
        GlassCard(padding: SWSpacing.md) {
            VStack(alignment: .leading, spacing: SWSpacing.md) {
                HStack(spacing: SWSpacing.xs) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.swGradientPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: SWSpacing.xxs) {
                        Text(title)
                            .font(SWTypography.headline)
                            .foregroundColor(.swTextPrimary)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(SWTypography.caption)
                                .foregroundColor(.swTextSecondary)
                        }
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: SWSpacing.sm) {
                    ForEach(options, id: \.self) { option in
                        ChipButton(
                            title: option.description,
                            isSelected: selection == option
                        ) {
                            selection = option
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        
        VStack(spacing: SWSpacing.lg) {
            CounterView(
                title: "Players",
                value: .constant(6),
                range: 3...100,
                subtitle: "Minimum 3 players required",
                icon: "person.3.fill"
            )
            
            CounterView(
                title: "Liars",
                value: .constant(1),
                range: 1...3,
                icon: "theatermasks.fill"
            )
            
            ToggleCard(
                title: "Show Category to Liar",
                isOn: .constant(true),
                subtitle: "Liar will see the category name",
                icon: "tag.fill"
            )
        }
        .padding()
    }
}
