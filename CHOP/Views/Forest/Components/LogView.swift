import SwiftUI

struct LogView: View {
    let woodType: WoodType
    let hasKnot: Bool
    let animationState: LogAnimationState

    // Default state for previews
    init(woodType: WoodType, hasKnot: Bool, animationState: LogAnimationState = .whole) {
        self.woodType = woodType
        self.hasKnot = hasKnot
        self.animationState = animationState
    }

    var body: some View {
        ZStack {
            switch animationState {
            case .splitting(let progress):
                // Two halves splitting apart
                HStack(spacing: progress * 20) {
                    LogHalfView(woodType: woodType, isLeft: true)
                        .offset(x: -animationState.splitOffset / 2)
                        .rotationEffect(.degrees(-Double(progress) * 15))

                    LogHalfView(woodType: woodType, isLeft: false)
                        .offset(x: animationState.splitOffset / 2)
                        .rotationEffect(.degrees(Double(progress) * 15))
                }
                .offset(y: progress * 30)  // Fall slightly

            case .removed:
                EmptyView()

            default:
                // Whole log
                WholeLogView(woodType: woodType, hasKnot: hasKnot)
                    .offset(x: animationState == .cracking ? CGFloat.random(in: -3...3) : animationState.shakeOffset)
            }
        }
        .opacity(animationState.opacity)
    }
}

// MARK: - Whole Log

struct WholeLogView: View {
    let woodType: WoodType
    let hasKnot: Bool

    var body: some View {
        ZStack {
            // Main log body
            RoundedRectangle(cornerRadius: 8)
                .fill(woodType.color)
                .frame(width: 140, height: 80)

            // Bark edges (top and bottom)
            VStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(woodType.barkColor)
                    .frame(width: 140, height: 8)

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(woodType.barkColor)
                    .frame(width: 140, height: 8)
            }
            .frame(height: 80)

            // Wood grain lines
            HStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { i in
                    WoodGrainLine(color: woodType.grainColor)
                        .offset(y: CGFloat(i % 2 == 0 ? -5 : 5))
                }
            }
            .frame(width: 120)

            // End grain (circles visible on cut end)
            HStack {
                EndGrainView(woodType: woodType)
                    .frame(width: 20, height: 60)
                    .offset(x: -55)

                Spacer()

                EndGrainView(woodType: woodType)
                    .frame(width: 20, height: 60)
                    .offset(x: 55)
            }
            .frame(width: 140)

            // Knot (if present)
            if hasKnot {
                KnotView()
                    .offset(x: 20, y: -5)
            }
        }
    }
}

// MARK: - Log Half (for split animation)

struct LogHalfView: View {
    let woodType: WoodType
    let isLeft: Bool

    var body: some View {
        ZStack {
            // Half log body
            UnevenRectangle(cornerRadius: 6, isLeft: isLeft)
                .fill(woodType.color)
                .frame(width: 65, height: 80)

            // Bark on outer edge
            VStack {
                UnevenRectangle(cornerRadius: 3, isLeft: isLeft)
                    .fill(woodType.barkColor)
                    .frame(width: 65, height: 6)

                Spacer()

                UnevenRectangle(cornerRadius: 3, isLeft: isLeft)
                    .fill(woodType.barkColor)
                    .frame(width: 65, height: 6)
            }
            .frame(height: 80)

            // Fresh cut face (lighter color where split)
            if isLeft {
                Rectangle()
                    .fill(woodType.grainColor.opacity(0.8))
                    .frame(width: 8, height: 70)
                    .offset(x: 28)
            } else {
                Rectangle()
                    .fill(woodType.grainColor.opacity(0.8))
                    .frame(width: 8, height: 70)
                    .offset(x: -28)
            }

            // Some grain lines
            HStack(spacing: 10) {
                ForEach(0..<2, id: \.self) { i in
                    WoodGrainLine(color: woodType.grainColor)
                        .offset(y: CGFloat(i % 2 == 0 ? -3 : 3))
                }
            }
            .frame(width: 40)
            .offset(x: isLeft ? -10 : 10)
        }
    }
}

// MARK: - Helper Shapes

struct UnevenRectangle: Shape {
    let cornerRadius: CGFloat
    let isLeft: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()

        if isLeft {
            // Left half - jagged right edge
            path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - 5, y: rect.midY * 0.3))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY * 0.6))
            path.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - 3, y: rect.midY * 1.4))
            path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
                             control: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
                             control: CGPoint(x: rect.minX, y: rect.minY))
        } else {
            // Right half - jagged left edge
            path.move(to: CGPoint(x: rect.minX + 10, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
                             control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
                             control: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + 10, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + 3, y: rect.midY * 1.4))
            path.addLine(to: CGPoint(x: rect.minX + 8, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY * 0.6))
            path.addLine(to: CGPoint(x: rect.minX + 5, y: rect.midY * 0.3))
        }

        path.closeSubpath()
        return path
    }
}

struct WoodGrainLine: View {
    let color: Color

    var body: some View {
        Capsule()
            .fill(color.opacity(0.4))
            .frame(width: 2, height: CGFloat.random(in: 30...50))
    }
}

struct EndGrainView: View {
    let woodType: WoodType

    var body: some View {
        ZStack {
            // Base end grain color
            Capsule()
                .fill(woodType.color.opacity(0.9))

            // Growth rings
            ForEach(0..<3, id: \.self) { i in
                Ellipse()
                    .stroke(woodType.grainColor.opacity(0.5), lineWidth: 1)
                    .frame(width: CGFloat(5 + i * 4), height: CGFloat(15 + i * 12))
            }
        }
    }
}

struct KnotView: View {
    var body: some View {
        ZStack {
            // Dark knot center
            Ellipse()
                .fill(Color(hex: "3D2E0D"))
                .frame(width: 18, height: 14)

            // Knot ring
            Ellipse()
                .stroke(Color(hex: "5A4210"), lineWidth: 2)
                .frame(width: 22, height: 18)
        }
    }
}

// MARK: - Previews

#Preview("Log - Soft Wood") {
    LogView(woodType: .soft, hasKnot: false)
        .padding()
        .background(Color.chopBackground)
}

#Preview("Log - Medium Wood") {
    LogView(woodType: .medium, hasKnot: false)
        .padding()
        .background(Color.chopBackground)
}

#Preview("Log - Hard Wood with Knot") {
    LogView(woodType: .hard, hasKnot: true)
        .padding()
        .background(Color.chopBackground)
}

#Preview("Log - All Wood Types") {
    VStack(spacing: 20) {
        LogView(woodType: .soft, hasKnot: false)
        LogView(woodType: .medium, hasKnot: false)
        LogView(woodType: .hard, hasKnot: true)
    }
    .padding()
    .background(Color.chopBackground)
}

#Preview("Log - Splitting Animation") {
    VStack(spacing: 30) {
        LogView(woodType: .medium, hasKnot: false, animationState: .whole)
        LogView(woodType: .medium, hasKnot: false, animationState: .cracking)
        LogView(woodType: .medium, hasKnot: false, animationState: .splitting(progress: 0.5))
        LogView(woodType: .medium, hasKnot: false, animationState: .splitting(progress: 1.0))
    }
    .padding()
    .background(Color.chopBackground)
}
