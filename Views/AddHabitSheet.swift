import SwiftUI
import SwiftData

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var habitName: String = ""
    @State private var isAgent: Bool = false
    @State private var selectedIcon: String = "bolt"
    @State private var showSaveError: Bool = false

    private let powerIcons = ["bolt", "figure.run", "book", "brain.head.profile", "drop.fill", "pencil.and.scribble"]
    private let agentIcons = ["xmark.shield", "iphone", "moon.zzz", "cup.and.saucer", "tv", "creditcard"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.matrixBlack.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    // Type Toggle
                    HStack(spacing: Spacing.md) {
                        TypeToggleButton(title: "HACK", isSelected: !isAgent) {
                            isAgent = false
                        }
                        TypeToggleButton(title: "AGENT", isSelected: isAgent) {
                            isAgent = true
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    // Name Input
                    TextField("", text: $habitName, prompt: Text("PROGRAM NAME").foregroundColor(Color.mediumGray))
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(isAgent ? Color.agentRed : Color.matrixGreen)
                        .padding()
                        .background(Color.charcoal)
                        .cornerRadius(Theme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .stroke(isAgent ? Color.agentRed : Color.matrixGreen, lineWidth: 1)
                        )
                        .padding(.horizontal, Spacing.md)

                    // Icon Selection
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("SELECT ICON")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.lightGray)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Spacing.md) {
                            ForEach(isAgent ? agentIcons : powerIcons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedIcon == icon ? (isAgent ? Color.agentRed : Color.matrixGreen) : Color.mediumGray)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon ? Color.charcoal : Color.clear)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer()

                    // Upload Button
                    if !habitName.trimmingCharacters(in: .whitespaces).isEmpty {
                        PrimaryButton(title: "UPLOAD TO CORE") {
                            if createHabit() {
                                dismiss()
                            } else {
                                showSaveError = true
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                    }
                }
                .padding(.top, Spacing.lg)
            }
            .navigationTitle(isAgent ? "NEW AGENT" : "NEW HACK")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CANCEL") { dismiss() }
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                }
            }
            .alert("SAVE FAILED", isPresented: $showSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Failed to create habit. Please try again.")
            }
        }
    }

    private func createHabit() -> Bool {
        let name = habitName.trimmingCharacters(in: .whitespaces)
        if isAgent {
            let agent = Agent(name: name, icon: selectedIcon)
            modelContext.insert(agent)
        } else {
            let power = Power(name: name, icon: selectedIcon)
            modelContext.insert(power)
        }
        do {
            try modelContext.save()
            return true
        } catch {
            ErrorLogger.logSaveFailure(error, context: "AddHabitSheet.createHabit")
            return false
        }
    }
}

// MARK: - Type Toggle Button

struct TypeToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? Color.deepBlack : Color.mediumGray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? (title == "AGENT" ? Color.agentRed : Color.matrixGreen) : Color.clear)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(title == "AGENT" ? Color.agentRed : Color.matrixGreen, lineWidth: 1)
                )
        }
    }
}
