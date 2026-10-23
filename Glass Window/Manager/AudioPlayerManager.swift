//
//  AudioPlayerManager.swift
//  Glass Window
//
//  Created by mac on 29/09/2026.
//

import SwiftUI
import AVFoundation
import Combine

public final class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    public static let shared = AudioPlayerManager()
    
    // MARK: - Published State
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var progress: Double = 0
    @Published public var playbackSpeed: String = "1.0x"
    @Published public var trackTitle: String = "Daily Gospel Narration"
    @Published public var trackSubtitle: String = "Narrated by Jonathan Roumie"
    @Published public var isLoaded: Bool = false
    @Published public var hasStartedPlayback: Bool = false
    @Published public var isFullPlayerPresented: Bool = false
    @Published public var showMiniPlayer: Bool = false
    
    /// Mini-player appears only when playback has started AND the user is not currently inside the full player view
    public var shouldShowMiniPlayer: Bool {
        showMiniPlayer && !isFullPlayerPresented
    }
    
    // MARK: - Private Properties
    private var player: AVAudioPlayer?
    private var timer: AnyCancellable?
    private var isUserScrubbing: Bool = false
    
    private let speedOptions: [(label: String, rate: Float)] = [
        ("0.75x", 0.75),
        ("1.0x", 1.0),
        ("1.25x", 1.25),
        ("1.5x", 1.5),
        ("2.0x", 2.0)
    ]
    private var currentSpeedIndex: Int = 1
    
    public override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Audio Session Configuration
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.defaultToSpeaker, .allowAirPlay])
            try session.setActive(true)
        } catch {
            print("AudioPlayerManager: Failed to configure audio session - \(error)")
        }
    }
    
    // MARK: - Audio Loading
    public func loadAudio(
        named fileName: String = "inspiring-cinematic-ambient-116199",
        title: String? = nil,
        subtitle: String? = nil,
        autoPlay: Bool = false
    ) {
        if let title = title {
            self.trackTitle = title
        }
        if let subtitle = subtitle {
            self.trackSubtitle = subtitle
        }
        
        guard let url = findAudioURL(named: fileName) else {
            print("AudioPlayerManager: Could not locate audio file '\(fileName)' in bundle or Musics folder.")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.enableRate = true
            player?.prepareToPlay()
            
            if let player = player {
                duration = player.duration
                currentTime = 0
                progress = 0
                isLoaded = true
                applyCurrentSpeed()
                
                if autoPlay {
                    play()
                }
            }
        } catch {
            print("AudioPlayerManager: Error initializing AVAudioPlayer: \(error)")
        }
    }
    
    // MARK: - URL Resolution in Bundle & Musics Group
    private func findAudioURL(named name: String) -> URL? {
        let cleanName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension.isEmpty ? "mp3" : (name as NSString).pathExtension
        
        // 1. Check main bundle root
        if let url = Bundle.main.url(forResource: cleanName, withExtension: ext) {
            return url
        }
        // 2. Check Musics subdirectory
        if let url = Bundle.main.url(forResource: cleanName, withExtension: ext, subdirectory: "Musics") {
            return url
        }
        // 3. Check exact name as provided
        if let url = Bundle.main.url(forResource: name, withExtension: nil) {
            return url
        }
        // 4. Check Musics subfolder with exact name
        if let url = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: "Musics") {
            return url
        }
        // 5. Fallback to any MP3 found in bundle
        if let urls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "Musics"), let first = urls.first {
            return first
        }
        if let urls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil), let first = urls.first {
            return first
        }
        return nil
    }
    
    // MARK: - Playback Controls
    public func play() {
        self.hasStartedPlayback = true
        self.showMiniPlayer = true
        guard let player = player else {
            loadAudio(autoPlay: true)
            return
        }
        
        applyCurrentSpeed()
        player.play()
        isPlaying = true
        startProgressTimer()
        
        // Real-Time Live Activity & Dynamic Island Trigger
        LiveActivityManager.shared.startActivity(
            title: trackTitle,
            subtitle: trackSubtitle,
            duration: duration
        )
    }
    
    public func pause() {
        player?.pause()
        isPlaying = false
        stopProgressTimer()
        
        // Update Live Activity to paused state
        LiveActivityManager.shared.updateActivity(isPlaying: false)
    }
    
    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    public func stop() {
        player?.stop()
        player?.currentTime = 0
        currentTime = 0
        progress = 0
        isPlaying = false
        stopProgressTimer()
        
        // End Live Activity session
        LiveActivityManager.shared.endActivity()
    }
    
    public func dismissMiniPlayer() {
        pause()
        showMiniPlayer = false
        hasStartedPlayback = false
        LiveActivityManager.shared.endActivity()
    }
    
    // MARK: - Seeking & Scrubbing
    public func seek(to newProgress: Double) {
        guard let player = player, duration > 0 else { return }
        let clampedProgress = min(max(newProgress, 0), 1)
        let targetTime = duration * clampedProgress
        player.currentTime = targetTime
        self.currentTime = targetTime
        self.progress = clampedProgress
    }
    
    public func onScrubbingChanged(isScrubbing: Bool, progressValue: Double) {
        self.isUserScrubbing = isScrubbing
        if isScrubbing {
            stopProgressTimer()
            self.currentTime = duration * progressValue
            self.progress = progressValue
        } else {
            seek(to: progressValue)
            if isPlaying {
                startProgressTimer()
            }
        }
    }
    
    public func skipForward(_ seconds: Double = 15) {
        guard let player = player else { return }
        let newTime = min(player.currentTime + seconds, player.duration)
        player.currentTime = newTime
        updateTimeAndProgress()
    }
    
    public func skipBackward(_ seconds: Double = 15) {
        guard let player = player else { return }
        let newTime = max(player.currentTime - seconds, 0)
        player.currentTime = newTime
        updateTimeAndProgress()
    }
    
    public func skipForward(by seconds: Double) {
        skipForward(seconds)
    }
    
    public func skipBackward(by seconds: Double) {
        skipBackward(seconds)
    }
    
    // MARK: - Speed Multiplier
    public func cyclePlaybackSpeed() {
        currentSpeedIndex = (currentSpeedIndex + 1) % speedOptions.count
        let currentOption = speedOptions[currentSpeedIndex]
        playbackSpeed = currentOption.label
        applyCurrentSpeed()
    }
    
    private func applyCurrentSpeed() {
        guard let player = player else { return }
        let rate = speedOptions[currentSpeedIndex].rate
        player.rate = rate
    }
    
    // MARK: - Timer & Progress Sync
    private func startProgressTimer() {
        stopProgressTimer()
        timer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isUserScrubbing else { return }
                self.updateTimeAndProgress()
            }
    }
    
    private func stopProgressTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func updateTimeAndProgress() {
        guard let player = player, player.duration > 0 else { return }
        self.currentTime = player.currentTime
        self.duration = player.duration
        self.progress = player.currentTime / player.duration
        self.isPlaying = player.isPlaying
    }
    
    // MARK: - AVAudioPlayerDelegate
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopProgressTimer()
        currentTime = 0
        progress = 0
        self.player?.currentTime = 0
        LiveActivityManager.shared.endActivity()
    }
    
    // MARK: - Time String Formatting
    public var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    public var formattedRemainingTime: String {
        let remaining = max(0, duration - currentTime)
        return "-\(formatTime(remaining))"
    }
    
    public var formattedDuration: String {
        formatTime(duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && !time.isInfinite && time >= 0 else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
