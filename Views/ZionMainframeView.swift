import SwiftUI
import SwiftData

struct ZionMainframeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var hapticsEnabled: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hapticsEnabled)
    @State private var soundEnabled: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEnabled)
    @State private var showResetAlert: Bool = false
    @State private var showExportSheet: Bool = false
    @State private var showAchievements: Bool = false
    @State private var versionTapCount: Int = 0
    @State private var showEasterEgg: Bool = false
    @State private var easterEggGlitch: CGSize = .zero

    var body: some View {
        ZStack {
            Color.matrixBlack
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    headerView

                    // Construct Config Section
                    configSection

                    // Memory Management Section
                    memorySection

                    // System Info Section
                    systemInfoSection

                    Spacer(minLength: 50)
                }
                .padding(.top, Spacing.md)
            }

            // Easter Egg Overlay
            if showEasterEgg {
                easterEggOverlay
            }
        }
        .alert("WARNING: SYSTEM CRITICAL", isPresented: $showResetAlert) {
            Button("CANCEL", role: .cancel) { }
            Button("DELETE", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("Rebooting will purge all localized memory. This cannot be undone.")
        }
        .sheet(isPresented: $showExportSheet) {
            ExportDataView()
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("BACK")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(Color.matrixGreen)
                }
                Spacer()
            }

            Text("ZION MAINFRAME")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Config Section

    private var configSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "CONSTRUCT CONFIG")

            // Achievements Button
            Button(action: { showAchievements = true }) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 16))
                    Text("DECRYPTIONS")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                    Spacer()
                    Text("\(unlockedAchievementCount)/\(AchievementLibrary.all.count)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color.mediumGray)
                }
                .foregroundColor(Color.matrixGold)
                .padding(Spacing.md)
                .background(Color.charcoal)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.matrixGold.opacity(0.5), lineWidth: 1)
                )
            }

            // Haptics Toggle
            SettingsToggleRow(
                title: "TACTILE RESPONSE",
                description: "Physical confirmation of uploaded data.",
                isOn: $hapticsEnabled
            ) {
                UserDefaults.standard.set(hapticsEnabled, forKey: UserDefaultsKeys.hapticsEnabled)
                if hapticsEnabled {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }

            // Sound Toggle
            SettingsToggleRow(
                title: "AUDIO CUES",
                description: "System interface sounds.",
                isOn: $soundEnabled
            ) {
                UserDefaults.standard.set(soundEnabled, forKey: UserDefaultsKeys.soundEnabled)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private var unlockedAchievementCount: Int {
        let descriptor = FetchDescriptor<Achievement>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    // MARK: - Memory Section

    private var memorySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "MEMORY MANAGEMENT")

            // Export Button
            Button(action: { showExportSheet = true }) {
                HStack {
                    Image(systemName: "arrow.up.doc")
                        .font(.system(size: 16))
                    Text("EXTRACT SOURCE CODE")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                    Spacer()
                }
                .foregroundColor(Color.matrixGreen)
                .padding(Spacing.md)
                .background(Color.charcoal)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.matrixGreen, lineWidth: 1)
                )
            }

            // Reset Button
            Button(action: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                showResetAlert = true
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 16))
                    Text("SYSTEM REBOOT")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                    Spacer()
                }
                .foregroundColor(Color.danger)
                .padding(Spacing.md)
                .background(Color.charcoal)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.danger, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - System Info Section

    private var systemInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "SYSTEM INFO")

            VStack(spacing: Spacing.lg) {
                // Version (tappable for easter egg)
                Button(action: handleVersionTap) {
                    Text("CONSTRUCT v1.0.0")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }

                // Credits
                Text("BUILT BY THE NEBUCHADNEZZAR CREW")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.mediumGray)

                // Copyright
                Text("© 2199 ZION INDUSTRIES")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.darkGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.xl)
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Easter Egg

    private var easterEggOverlay: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            Text("THERE IS NO SPOON")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
                .offset(easterEggGlitch)
        }
        .onAppear {
            triggerGlitch()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showEasterEgg = false
                }
            }
        }
        .onTapGesture {
            showEasterEgg = false
        }
    }

    private func handleVersionTap() {
        versionTapCount += 1

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if versionTapCount >= 7 {
            versionTapCount = 0
            withAnimation {
                showEasterEgg = true
            }
        }
    }

    private func triggerGlitch() {
        GlitchEffect.triggerHeavy(offset: $easterEggGlitch)
    }

    // MARK: - Actions

    private func resetAllData() {
        // Clear SwiftData
        do {
            try modelContext.delete(model: Power.self)
            try modelContext.delete(model: Agent.self)
            try modelContext.delete(model: CheckIn.self)
            try modelContext.delete(model: Achievement.self)
            try modelContext.save()
        } catch {
            #if DEBUG
            print("Failed to reset data: \(error)")
            #endif
        }

        // Clear UserDefaults
        UserProfile.reset()

        // Feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Dismiss
        dismiss()
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text("> \(title)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)

            Rectangle()
                .fill(Color.matrixGreen.opacity(0.3))
                .frame(height: 1)
        }
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let onChange: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.lightGray)
            }

            Spacer()

            // Custom Matrix-style toggle
            Button(action: {
                isOn.toggle()
                onChange()
            }) {
                Text(isOn ? "[ ON ]" : "[ OFF ]")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isOn ? Color.matrixGreen : Color.mediumGray)
            }
        }
        .padding(Spacing.md)
        .background(Color.charcoal)
        .cornerRadius(Theme.cornerRadius)
    }
}

