import SwiftUI
import SwiftData

struct CommandCenterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var powers: [Power]
    @Query private var agents: [Agent]

    @State private var selectedTab: Int = 0
    @State private var showAddHabit: Bool = false
    @State private var showSettings: Bool = false
    @State private var selectedPower: Power? = nil
    @State private var selectedAgent: Agent? = nil
    @State private var showWhiteRabbit: Bool = false
    @StateObject private var rabbitManager = WhiteRabbitManager()

    private var totalSignalStrength: Int {
        let powerStreak = powers.reduce(0) { $0 + $1.currentStreak }
        let agentStreak = agents.reduce(0) { $0 + $1.currentStreak }
        return powerStreak + agentStreak
    }

    private var codeRainOpacity: Double {
        // Base 0.1, max 0.4 at high streaks
        min(0.4, 0.1 + Double(totalSignalStrength) * 0.02)
    }

    private var codeRainSpeed: Double {
        // Base 0.5, faster at high streaks
        min(3.0, 0.5 + Double(totalSignalStrength) * 0.1)
    }

    var body: some View {
        ZStack {
            // Background
            Color.matrixBlack
                .ignoresSafeArea()

            // Dynamic code rain
            CodeRainBackground(opacity: codeRainOpacity, speed: codeRainSpeed)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Content based on selected tab
                if selectedTab == 0 {
                    dashboardContent
                } else if selectedTab == 1 {
                    SignalAnalysisView()
                } else if selectedTab == 2 {
                    AchievementsTabView()
                }

                // Tab Bar
                tabBarView
            }

            // White Rabbit Overlay (5% chance)
            if showWhiteRabbit {
                WhiteRabbitOverlay(isVisible: $showWhiteRabbit) { reward in
                    handleRabbitReward(reward)
                }
            }
        }
        .onAppear {
            rabbitManager.checkForRabbit()
        }
        .onChange(of: rabbitManager.shouldShowRabbit) { _, newValue in
            if newValue {
                showWhiteRabbit = true
                rabbitManager.rabbitDismissed()
            }
        }
        .sheet(isPresented: $showAddHabit) {
            AddHabitSheet()
        }
        .sheet(isPresented: $showSettings) {
            ZionMainframeView()
        }
        .fullScreenCover(item: $selectedPower) { power in
            DialInView(power: power)
        }
        .fullScreenCover(item: $selectedAgent) { agent in
            DialInView(agent: agent)
        }
    }

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Powers Section
                    if !powers.isEmpty {
                        sectionView(
                            title: "// LOADED HACKS",
                            items: powers,
                            isPower: true
                        )
                    }

                    // Agents Section
                    if !agents.isEmpty {
                        sectionView(
                            title: "// DETECTED AGENTS",
                            items: agents,
                            isPower: false
                        )
                    }

                    // Empty state
                    if powers.isEmpty && agents.isEmpty {
                        emptyStateView
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, Spacing.md)
            }
        }
    }

    // MARK: - Header

    private var operativeName: String {
        UserDefaults.standard.string(forKey: "operatorName") ?? "OPERATIVE"
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Operative identifier
            Text("> LOGGED IN: \(operativeName.uppercased())")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
                .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)

            HStack {
                Text("COMMAND CENTER")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                // Rank badge
                Text("RANK: \(UserProfile.currentRank.rawValue)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.darkGray)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.matrixGreen.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Section View

    private func sectionView(title: String, items: [any HabitProtocol], isPower: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)
                .padding(.horizontal, Spacing.md)

            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                HabitCard(
                    title: item.name,
                    icon: item.icon,
                    currentDay: item.currentStreak,
                    targetDays: item.targetDays,
                    isCompletedToday: isPower ? (item as! Power).completedToday : (item as! Agent).resistedToday,
                    isPower: isPower
                )
                .padding(.horizontal, Spacing.md)
                .onTapGesture {
                    if isPower {
                        selectedPower = items[index] as? Power
                    } else {
                        selectedAgent = items[index] as? Agent
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer().frame(height: 100)

            Image(systemName: "cube.transparent")
                .font(.system(size: 60))
                .foregroundColor(Color.mediumGray)

            Text("CONSTRUCT EMPTY")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)

            Text("Load a program to begin.")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(Color.mediumGray)

            Button(action: { showAddHabit = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("LOAD PROGRAM")
                }
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.matrixGreen, lineWidth: 2)
                )
            }
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Tab Bar

    private var tabBarView: some View {
        HStack {
            Spacer()

            // Grid (Dashboard)
            TabBarButton(icon: "square.grid.2x2", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            Spacer()

            // Stats
            TabBarButton(icon: "chart.bar", isSelected: selectedTab == 1) {
                selectedTab = 1
            }

            Spacer()

            // Add
            Button(action: { showAddHabit = true }) {
                ZStack {
                    Circle()
                        .fill(Color.matrixGreen)
                        .frame(width: 56, height: 56)

                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.deepBlack)
                }
            }

            Spacer()

            // Achievements
            TabBarButton(icon: "trophy", isSelected: selectedTab == 2) {
                selectedTab = 2
            }

            Spacer()

            // Settings
            TabBarButton(icon: "gearshape", isSelected: false) {
                showSettings = true
            }

            Spacer()
        }
        .padding(.vertical, Spacing.md)
        .background(
            Color.deepBlack
                .opacity(0.95)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - White Rabbit Reward

    private func handleRabbitReward(_ reward: WhiteRabbitOverlay.RewardType) {
        switch reward {
        case .cheatKey:
            WhiteRabbitManager.addCheatKey()
        case .cosmeticHack:
            // TODO: Implement cosmetic unlocks
            break
        }
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? Color.matrixGreen : Color.mediumGray)
        }
    }
}

