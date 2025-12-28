//
//  HapticsService.swift
//  ShadowWord
//
//  Haptic feedback service
//

import UIKit

final class HapticsService {
    static let shared = HapticsService()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        // Prepare generators
        prepare()
    }
    
    func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - Impact Feedback
    
    enum ImpactStyle {
        case light
        case medium
        case heavy
    }
    
    func impact(_ style: ImpactStyle) {
        switch style {
        case .light:
            lightGenerator.impactOccurred()
        case .medium:
            mediumGenerator.impactOccurred()
        case .heavy:
            heavyGenerator.impactOccurred()
        }
    }
    
    // MARK: - Notification Feedback
    
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        selectionGenerator.selectionChanged()
    }
    
    // MARK: - Game-Specific Haptics
    
    func roleReveal(isLiar: Bool) {
        if isLiar {
            // Dramatic double tap for liar
            heavyGenerator.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.heavyGenerator.impactOccurred()
            }
        } else {
            // Single medium tap for innocent
            mediumGenerator.impactOccurred()
        }
    }
    
    func voteConfirm() {
        mediumGenerator.impactOccurred()
    }
    
    func resultReveal(liarWins: Bool) {
        if liarWins {
            // Warning pattern for liar winning
            notificationGenerator.notificationOccurred(.warning)
        } else {
            // Success pattern for group winning
            notificationGenerator.notificationOccurred(.success)
        }
    }
    
    func countdown() {
        lightGenerator.impactOccurred()
    }
    
    func buttonTap() {
        impact(.medium)
    }
}
