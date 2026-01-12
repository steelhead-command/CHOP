import SwiftUI

struct ForestSceneBackground: View {
    var body: some View {
        ZStack {
            // Sky gradient
            SkyLayer()

            // Distant mountains/hills
            DistantHillsLayer()

            // Far trees (silhouettes)
            FarTreesLayer()
                .offset(y: 50)

            // Mid-ground trees
            MidTreesLayer()
                .offset(y: 100)

            // Ground
            GroundLayer()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Sky Layer

struct SkyLayer: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "87CEEB"),  // Sky blue
                Color(hex: "B4D7E8"),  // Lighter blue
                Color(hex: "E8E4D9")   // Warm horizon
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Distant Hills

struct DistantHillsLayer: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Furthest hill
                HillShape(heightRatio: 0.25, peaks: 3)
                    .fill(Color(hex: "8BA89E").opacity(0.5))
                    .frame(height: geometry.size.height * 0.4)
                    .offset(y: geometry.size.height * 0.35)

                // Closer hill
                HillShape(heightRatio: 0.3, peaks: 4)
                    .fill(Color(hex: "6B8E7D").opacity(0.6))
                    .frame(height: geometry.size.height * 0.35)
                    .offset(y: geometry.size.height * 0.45)
            }
        }
    }
}

struct HillShape: Shape {
    let heightRatio: CGFloat
    let peaks: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let segmentWidth = rect.width / CGFloat(peaks)

        path.move(to: CGPoint(x: 0, y: rect.maxY))

        for i in 0..<peaks {
            let startX = CGFloat(i) * segmentWidth
            let peakX = startX + segmentWidth / 2
            let endX = startX + segmentWidth
            let peakHeight = rect.height * heightRatio * CGFloat.random(in: 0.7...1.0)

            path.addQuadCurve(
                to: CGPoint(x: endX, y: rect.maxY),
                control: CGPoint(x: peakX, y: rect.maxY - peakHeight)
            )
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Far Trees Layer

struct FarTreesLayer: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { i in
                    TreeSilhouette(
                        height: CGFloat.random(in: 80...140),
                        width: CGFloat.random(in: 30...50)
                    )
                    .foregroundColor(Color(hex: "4A6B5C").opacity(0.7))
                    .offset(y: geometry.size.height * 0.4 + CGFloat.random(in: -20...20))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Mid Trees Layer

struct MidTreesLayer: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: -10) {
                ForEach(0..<6, id: \.self) { i in
                    TreeSilhouette(
                        height: CGFloat.random(in: 120...200),
                        width: CGFloat.random(in: 50...80)
                    )
                    .foregroundColor(Color(hex: "2D4A3E").opacity(0.85))
                    .offset(y: geometry.size.height * 0.35 + CGFloat.random(in: -30...30))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Tree Silhouette

struct TreeSilhouette: View {
    let height: CGFloat
    let width: CGFloat

    var body: some View {
        TreeShape()
            .frame(width: width, height: height)
    }
}

struct TreeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let trunkWidth = rect.width * 0.15
        let trunkHeight = rect.height * 0.2

        // Trunk
        path.addRect(CGRect(
            x: rect.midX - trunkWidth / 2,
            y: rect.maxY - trunkHeight,
            width: trunkWidth,
            height: trunkHeight
        ))

        // Foliage layers (3 triangular sections)
        let foliageBottom = rect.maxY - trunkHeight
        let layerHeight = (rect.height - trunkHeight) / 3

        for i in 0..<3 {
            let layerTop = foliageBottom - CGFloat(i + 1) * layerHeight
            let layerBottom = foliageBottom - CGFloat(i) * layerHeight + layerHeight * 0.3
            let widthFactor = 1.0 - CGFloat(i) * 0.25

            path.move(to: CGPoint(x: rect.midX, y: layerTop))
            path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.5 * widthFactor, y: layerBottom))
            path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.5 * widthFactor, y: layerBottom))
            path.closeSubpath()
        }

        return path
    }
}

// MARK: - Ground Layer

struct GroundLayer: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                // Grass/clearing
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "7CB342"),  // Grass green
                                Color(hex: "8BC34A"),  // Lighter grass
                                Color(hex: "9CCC65")   // Clearing
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geometry.size.height * 0.25)

                // Dirt/path area
                Rectangle()
                    .fill(Color(hex: "8B7355"))
                    .frame(height: geometry.size.height * 0.1)
            }
        }
    }
}

// MARK: - Previews

#Preview("Forest Background") {
    ForestSceneBackground()
}

#Preview("Forest with Chopping Area") {
    ZStack {
        ForestSceneBackground()

        VStack {
            Spacer()

            ZStack {
                ChoppingBlockView()

                LogView(woodType: .medium, hasKnot: false)
                    .offset(y: -70)
            }
            .padding(.bottom, 100)
        }
    }
}