// MARK: - Habit Protocol

protocol HabitProtocol {
    var name: String { get }
    var icon: String { get }
    var currentStreak: Int { get }
    var targetDays: Int { get }
}

extension Power: HabitProtocol {}
extension Agent: HabitProtocol {}

// MARK: - Add Habit Sheet (Placeholder)

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var habitName: String = ""
    @State private var isAgent: Bool = false
    @State private var selectedIcon: String = "bolt"

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
                            createHabit()
                            dismiss()
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
        }
    }

    private func createHabit() {
        let name = habitName.trimmingCharacters(in: .whitespaces)
        if isAgent {
            let agent = Agent(name: name, icon: selectedIcon)
            modelContext.insert(agent)
        } else {
            let power = Power(name: name, icon: selectedIcon)
            modelContext.insert(power)
        }
        try? modelContext.save()
    }
}

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

// MARK: - Achievements Tab View

struct AchievementsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unlockedAchievements: [Achievement]

    private var unlockedIds: Set<String> {
        Set(unlockedAchievements.map { $0.id })
    }

    private var unlockedCount: Int {
        unlockedAchievements.count
    }

    private var totalCount: Int {
        AchievementLibrary.all.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("> DECRYPTIONS")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)

                HStack {
                    Text("ACHIEVEMENTS")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Spacer()

                    // Progress badge
                    Text("\(unlockedCount)/\(totalCount)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGold)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.darkGray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.matrixGold.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.sm)

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Progress Ring
                    progressHeader

                    // Categories
                    achievementSection(
                        title: "// STREAK DECRYPTIONS",
                        achievements: AchievementLibrary.streakAchievements
                    )

                    achievementSection(
                        title: "// CONSISTENCY PROTOCOLS",
                        achievements: AchievementLibrary.consistencyAchievements
                    )

                    achievementSection(
                        title: "// SPECIAL OPS",
                        achievements: AchievementLibrary.specialAchievements
                    )

                    Spacer(minLength: 100)
                }
                .padding(.top, Spacing.md)
            }
        }
    }

    private var progressHeader: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .stroke(Color.charcoal, lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: totalCount > 0 ? CGFloat(unlockedCount) / CGFloat(totalCount) : 0)
                    .stroke(Color.matrixGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(unlockedCount)")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                    Text("/ \(totalCount)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
            }

            Text("DECRYPTION PROGRESS")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)

            Text("+\(totalXPEarned) XP EARNED")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
        }
        .padding(.vertical, Spacing.lg)
    }

    private var totalXPEarned: Int {
        unlockedAchievements.compactMap { achievement in
            AchievementLibrary.definition(for: achievement.id)?.rarity.xpReward
        }.reduce(0, +)
    }

    private func achievementSection(title: String, achievements: [AchievementDefinition]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)
                .padding(.horizontal, Spacing.lg)

            ForEach(achievements) { achievement in
                AchievementRowCompact(
                    achievement: achievement,
                    isUnlocked: unlockedIds.contains(achievement.id)
                )
                .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

// MARK: - Compact Achievement Row

struct AchievementRowCompact: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? rarityColor.opacity(0.2) : Color.charcoal)
                    .frame(width: 44, height: 44)

                Image(systemName: achievement.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isUnlocked ? rarityColor : Color.mediumGray)
            }

            // Details
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(achievement.name)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(isUnlocked ? .white : Color.mediumGray)

                    Spacer()

                    Text(achievement.rarity.rawValue)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(rarityColor)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(rarityColor.opacity(0.2))
                        .cornerRadius(4)
                }

                Text(isUnlocked ? achievement.description : "???")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .lineLimit(1)
            }
        }
        .padding(Spacing.sm)
        .background(isUnlocked ? Color.charcoal : Color.charcoal.opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isUnlocked ? rarityColor.opacity(0.5) : Color.mediumGray.opacity(0.3), lineWidth: 1)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }

    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return Color.lightGray
        case .rare: return Color.matrixGreen
        case .epic: return Color.matrixGold
        case .legendary: return Color.purple
        }
    }
}

#Preview {
    CommandCenterView()
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}
