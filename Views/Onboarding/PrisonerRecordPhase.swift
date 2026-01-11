import SwiftUI

// MARK: - Phase 0: Prisoner Record

struct PrisonerRecordPhase: View {
    @Binding var operatorName: String
    @Binding var operatorAge: String
    let onComplete: () -> Void

    @State private var phase: InputPhase = .typing
    @State private var displayedLines: [String] = []
    @State private var currentTypingLine: String = ""
    @State private var showCursor: Bool = true
    @State private var showContinue: Bool = false
    @State private var cursorTimer: Timer?
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var ageFieldFocused: Bool

    enum InputPhase {
        case typing, enteringName, enteringAge, complete
    }

    private let systemLines = [
        "> SYSTEM BREACH DETECTED",
        "> WAKE UP.",
        "> Identify yourself."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status bar
            HStack {
                Text("[ CONNECTION: UNSECURE ]")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.agentRed)
                    .matrixGlow()
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, 72)
            .padding(.bottom, Spacing.lg)

            // Terminal text
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(displayedLines, id: \.self) { line in
                    Text(line)
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()
                }

                if phase == .typing && (!currentTypingLine.isEmpty || showCursor) {
                    Text(currentTypingLine + (showCursor ? "█" : " "))
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()
                }

                // Name Input
                if phase == .enteringName || phase == .enteringAge || phase == .complete {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("> USERNAME:")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        TextField("", text: $operatorName)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .focused($nameFieldFocused)
                            .disabled(phase != .enteringName)
                            .padding(.vertical, Spacing.sm)
                            .padding(.horizontal, Spacing.md)
                            .background(Color.charcoal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.matrixGreen, lineWidth: 2)
                                    .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)
                            )
                            .onSubmit { handleNameSubmit() }
                    }
                    .padding(.top, Spacing.lg)
                }

                // Age Input
                if phase == .enteringAge || phase == .complete {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("> AGE:")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        TextField("", text: $operatorAge)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled()
                            .focused($ageFieldFocused)
                            .disabled(phase == .complete)
                            .padding(.vertical, Spacing.sm)
                            .padding(.horizontal, Spacing.md)
                            .background(Color.charcoal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.matrixGreen, lineWidth: 2)
                                    .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)
                            )
                            .onChange(of: operatorAge) { _, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue { operatorAge = filtered }
                                if filtered.count > 2 { operatorAge = String(filtered.prefix(2)) }
                            }
                    }
                    .padding(.top, Spacing.md)
                }

                // Response text
                if phase == .complete {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("> \(operatorAge) YEARS... CALCULATING WASTED CYCLES...")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                    .padding(.top, Spacing.md)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Continue Button
            if showContinue {
                PrimaryButton(title: "CONTINUE_") {
                    if phase == .enteringName {
                        handleNameSubmit()
                    } else if phase == .enteringAge && !operatorAge.isEmpty {
                        handleAgeSubmit()
                    } else if phase == .complete {
                        onComplete()
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showContinue)
        .onAppear {
            startTypingSequence()
            startCursorBlink()
        }
        .onDisappear {
            cursorTimer?.invalidate()
            cursorTimer = nil
        }
    }

    private func startTypingSequence() {
        typeLines(systemLines) {
            phase = .enteringName
            showContinue = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { nameFieldFocused = true }
        }
    }

    private func typeLines(_ lines: [String], completion: @escaping () -> Void) {
        var lineIndex = 0
        func typeLine() {
            guard lineIndex < lines.count else { completion(); return }
            let line = lines[lineIndex]
            var charIndex = 0
            currentTypingLine = ""
            Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
                if charIndex < line.count {
                    let index = line.index(line.startIndex, offsetBy: charIndex)
                    currentTypingLine += String(line[index])
                    charIndex += 1
                } else {
                    timer.invalidate()
                    displayedLines.append(currentTypingLine)
                    currentTypingLine = ""
                    lineIndex += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { typeLine() }
                }
            }
        }
        typeLine()
    }

    private func startCursorBlink() {
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in showCursor.toggle() }
    }

    private func handleNameSubmit() {
        guard !operatorName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        phase = .enteringAge
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { ageFieldFocused = true }
    }

    private func handleAgeSubmit() {
        guard !operatorAge.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        ageFieldFocused = false
        phase = .complete
    }
}
