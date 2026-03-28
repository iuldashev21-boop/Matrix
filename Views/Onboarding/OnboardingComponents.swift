import SwiftUI

// MARK: - CRT Overlay Components

struct ScanlineOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for y in stride(from: 0, to: size.height, by: 3) {
                    context.fill(
                        Path(CGRect(x: 0, y: y, width: size.width, height: 1)),
                        with: .color(.black.opacity(0.15))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct VignetteOverlay: View {
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
            center: .center,
            startRadius: UIScreen.main.bounds.width * 0.3,
            endRadius: UIScreen.main.bounds.width * 0.9
        )
        .allowsHitTesting(false)
    }
}

struct MatrixTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.matrixGreen.opacity(0.6), radius: 4)
    }
}

extension View {
    func matrixGlow() -> some View {
        modifier(MatrixTextStyle())
    }
}

// MARK: - Progress Indicator

struct OnboardingProgressBar: View {
    let currentPhase: Int
    let totalPhases: Int

    private var progress: Double {
        guard totalPhases > 0 else { return 0 }
        return Double(currentPhase) / Double(totalPhases - 1)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("PHASE \(currentPhase + 1) OF \(totalPhases)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.charcoal)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.matrixGreen)
                        .frame(width: geo.size.width * CGFloat(progress), height: 6)
                        .shadow(color: Color.matrixGreen.opacity(0.6), radius: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                .fill(Color.black.opacity(0.7))
        )
    }
}

// MARK: - Diagnostic Buttons

struct DiagnosticButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? Color.deepBlack : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isSelected ? Color.matrixGreen : Color.charcoal)
                .cornerRadius(Theme.cornerRadiusCompact)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                        .stroke(isSelected ? Color.matrixGreen : Color.mediumGray.opacity(0.5), lineWidth: 1)
                        .shadow(color: isSelected ? Color.matrixGreen.opacity(0.4) : .clear, radius: 4)
                )
        }
    }
}

struct DiagnosticButtonWithFlavor: View {
    let title: String
    let flavor: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? Color.deepBlack : .white)
                Text(flavor)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(isSelected ? Color.deepBlack.opacity(0.7) : Color.mediumGray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isSelected ? Color.matrixGreen : Color.charcoal)
            .cornerRadius(Theme.cornerRadiusCompact)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                    .stroke(isSelected ? Color.matrixGreen : Color.mediumGray.opacity(0.5), lineWidth: 1)
                    .shadow(color: isSelected ? Color.matrixGreen.opacity(0.4) : .clear, radius: 4)
            )
        }
    }
}

// MARK: - Helper Views

struct TimeBreakdownRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color.mediumGray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color.agentRed)
        }
        .padding(.horizontal, Spacing.xl)
    }
}

struct ManualConceptRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(color)

                Text(description)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.lightGray)
            }

            Spacer()
        }
        .padding(Spacing.sm)
        .background(Color.charcoal)
        .cornerRadius(Theme.cornerRadiusCompact)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
