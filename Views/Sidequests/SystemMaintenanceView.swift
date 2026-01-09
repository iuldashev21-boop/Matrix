import SwiftUI

struct SystemMaintenanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var task: MaintenanceTask?
    @State private var isCompleted: Bool = false
    @State private var xpEarned: Int = 0
    @State private var showStatic: Bool = true

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            // Static/Glitch background when not completed
            if showStatic {
                StaticNoiseView()
                    .ignoresSafeArea()
                    .opacity(0.3)
            }

            VStack(spacing: Spacing.xl) {
                // Header
                headerView

                Spacer()

                if !isCompleted {
                    taskView
                } else {
                    completedView
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            task = MaintenanceTasks.random()
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

            Spacer()

            Text("SYS_MAINTENANCE")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(showStatic ? Color.agentRed : Color.matrixGreen)

            Spacer()

            // Spacer for alignment
            Color.clear.frame(width: 24, height: 24)
        }
    }

    // MARK: - Task View

    private var taskView: some View {
        VStack(spacing: Spacing.xl) {
            // Glitch indicator
            Text("// GLITCH_DETECTED")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color.agentRed)

            // Task card
            if let task = task {
                VStack(spacing: Spacing.md) {
                    Text(task.name.uppercased())
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(Spacing.xl)
                .frame(maxWidth: .infinity)
                .background(Color.charcoal)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.agentRed.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal, Spacing.md)
            }

            // Purge button
            Button(action: purgeGlitch) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "bolt.fill")
                    Text("PURGE GLITCH")
                }
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color.deepBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.matrixGreen)
                .cornerRadius(12)
            }
            .padding(.horizontal, Spacing.xl)
        }
    }

    // MARK: - Completed View

    private var completedView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.matrixGreen)

            Text("ENVIRONMENTAL_SYNC_COMPLETE")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
                .multilineTextAlignment(.center)

            Text("+\(xpEarned) XP")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)

            Button(action: { dismiss() }) {
                Text("RETURN")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.matrixGreen, lineWidth: 2)
                    )
            }
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Logic

    private func purgeGlitch() {
        // Clear static immediately
        withAnimation(.easeOut(duration: 0.2)) {
            showStatic = false
        }

        xpEarned = SidequestManager.completeMaintenance()

        withAnimation(.easeInOut(duration: 0.3)) {
            isCompleted = true
        }
    }
}

// MARK: - Maintenance Tasks

struct MaintenanceTask {
    let name: String
}

enum MaintenanceTasks {
    static let all: [MaintenanceTask] = [
        MaintenanceTask(name: "Clear one surface in your space"),
        MaintenanceTask(name: "Delete 5 old photos from your phone"),
        MaintenanceTask(name: "Drink a glass of water"),
        MaintenanceTask(name: "File or throw away one piece of paper"),
        MaintenanceTask(name: "Put away 3 items that are out of place"),
        MaintenanceTask(name: "Wipe down your phone screen"),
        MaintenanceTask(name: "Close 5 browser tabs"),
        MaintenanceTask(name: "Unsubscribe from one email list"),
        MaintenanceTask(name: "Empty your pockets or bag"),
        MaintenanceTask(name: "Straighten your shoes by the door"),
        MaintenanceTask(name: "Take out one piece of trash"),
        MaintenanceTask(name: "Plug in a device that needs charging"),
        MaintenanceTask(name: "Return one item to its proper place"),
        MaintenanceTask(name: "Clear your notifications"),
        MaintenanceTask(name: "Make your bed (if not done)"),
    ]

    static func random() -> MaintenanceTask {
        all.randomElement() ?? all[0]
    }
}

// MARK: - Static Noise View

struct StaticNoiseView: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for _ in 0..<500 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let gray = CGFloat.random(in: 0.1...0.4)

                    context.fill(
                        Path(CGRect(x: x, y: y, width: 2, height: 2)),
                        with: .color(Color(white: gray))
                    )
                }
            }
        }
        .onAppear {
            // Animate to create flickering effect
            withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: false)) {
                offset = 1
            }
        }
    }
}

#Preview {
    SystemMaintenanceView()
}