// MARK: - Export Data View

struct ExportDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var powers: [Power]
    @Query private var agents: [Agent]
    @Query private var checkIns: [CheckIn]

    var body: some View {
        NavigationView {
            ZStack {
                Color.matrixBlack.ignoresSafeArea()

                VStack(spacing: Spacing.xl) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 50))
                        .foregroundColor(Color.matrixGreen)

                    Text("SOURCE CODE READY")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    VStack(spacing: Spacing.sm) {
                        Text("HACKS: \(powers.count)")
                        Text("AGENTS: \(agents.count)")
                        Text("CHECK-INS: \(checkIns.count)")
                        Text("TOTAL XP: \(UserProfile.totalXP)")
                    }
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.lightGray)

                    Spacer()

                    if let exportData = generateExportData() {
                        ShareLink(item: exportData) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("EXPORT JSON")
                            }
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.deepBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.matrixGreen)
                            .cornerRadius(Theme.cornerRadius)
                        }
                        .padding(.horizontal, Spacing.xl)
                    }

                    Spacer()
                }
                .padding(.top, Spacing.xxl)
            }
            .navigationTitle("EXTRACT DATA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CLOSE") { dismiss() }
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                }
            }
        }
    }

    private func generateExportData() -> String? {
        let export = ExportData(
            version: "1.0.0",
            exportDate: Date(),
            totalXP: UserProfile.totalXP,
            rank: UserProfile.currentRank.rawValue,
            powers: powers.map { ExportData.HabitExport(name: $0.name, icon: $0.icon, currentStreak: $0.currentStreak, longestStreak: $0.longestStreak, createdAt: $0.createdAt) },
            agents: agents.map { ExportData.HabitExport(name: $0.name, icon: $0.icon, currentStreak: $0.currentStreak, longestStreak: $0.longestStreak, createdAt: $0.createdAt) },
            checkIns: checkIns.map { ExportData.CheckInExport(date: $0.date, isSuccess: $0.isSuccess, note: $0.note ?? "") }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        guard let jsonData = try? encoder.encode(export),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        return jsonString
    }
}

// MARK: - Export Data Models

private struct ExportData: Codable {
    let version: String
    let exportDate: Date
    let totalXP: Int
    let rank: String
    let powers: [HabitExport]
    let agents: [HabitExport]
    let checkIns: [CheckInExport]

    struct HabitExport: Codable {
        let name: String
        let icon: String
        let currentStreak: Int
        let longestStreak: Int
        let createdAt: Date
    }

    struct CheckInExport: Codable {
        let date: Date
        let isSuccess: Bool
        let note: String
    }
}

#Preview {
    ZionMainframeView()
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self, Achievement.self], inMemory: true)
}

