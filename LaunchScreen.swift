import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            // Pure black background
            Color.black
                .ignoresSafeArea()

            // Subtle code rain effect (static for launch)
            LaunchCodeRain()
                .opacity(0.3)

            // Center content
            VStack(spacing: 24) {
                // App icon representation
                ZStack {
                    // Hexagon shape
                    HexagonShape()
                        .stroke(Color(red: 0, green: 0.94, blue: 0.14), lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(red: 0, green: 0.94, blue: 0.14).opacity(0.6), radius: 20)

                    // M letter
                    Text("M")
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0, green: 0.94, blue: 0.14))
                        .shadow(color: Color(red: 0, green: 0.94, blue: 0.14).opacity(0.8), radius: 10)
                }

                // App name
                Text("MATRIX HABIT")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0, green: 0.94, blue: 0.14))
                    .shadow(color: Color(red: 0, green: 0.94, blue: 0.14).opacity(0.6), radius: 8)

                // Tagline
                Text("BREAK FREE FROM THE SIMULATION")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
    }
}

// Simple hexagon shape
struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for i in 0..<6 {
            let angle = CGFloat(Double(i) * .pi / 3 - .pi / 6)
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// Static code rain for launch screen
struct LaunchCodeRain: View {
    private let columns = 15
    private let chars = "01アイウエオカキクケコ"

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: geo.size.width / CGFloat(columns + 1)) {
                ForEach(0..<columns, id: \.self) { col in
                    VStack(spacing: 8) {
                        ForEach(0..<20, id: \.self) { row in
                            Text(String(chars.randomElement() ?? "0"))
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(Color(red: 0, green: 0.94, blue: 0.14))
                                .opacity(Double.random(in: 0.1...0.5))
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    LaunchScreen()
}
