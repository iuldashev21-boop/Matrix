import AVFoundation
import SwiftUI

/// Centralized sound effect management for the app
/// Plays Matrix-themed audio feedback at key moments
final class SoundManager: ObservableObject {

    static let shared = SoundManager()

    // MARK: - Sound Types

    enum Sound: String, CaseIterable {
        // Must Have (v1)
        case checkInSuccess = "checkin_success"      // Daily check-in confirmation
        case streakMilestone = "streak_milestone"    // 7/21/66 day achievements
        case protocolComplete = "protocol_complete"  // Power unlock / Agent defeat
        case relapse = "relapse"                     // Streak break / breach
        case buttonTap = "button_tap"                // UI interaction feedback

        // Nice to Have (v1.x)
        case empTokenEarned = "emp_token"            // EMP token reward
        case achievementUnlock = "achievement"       // Badge/achievement earned
        case levelUp = "level_up"                    // Rank advancement
        case holdProgress = "hold_progress"          // Long-press charging
        case terminalType = "terminal_type"          // Typing effect sounds

        var fileExtension: String { "wav" }
    }

    // MARK: - Properties

    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("soundVolume") var soundVolume: Double = 0.7

    private var audioPlayers: [Sound: AVAudioPlayer] = [:]
    private var isInitialized = false

    // MARK: - Initialization

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            ErrorLogger.log(error, operation: "configureAudioSession", context: "SoundManager")
        }
    }

    /// Preload all sound files for instant playback
    func preloadSounds() {
        guard !isInitialized else { return }

        for sound in Sound.allCases {
            loadSound(sound)
        }

        isInitialized = true
    }

    private func loadSound(_ sound: Sound) {
        guard let url = Bundle.main.url(
            forResource: sound.rawValue,
            withExtension: sound.fileExtension
        ) else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = Float(soundVolume)
            audioPlayers[sound] = player
        } catch {
            ErrorLogger.log(error, operation: "loadSound", context: "SoundManager.\(sound.rawValue)")
        }
    }

    // MARK: - Playback

    /// Play a sound effect
    func play(_ sound: Sound) {
        guard soundEnabled else { return }

        // Load on-demand if not preloaded
        if audioPlayers[sound] == nil {
            loadSound(sound)
        }

        guard let player = audioPlayers[sound] else { return }

        player.volume = Float(soundVolume)
        player.currentTime = 0
        player.play()
    }

    /// Play sound with haptic feedback combo
    func playWithHaptic(_ sound: Sound, haptic: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        play(sound)

        let generator = UIImpactFeedbackGenerator(style: haptic)
        generator.impactOccurred()
    }

    // MARK: - Convenience Methods

    /// Check-in success sound + haptic
    func playCheckIn() {
        playWithHaptic(.checkInSuccess, haptic: .medium)
    }

    /// Streak milestone celebration
    func playMilestone() {
        playWithHaptic(.streakMilestone, haptic: .heavy)
    }

    /// Protocol complete (unlock/defeat)
    func playProtocolComplete() {
        playWithHaptic(.protocolComplete, haptic: .heavy)
    }

    /// Relapse/breach alert
    func playRelapse() {
        playWithHaptic(.relapse, haptic: .rigid)
    }

    /// Light button tap
    func playTap() {
        playWithHaptic(.buttonTap, haptic: .light)
    }

    /// EMP token earned
    func playEMPToken() {
        playWithHaptic(.empTokenEarned, haptic: .medium)
    }

    /// Achievement unlocked
    func playAchievement() {
        playWithHaptic(.achievementUnlock, haptic: .heavy)
    }

    /// Level/rank up
    func playLevelUp() {
        playWithHaptic(.levelUp, haptic: .heavy)
    }

    // MARK: - Settings

    func setEnabled(_ enabled: Bool) {
        soundEnabled = enabled
    }

    func setVolume(_ volume: Double) {
        soundVolume = max(0, min(1, volume))

        // Update all loaded players
        for player in audioPlayers.values {
            player.volume = Float(soundVolume)
        }
    }
}

// MARK: - SwiftUI Environment

private struct SoundManagerKey: EnvironmentKey {
    static let defaultValue = SoundManager.shared
}

extension EnvironmentValues {
    var soundManager: SoundManager {
        get { self[SoundManagerKey.self] }
        set { self[SoundManagerKey.self] = newValue }
    }
}

// MARK: - View Modifier for Easy Access

extension View {
    /// Play a sound when this view appears
    func playSound(_ sound: SoundManager.Sound) -> some View {
        self.onAppear {
            SoundManager.shared.play(sound)
        }
    }

    /// Play a sound with haptic on button tap
    func withTapSound() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                SoundManager.shared.playTap()
            }
        )
    }
}
