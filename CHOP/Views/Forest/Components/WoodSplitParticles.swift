import SwiftUI

struct WoodSplitParticles: View {
    let woodType: WoodType
    @State private var particles: [WoodParticle] = []
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                WoodChipView(woodType: woodType, size: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }

    private func generateParticles() {
        particles = (0..<12).map { _ in
            WoodParticle(
                x: CGFloat.random(in: -30...30),
                y: CGFloat.random(in: -20...10),
                rotation: Double.random(in: 0...360),
                size: CGFloat.random(in: 8...20),
                velocityX: CGFloat.random(in: -80...80),
                velocityY: CGFloat.random(in: (-120)...(-60)),
                angularVelocity: Double.random(in: -360...360),
                opacity: 1.0
            )
        }
    }

    private func animateParticles() {
        isAnimating = true

        // Animate particles falling with gravity
        withAnimation(.easeOut(duration: 0.8)) {
            particles = particles.map { particle in
                var newParticle = particle
                newParticle.x += particle.velocityX * 0.5
                newParticle.y += particle.velocityY * -0.8 + 150  // Gravity effect
                newParticle.rotation += particle.angularVelocity * 0.8
                newParticle.opacity = 0
                return newParticle
            }
        }
    }
}

// MARK: - Wood Particle Data

struct WoodParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var size: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var angularVelocity: Double
    var opacity: Double
}

// MARK: - Wood Chip View

struct WoodChipView: View {
    let woodType: WoodType
    let size: CGFloat

    var body: some View {
        ZStack {
            // Chip shape
            WoodChipShape()
                .fill(woodType.color)
                .frame(width: size, height: size * 0.6)

            // Grain detail
            WoodChipShape()
                .fill(woodType.grainColor.opacity(0.5))
                .frame(width: size * 0.6, height: size * 0.3)
        }
    }
}

// MARK: - Wood Chip Shape

struct WoodChipShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Irregular polygon for wood chip
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.15, y: rect.minY + rect.height * 0.1))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.1, y: rect.maxY - rect.height * 0.15))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + rect.height * 0.1))
        path.closeSubpath()

        return path
    }
}

// MARK: - Sawdust Particles (bonus effect)

struct SawdustParticles: View {
    @State private var particles: [SawdustParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color(hex: "D4C4A8").opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }

    private func generateParticles() {
        particles = (0..<20).map { _ in
            SawdustParticle(
                x: CGFloat.random(in: -20...20),
                y: CGFloat.random(in: -10...10),
                size: CGFloat.random(in: 2...5),
                velocityX: CGFloat.random(in: -40...40),
                velocityY: CGFloat.random(in: (-60)...(-20)),
                opacity: Double.random(in: 0.5...0.8)
            )
        }
    }

    private func animateParticles() {
        withAnimation(.easeOut(duration: 0.6)) {
            particles = particles.map { particle in
                var newParticle = particle
                newParticle.x += particle.velocityX * 0.4
                newParticle.y += particle.velocityY * -0.6 + 80
                newParticle.opacity = 0
                return newParticle
            }
        }
    }
}

struct SawdustParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var opacity: Double
}

// MARK: - Previews

#Preview("Wood Split Particles - Soft") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        WoodSplitParticles(woodType: .soft)
    }
}

#Preview("Wood Split Particles - Hard") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        WoodSplitParticles(woodType: .hard)
    }
}

#Preview("Sawdust Effect") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        SawdustParticles()
    }
}

#Preview("Combined Split Effect") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        ZStack {
            SawdustParticles()
            WoodSplitParticles(woodType: .medium)
        }
    }
}
