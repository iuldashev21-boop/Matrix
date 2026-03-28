import SwiftUI

struct CollapsibleSection<Content: View>: View {
    let title: String
    let subtitle: String?
    let accentColor: Color
    @Binding var isExpanded: Bool
    let content: () -> Content

    init(
        title: String,
        subtitle: String? = nil,
        accentColor: Color = Color.matrixGreen,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accentColor = accentColor
        self._isExpanded = isExpanded
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (always visible, tappable)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    // Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(isExpanded ? accentColor : Color.mediumGray)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Color.mediumGray)
                        }
                    }

                    Spacer()

                    // Expand/Collapse indicator
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isExpanded ? accentColor : Color.mediumGray)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
            }
            .buttonStyle(.plain)

            // Collapsible content
            if isExpanded {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Sidequest Section Header

struct SidequestSectionHeader: View {
    let isAvailable: Bool
    @Binding var isExpanded: Bool
    let xpEarned: Int
    let xpCap: Int

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.25)) {
                isExpanded.toggle()
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Spacing.sm) {
                        Text("// THE CONSTRUCT")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(isAvailable ? Color.matrixGreen : Color.mediumGray)

                        if isAvailable && !isExpanded {
                            // Pulsing indicator when available
                            Circle()
                                .fill(Color.matrixGreen)
                                .frame(width: 6, height: 6)
                                .modifier(PulseModifier())
                        }
                    }

                    if isAvailable {
                        Text("OPTIONAL PROGRAMS READY")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    } else {
                        Text("COMPLETE HABITS TO UNLOCK")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.mediumGray.opacity(0.6))
                    }
                }

                Spacer()

                // XP Progress
                if isAvailable {
                    Text("\(xpEarned)/\(xpCap) XP")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.matrixGreen.opacity(0.15))
                        .cornerRadius(Theme.cornerRadiusSm)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isAvailable ? Color.matrixGreen : Color.mediumGray)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isAvailable && !isExpanded ? Color.matrixGreen.opacity(0.05) : Color.clear)
            .cornerRadius(Theme.cornerRadiusCompact)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .opacity(isAvailable ? 1.0 : 0.6)
    }
}

// MARK: - Pulse Modifier

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 0.4 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

#Preview {
    ZStack {
        Color.matrixBlack.ignoresSafeArea()

        VStack(spacing: Spacing.lg) {
            CollapsibleSection(
                title: "// LOADED HACKS",
                subtitle: "2/3 COMPLETED",
                isExpanded: .constant(true)
            ) {
                VStack(spacing: Spacing.sm) {
                    Text("Content here")
                        .foregroundColor(.white)
                    Text("More content")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, Spacing.md)
            }

            SidequestSectionHeader(
                isAvailable: true,
                isExpanded: .constant(false),
                xpEarned: 25,
                xpCap: 75
            )
        }
        .padding()
    }
}

