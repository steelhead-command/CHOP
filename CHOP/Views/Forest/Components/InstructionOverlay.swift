import SwiftUI

struct InstructionOverlay: View {
    @State private var isAnimating = false
    @State private var arrowOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            // Swipe arrow indicator
            VStack(spacing: 4) {
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(180))
                    .offset(y: arrowOffset)

                // Arrow trail
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7 - Double(i) * 0.2))
                        .offset(y: arrowOffset * CGFloat(1 - Double(i) * 0.3))
                }
            }

            // Instruction text
            Text("SWIPE DOWN TO CHOP")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Quick swipes for faster chopping")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.7))
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                arrowOffset = 15
            }
        }
    }
}

// MARK: - Compact Version

struct CompactInstructionOverlay: View {
    @State private var opacity: Double = 1.0

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.down")
                .font(.caption)
                .foregroundColor(.white)

            Text("SWIPE TO CHOP")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.5))
        .cornerRadius(20)
        .opacity(opacity)
        .onAppear {
            // Fade out after a few seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0
                }
            }
        }
    }
}

// MARK: - First Time Tutorial

struct FirstTimeTutorial: View {
    @Binding var isVisible: Bool
    @State private var currentStep = 0

    let steps = [
        TutorialStep(
            icon: "hand.point.down.fill",
            title: "Swipe Down",
            description: "Swipe down quickly to chop the log"
        ),
        TutorialStep(
            icon: "exclamationmark.triangle.fill",
            title: "Watch for Knots",
            description: "Some logs have knots - time your chops carefully!"
        ),
        TutorialStep(
            icon: "bolt.fill",
            title: "Build Combos",
            description: "Chain quick chops for bonus points"
        )
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Step indicator
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Circle()
                        .fill(i == currentStep ? Color.chopOrange : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            // Current step content
            VStack(spacing: 12) {
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 48))
                    .foregroundColor(.chopOrange)

                Text(steps[currentStep].title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(steps[currentStep].description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // Navigation
            HStack(spacing: 16) {
                if currentStep > 0 {
                    Button {
                        withAnimation {
                            currentStep -= 1
                        }
                    } label: {
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                    }
                }

                Button {
                    if currentStep < steps.count - 1 {
                        withAnimation {
                            currentStep += 1
                        }
                    } else {
                        withAnimation {
                            isVisible = false
                        }
                    }
                } label: {
                    Text(currentStep < steps.count - 1 ? "Next" : "Got it!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.chopOrange)
                        .cornerRadius(25)
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.85))
        )
        .padding()
    }
}

struct TutorialStep {
    let icon: String
    let title: String
    let description: String
}

// MARK: - Previews

#Preview("Instruction Overlay") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        InstructionOverlay()
    }
}

#Preview("Compact Instruction") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        VStack {
            Spacer()
            CompactInstructionOverlay()
            Spacer().frame(height: 100)
        }
    }
}

#Preview("First Time Tutorial") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        FirstTimeTutorial(isVisible: .constant(true))
    }
}
