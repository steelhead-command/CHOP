import SwiftUI

struct AxeView: View {
    let state: AxeAnimationState
    var axeTier: AxeTier = .basic
    var axeType: AxeType = .balanced

    var body: some View {
        ZStack {
            // Axe handle
            AxeHandleView(tier: axeTier)

            // Axe head
            AxeHeadView(tier: axeTier, type: axeType)
                .offset(x: 0, y: -60)
        }
        .rotationEffect(.degrees(state.rotation), anchor: .bottom)
        .offset(y: state.offsetY)
        .scaleEffect(state.scale)
    }
}

// MARK: - Axe Handle

struct AxeHandleView: View {
    let tier: AxeTier

    var handleColor: Color {
        switch tier {
        case .basic: return Color(hex: "8B6914")
        case .mid: return Color(hex: "6B4D32")
        case .premium: return Color(hex: "5C4612")
        case .master: return Color(hex: "4A3728")
        case .diamond: return Color(hex: "4A90D9")
        }
    }

    var body: some View {
        ZStack {
            // Main handle
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [handleColor, handleColor.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 12, height: 120)

            // Handle wrap/grip
            VStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 14, height: 4)
                }
            }
            .offset(y: 30)

            // Pommel
            Ellipse()
                .fill(handleColor.opacity(0.8))
                .frame(width: 16, height: 10)
                .offset(y: 58)
        }
    }
}

// MARK: - Axe Head

struct AxeHeadView: View {
    let tier: AxeTier
    let type: AxeType

    var headColor: Color {
        switch tier {
        case .basic: return Color(hex: "6B7B8C")     // Iron gray
        case .mid: return Color(hex: "8C8C8C")      // Steel
        case .premium: return Color(hex: "B8860B")   // Dark golden
        case .master: return Color(hex: "4B0082")    // Indigo
        case .diamond: return Color(hex: "87CEEB")   // Sky blue
        }
    }

    var edgeColor: Color {
        switch tier {
        case .basic: return Color(hex: "9CA3AF")
        case .mid: return Color(hex: "C0C0C0")
        case .premium: return Color(hex: "DAA520")
        case .master: return Color(hex: "8A2BE2")    // Blue violet
        case .diamond: return Color(hex: "ADD8E6")
        }
    }

    var headWidth: CGFloat {
        switch type {
        case .balanced: return 50
        case .sharp: return 45
        case .heavy: return 60
        case .diamond: return 55  // Diamond axe
        }
    }

    var body: some View {
        ZStack {
            // Main head shape
            AxeHeadShape(type: type)
                .fill(
                    LinearGradient(
                        colors: [headColor.opacity(0.9), headColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: headWidth, height: 45)

            // Edge highlight
            AxeEdgeShape(type: type)
                .fill(edgeColor)
                .frame(width: headWidth - 5, height: 40)
                .offset(x: -5)

            // Socket where handle connects
            Ellipse()
                .fill(Color.black.opacity(0.3))
                .frame(width: 10, height: 20)
                .offset(x: 15, y: 5)

            // Diamond sparkle effect
            if tier == .diamond {
                DiamondSparkles()
            }
        }
    }
}

// MARK: - Axe Head Shape

struct AxeHeadShape: Shape {
    let type: AxeType

    func path(in rect: CGRect) -> Path {
        var path = Path()

        switch type {
        case .balanced:
            // Standard axe shape
            path.move(to: CGPoint(x: rect.midX + 5, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 10))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - 5, y: rect.maxY - 10),
                control: CGPoint(x: rect.maxX + 5, y: rect.midY)
            )
            path.addLine(to: CGPoint(x: rect.midX + 5, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX - 5, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + 10, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX - 5, y: rect.minY))

        case .sharp:
            // Thinner, more pointed
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX + 5, y: rect.midY - 5))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.midY + 5),
                control: CGPoint(x: rect.maxX + 10, y: rect.midY)
            )
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX - 10, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + 5, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX - 10, y: rect.minY))

        case .heavy:
            // Wider, more substantial
            path.move(to: CGPoint(x: rect.midX + 10, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 5))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - 5, y: rect.maxY - 5),
                control: CGPoint(x: rect.maxX + 8, y: rect.midY)
            )
            path.addLine(to: CGPoint(x: rect.midX + 10, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX - 15, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX - 15, y: rect.minY))

        case .diamond:
            // Diamond axe - elegant balanced shape
            path.move(to: CGPoint(x: rect.midX + 5, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 10))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - 5, y: rect.maxY - 10),
                control: CGPoint(x: rect.maxX + 5, y: rect.midY)
            )
            path.addLine(to: CGPoint(x: rect.midX + 5, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX - 5, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + 10, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX - 5, y: rect.minY))
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Axe Edge Shape

struct AxeEdgeShape: Shape {
    let type: AxeType

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Sharp edge on the cutting side
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 8))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - 8),
            control: CGPoint(x: rect.minX - 8, y: rect.midY)
        )
        path.addLine(to: CGPoint(x: rect.minX + 10, y: rect.maxY - 5))
        path.addLine(to: CGPoint(x: rect.minX + 10, y: rect.minY + 5))
        path.closeSubpath()

        return path
    }
}

// MARK: - Diamond Sparkles

struct DiamondSparkles: View {
    @State private var sparklePhase: CGFloat = 0

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.8))
                    .offset(
                        x: CGFloat([-15, 5, -5][i]),
                        y: CGFloat([-10, 0, 12][i])
                    )
                    .opacity(Double((sparklePhase + CGFloat(i) * 0.33).truncatingRemainder(dividingBy: 1.0)))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                sparklePhase = 1
            }
        }
    }
}

// MARK: - Previews

#Preview("Axe - Idle") {
    AxeView(state: .idle)
        .padding()
        .background(Color.chopBackground)
}

#Preview("Axe - Tracking") {
    AxeView(state: .tracking(progress: 0.5))
        .padding()
        .background(Color.chopBackground)
}

#Preview("Axe - Impact") {
    AxeView(state: .impact)
        .padding()
        .background(Color.chopBackground)
}

#Preview("Axe - All Tiers") {
    HStack(spacing: 40) {
        AxeView(state: .idle, axeTier: .basic, axeType: .balanced)
        AxeView(state: .idle, axeTier: .mid, axeType: .sharp)
        AxeView(state: .idle, axeTier: .premium, axeType: .heavy)
        AxeView(state: .idle, axeTier: .diamond, axeType: .balanced)
    }
    .padding()
    .background(Color.chopBackground)
}

#Preview("Axe - All Types") {
    HStack(spacing: 40) {
        VStack {
            AxeView(state: .idle, axeTier: .mid, axeType: .balanced)
            Text("Balanced").font(.caption)
        }
        VStack {
            AxeView(state: .idle, axeTier: .mid, axeType: .sharp)
            Text("Sharp").font(.caption)
        }
        VStack {
            AxeView(state: .idle, axeTier: .mid, axeType: .heavy)
            Text("Heavy").font(.caption)
        }
    }
    .padding()
    .background(Color.chopBackground)
}
