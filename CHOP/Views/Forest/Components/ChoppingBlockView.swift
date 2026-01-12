import SwiftUI

struct ChoppingBlockView: View {
    var showImpactMark: Bool = false

    var body: some View {
        ZStack {
            // Tree stump base
            StumpShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "8B6914"),
                            Color(hex: "6B4D32")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 180, height: 100)

            // Top surface with growth rings
            Ellipse()
                .fill(Color(hex: "A67C52"))
                .frame(width: 160, height: 50)
                .offset(y: -30)

            // Growth rings on top
            GrowthRingsView()
                .offset(y: -30)

            // Bark texture on sides
            BarkTextureView()
                .frame(width: 180, height: 70)
                .offset(y: 15)
                .mask(
                    StumpShape()
                        .frame(width: 180, height: 100)
                )

            // Axe marks/wear
            AxeMarksView()
                .offset(y: -25)

            // Impact flash (shown on chop)
            if showImpactMark {
                Ellipse()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 40, height: 15)
                    .offset(y: -30)
                    .blur(radius: 3)
            }
        }
    }
}

// MARK: - Stump Shape

struct StumpShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topWidth = rect.width * 0.88
        let bottomWidth = rect.width
        let topInset = (rect.width - topWidth) / 2

        // Start at top left
        path.move(to: CGPoint(x: topInset, y: rect.minY))

        // Top edge (slightly curved)
        path.addQuadCurve(
            to: CGPoint(x: rect.width - topInset, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.minY - 5)
        )

        // Right edge (tapers outward)
        path.addLine(to: CGPoint(x: bottomWidth, y: rect.maxY - 10))

        // Bottom right corner
        path.addQuadCurve(
            to: CGPoint(x: bottomWidth - 10, y: rect.maxY),
            control: CGPoint(x: bottomWidth, y: rect.maxY)
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: 10, y: rect.maxY))

        // Bottom left corner
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY - 10),
            control: CGPoint(x: 0, y: rect.maxY)
        )

        // Left edge (tapers inward going up)
        path.addLine(to: CGPoint(x: topInset, y: rect.minY))

        path.closeSubpath()
        return path
    }
}

// MARK: - Growth Rings

struct GrowthRingsView: View {
    var body: some View {
        ZStack {
            // Outer rings
            ForEach(0..<5, id: \.self) { i in
                Ellipse()
                    .stroke(
                        Color(hex: "8B6914").opacity(0.3 + Double(i) * 0.1),
                        lineWidth: 1.5
                    )
                    .frame(
                        width: CGFloat(140 - i * 25),
                        height: CGFloat(40 - i * 7)
                    )
            }

            // Center heartwood
            Ellipse()
                .fill(Color(hex: "5C4612"))
                .frame(width: 25, height: 10)
        }
    }
}

// MARK: - Bark Texture

struct BarkTextureView: View {
    var body: some View {
        ZStack {
            // Vertical bark lines
            HStack(spacing: 8) {
                ForEach(0..<12, id: \.self) { i in
                    BarkLine()
                        .offset(y: CGFloat.random(in: -5...5))
                }
            }
        }
        .opacity(0.4)
    }
}

struct BarkLine: View {
    var body: some View {
        Capsule()
            .fill(Color(hex: "3D2E0D"))
            .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 30...60))
    }
}

// MARK: - Axe Marks

struct AxeMarksView: View {
    var body: some View {
        ZStack {
            // Worn area from repeated chopping
            Ellipse()
                .fill(Color(hex: "7A5C1A").opacity(0.5))
                .frame(width: 60, height: 20)

            // Individual axe marks
            ForEach(0..<3, id: \.self) { i in
                AxeMark()
                    .offset(
                        x: CGFloat.random(in: -25...25),
                        y: CGFloat.random(in: -5...5)
                    )
                    .rotationEffect(.degrees(Double.random(in: -20...20)))
            }
        }
    }
}

struct AxeMark: View {
    var body: some View {
        Capsule()
            .fill(Color(hex: "5C4612"))
            .frame(width: CGFloat.random(in: 15...25), height: 3)
    }
}

// MARK: - Previews

#Preview("Chopping Block") {
    ChoppingBlockView()
        .padding()
        .background(Color.chopBackground)
}

#Preview("Chopping Block - Impact") {
    ChoppingBlockView(showImpactMark: true)
        .padding()
        .background(Color.chopBackground)
}

#Preview("Chopping Block - In Scene") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        VStack {
            Spacer()

            // Log on block
            ZStack {
                ChoppingBlockView()

                LogView(woodType: .medium, hasKnot: false)
                    .offset(y: -70)
            }

            Spacer()
        }
    }
}
