import SwiftUI

struct KnotIndicator: View {
    let knotState: KnotState
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.8

    var body: some View {
        ZStack {
            switch knotState {
            case .awaitingStrike(let number):
                AwaitingStrikeView(strikeNumber: number)

            case .waitPeriod(let strike, let remaining):
                WaitPeriodView(strikeNumber: strike, remaining: remaining)

            case .windowOpen(let strike, let remaining):
                WindowOpenView(strikeNumber: strike, remaining: remaining)

            case .success:
                SuccessView()

            case .failed:
                FailedView()
            }
        }
    }
}

// MARK: - Awaiting Strike View

struct AwaitingStrikeView: View {
    let strikeNumber: Int
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 8) {
            // Knot warning icon
            ZStack {
                Circle()
                    .fill(Color.amberGold.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0.5 : 0.8)

                Circle()
                    .fill(Color.amberGold.opacity(0.3))
                    .frame(width: 40, height: 40)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.amberGold)
            }

            Text("KNOT DETECTED")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.amberGold)

            Text("Strike \(strikeNumber) of 3")
                .font(.caption2)
                .foregroundColor(.chopSecondaryText)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Wait Period View

struct WaitPeriodView: View {
    let strikeNumber: Int
    let remaining: TimeInterval

    var body: some View {
        VStack(spacing: 8) {
            // Timer circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: CGFloat(remaining / 0.4))  // Assuming 0.4s wait
                    .stroke(Color.gray, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))

                Text("WAIT")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }

            Text("Strike \(strikeNumber)")
                .font(.caption2)
                .foregroundColor(.chopSecondaryText)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}

// MARK: - Window Open View

struct WindowOpenView: View {
    let strikeNumber: Int
    let remaining: TimeInterval
    @State private var isFlashing = false

    var windowDuration: TimeInterval {
        KnotState.windowDurations[strikeNumber] ?? 0.6
    }

    var body: some View {
        VStack(spacing: 8) {
            // Action indicator
            ZStack {
                Circle()
                    .fill(Color.chopSuccess.opacity(isFlashing ? 0.8 : 0.4))
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: CGFloat(remaining / windowDuration))
                    .stroke(Color.chopSuccess, lineWidth: 5)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "hand.tap.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Text("CHOP NOW!")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.chopSuccess)

            Text("Strike \(strikeNumber) of 3")
                .font(.caption2)
                .foregroundColor(.chopSecondaryText)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
                isFlashing = true
            }
        }
    }
}

// MARK: - Success View

struct SuccessView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.chopSuccess.opacity(0.3))
                    .frame(width: 60, height: 60)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.chopSuccess)
            }

            Text("KNOT CLEARED!")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.chopSuccess)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Failed View

struct FailedView: View {
    @State private var shake: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.chopError.opacity(0.3))
                    .frame(width: 60, height: 60)

                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.chopError)
            }

            Text("MISSED!")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.chopError)

            Text("+1 Strike")
                .font(.caption2)
                .foregroundColor(.chopError)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .offset(x: shake)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.1).repeatCount(4, autoreverses: true)) {
                shake = 10
            }
        }
    }
}

// MARK: - Previews

#Preview("Knot - Awaiting Strike") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        KnotIndicator(knotState: .awaitingStrike(number: 1))
    }
}

#Preview("Knot - Wait Period") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        KnotIndicator(knotState: .waitPeriod(strike: 2, remaining: 0.2))
    }
}

#Preview("Knot - Window Open") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        KnotIndicator(knotState: .windowOpen(strike: 1, remaining: 0.4))
    }
}

#Preview("Knot - Success") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        KnotIndicator(knotState: .success)
    }
}

#Preview("Knot - Failed") {
    ZStack {
        Color.chopBackground
            .ignoresSafeArea()

        KnotIndicator(knotState: .failed)
    }
}

#Preview("All Knot States") {
    VStack(spacing: 20) {
        KnotIndicator(knotState: .awaitingStrike(number: 1))
        KnotIndicator(knotState: .windowOpen(strike: 2, remaining: 0.3))
        HStack(spacing: 20) {
            KnotIndicator(knotState: .success)
            KnotIndicator(knotState: .failed)
        }
    }
    .padding()
    .background(Color.chopBackground)
}
