//
//  ParticleBackground.swift
//  ShadowWord
//
//  Animated particle/star background effect
//

import SwiftUI

struct ParticleBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var particles: [Particle] = []
    @State private var animationTimer: Timer?
    
    let particleCount: Int
    
    init(particleCount: Int = 50) {
        self.particleCount = particleCount
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient background
                backgroundGradient
                
                // Particles using Canvas for performance
                Canvas { context, size in
                    for particle in particles {
                        let rect = CGRect(
                            x: particle.x * size.width - particle.size / 2,
                            y: particle.y * size.height - particle.size / 2,
                            width: particle.size,
                            height: particle.size
                        )
                        
                        let color = colorScheme == .dark 
                            ? Color.white.opacity(particle.opacity)
                            : Color.swGlowPurple.opacity(particle.opacity * 0.5)
                        
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(color)
                        )
                    }
                }
            }
            .onAppear {
                initializeParticles()
                startAnimation()
            }
            .onDisappear {
                animationTimer?.invalidate()
            }
        }
        .ignoresSafeArea()
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark ? [
                Color(red: 0.08, green: 0.05, blue: 0.15),
                Color(red: 0.04, green: 0.04, blue: 0.12),
                Color(red: 0.02, green: 0.02, blue: 0.08)
            ] : [
                Color(red: 0.95, green: 0.93, blue: 1.0),
                Color(red: 0.98, green: 0.97, blue: 1.0),
                Color(red: 1.0, green: 0.99, blue: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func initializeParticles() {
        particles = (0..<particleCount).map { _ in
            Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...4),
                opacity: Double.random(in: 0.1...0.6),
                speed: Double.random(in: 0.0001...0.0005),
                direction: Double.random(in: 0...(2 * .pi)),
                twinklePhase: Double.random(in: 0...(2 * .pi)),
                twinkleSpeed: Double.random(in: 0.02...0.05)
            )
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            // Move particle
            particles[i].x += cos(particles[i].direction) * particles[i].speed
            particles[i].y += sin(particles[i].direction) * particles[i].speed
            
            // Twinkle effect
            particles[i].twinklePhase += particles[i].twinkleSpeed
            let twinkle = sin(particles[i].twinklePhase)
            particles[i].opacity = 0.2 + 0.4 * (twinkle + 1) / 2
            
            // Wrap around edges
            if particles[i].x < 0 { particles[i].x = 1 }
            if particles[i].x > 1 { particles[i].x = 0 }
            if particles[i].y < 0 { particles[i].y = 1 }
            if particles[i].y > 1 { particles[i].y = 0 }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: Double
    var direction: Double
    var twinklePhase: Double
    var twinkleSpeed: Double
}

// MARK: - Simple Floating Orbs (Alternative)

struct FloatingOrbs: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Large blurred orbs
                Circle()
                    .fill(Color.swGlowPurple.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(
                        x: animate ? 50 : -50,
                        y: animate ? -100 : 100
                    )
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3)
                
                Circle()
                    .fill(Color.swGlowBlue.opacity(0.25))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(
                        x: animate ? -30 : 30,
                        y: animate ? 80 : -80
                    )
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.7)
                
                Circle()
                    .fill(Color.swGlowPurple.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(
                        x: animate ? 40 : -40,
                        y: animate ? 60 : -60
                    )
                    .position(x: geometry.size.width * 0.6, y: geometry.size.height * 0.2)
            }
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 8)
                    .repeatForever(autoreverses: true)
                ) {
                    animate = true
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Combined Background

struct AnimatedBackground: View {
    var showParticles: Bool = true
    var showOrbs: Bool = true
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Color(red: 0.08, green: 0.05, blue: 0.15),
                    Color(red: 0.02, green: 0.02, blue: 0.08)
                ] : [
                    Color(red: 0.95, green: 0.93, blue: 1.0),
                    Color(red: 1.0, green: 0.99, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if showOrbs {
                FloatingOrbs()
            }
            
            if showParticles {
                ParticleBackground(particleCount: 40)
            }
        }
    }
}

#Preview {
    AnimatedBackground()
}
