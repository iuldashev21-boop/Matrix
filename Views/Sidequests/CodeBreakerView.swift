import SwiftUI

struct CodeBreakerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var secretCode: [Int] = []
    @State private var guesses: [[Int]] = []
    @State private var currentGuess: [Int] = []
    @State private var gameState: GameState = .playing
    @State private var xpEarned: Int = 0
    @State private var showGlitch: Bool = false

    enum GameState {
        case playing
        case won
        case lost
    }

    private let maxAttempts = 5
    private let codeLength = 4

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            // Glitch effect on win
            if showGlitch {
                Color.matrixGreen
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack(spacing: Spacing.lg) {
                // Header
                headerView

                Spacer()

                // Attempt rows
                attemptsView

                Spacer()

                // Current input or result
                if gameState == .playing {
                    currentInputView
                    numpadView
                } else {
                    resultView
                }
            }
            .padding()
        }
        .onAppear {
            generateSecretCode()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.mediumGray)
            }
            .accessibilityLabel("Close")

            Spacer()

            Text("CODE_BREAKER")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)

            Spacer()

            Text("ATT: \(guesses.count)/\(maxAttempts)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color.lightGray)
        }
    }

    // MARK: - Attempts View

    private var attemptsView: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(0..<maxAttempts, id: \.self) { row in
                HStack(spacing: Spacing.sm) {
                    ForEach(0..<codeLength, id: \.self) { col in
                        attemptCell(row: row, col: col)
                    }
                }
            }
        }
    }

    private func attemptCell(row: Int, col: Int) -> some View {
        let cellState = getCellState(row: row, col: col)
        let digit = getDigit(row: row, col: col)

        return ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                .fill(cellState.backgroundColor)
                .frame(width: 50, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                        .stroke(cellState.borderColor, lineWidth: 2)
                )

            if let digit = digit {
                Text("\(digit)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(cellState.textColor)
            }
        }
    }

    private func getCellState(row: Int, col: Int) -> CellState {
        guard row < guesses.count else {
            return .empty
        }

        let guess = guesses[row]
        let digit = guess[col]

        if secretCode[col] == digit {
            return .correct
        } else if secretCode.contains(digit) {
            return .wrongPosition
        } else {
            return .incorrect
        }
    }

    private func getDigit(row: Int, col: Int) -> Int? {
        guard row < guesses.count else { return nil }
        return guesses[row][col]
    }

    enum CellState {
        case empty
        case correct
        case wrongPosition
        case incorrect

        var backgroundColor: Color {
            switch self {
            case .empty: return Color.charcoal
            case .correct: return Color.matrixGreen
            case .wrongPosition: return Color.warning
            case .incorrect: return Color.darkGray
            }
        }

        var borderColor: Color {
            switch self {
            case .empty: return Color.mediumGray
            case .correct: return Color.matrixGreen
            case .wrongPosition: return Color.warning
            case .incorrect: return Color.mediumGray
            }
        }

        var textColor: Color {
            switch self {
            case .empty: return .white
            case .correct: return Color.deepBlack
            case .wrongPosition: return Color.deepBlack
            case .incorrect: return Color.lightGray
            }
        }
    }

    // MARK: - Current Input View

    private var currentInputView: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<codeLength, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                        .stroke(Color.matrixGreen, lineWidth: 2)
                        .frame(width: 50, height: 60)

                    if index < currentGuess.count {
                        Text("\(currentGuess[index])")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                    } else {
                        Text("_")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                }
            }
        }
    }

    // MARK: - Numpad View

    private var numpadView: some View {
        VStack(spacing: Spacing.sm) {
            // Row 1-3
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: Spacing.sm) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        numpadButton(number: number)
                    }
                }
            }

            // Row 4: Delete, 0, Enter
            HStack(spacing: Spacing.sm) {
                // Delete
                Button(action: deleteLast) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.agentRed)
                        .frame(width: 70, height: 50)
                        .background(Color.charcoal)
                        .cornerRadius(Theme.cornerRadiusCompact)
                }

                // 0
                numpadButton(number: 0)

                // Enter
                Button(action: submitGuess) {
                    Text("ENTER")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(currentGuess.count == codeLength ? Color.matrixGreen : Color.mediumGray)
                        .frame(width: 70, height: 50)
                        .background(currentGuess.count == codeLength ? Color.matrixGreen.opacity(0.2) : Color.charcoal)
                        .cornerRadius(Theme.cornerRadiusCompact)
                }
                .disabled(currentGuess.count != codeLength)
            }
        }
    }

    private func numpadButton(number: Int) -> some View {
        Button(action: { addDigit(number) }) {
            Text("\(number)")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 70, height: 50)
                .background(Color.charcoal)
                .cornerRadius(Theme.cornerRadiusCompact)
        }
        .disabled(currentGuess.count >= codeLength)
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: Spacing.lg) {
            if gameState == .won {
                Text("ACCESS_GRANTED")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                Text("+\(xpEarned) XP")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
            } else {
                Text("ACCESS_DENIED")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.agentRed)

                Text("CODE WAS: \(secretCode.map { String($0) }.joined())")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
            }

            Button(action: { dismiss() }) {
                Text("DISCONNECT")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                            .stroke(Color.matrixGreen, lineWidth: 2)
                    )
            }
        }
        .padding(.bottom, Spacing.xl)
    }

    // MARK: - Game Logic

    private func generateSecretCode() {
        secretCode = (0..<codeLength).map { _ in Int.random(in: 0...9) }
    }

    private func addDigit(_ digit: Int) {
        guard currentGuess.count < codeLength else { return }
        currentGuess.append(digit)
    }

    private func deleteLast() {
        guard !currentGuess.isEmpty else { return }
        currentGuess.removeLast()
    }

    private func submitGuess() {
        guard currentGuess.count == codeLength else { return }

        guesses.append(currentGuess)

        // Check win
        if currentGuess == secretCode {
            // Glitch effect
            withAnimation(.easeInOut(duration: 0.1)) {
                showGlitch = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    showGlitch = false
                }
            }

            xpEarned = SidequestManager.completeCodeBreaker(won: true)
            gameState = .won
        } else if guesses.count >= maxAttempts {
            _ = SidequestManager.completeCodeBreaker(won: false)
            gameState = .lost
        }

        currentGuess = []
    }
}

#Preview {
    CodeBreakerView()
}

