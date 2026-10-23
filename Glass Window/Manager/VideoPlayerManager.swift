//
//  VideoPlayerManager.swift
//  Glass Window
//
//  Created by mac on 29/09/2026.
//

import SwiftUI
import AVFoundation
import AVKit
import Combine

/// A dedicated manager responsible for remote video streaming, AVPlayer lifecycle,
/// Picture-in-Picture (PiP) backgrounding, buffering state, playback controls, time observation, and audio-session handling.
public final class VideoPlayerManager: NSObject, ObservableObject {
    
    // MARK: - Shared Singleton Instance
    public static let shared = VideoPlayerManager()
    
    // MARK: - Reliable Online Stream Defaults
    public static let defaultOnlineURL = URL(string: "https://vjs.zencdn.net/v/oceans.mp4")!
    public static let fallbackOnlineURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
    
    // MARK: - Published State
    @Published public var player: AVPlayer?
    @Published public var isPlaying: Bool = false
    @Published public var isMuted: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var isFailed: Bool = false
    @Published public var currentTime: Double = 0
    @Published public var duration: Double = 0
    @Published public var progress: Double = 0
    @Published public var bufferedProgress: Double = 0
    @Published public var bufferedDuration: Double = 0
    @Published public var showControls: Bool = true
    @Published public var isFullScreen: Bool = false
    @Published public var currentURL: URL?
    @Published public var currentTitle: String = "Gospel Reflection Video"
    @Published public var currentSubtitle: String = "Visual Homily & Sacred Meditation"
    
    // MARK: - Picture in Picture (PiP) State
    @Published public var isPictureInPictureActive: Bool = false
    @Published public var isPictureInPicturePossible: Bool = false
    @Published public var isPictureInPictureSupported: Bool = AVPictureInPictureController.isPictureInPictureSupported()
    
    // MARK: - Callbacks
    public var onPlay: (() -> Void)?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var timeObserver: Any?
    private var dismissTimerCancellable: AnyCancellable?
    private var pipController: AVPictureInPictureController?
    private var pipPossibleObservation: NSKeyValueObservation?
    
    // MARK: - Init & Deinit
    public init(videoURL: URL? = nil, onPlay: (() -> Void)? = nil) {
        self.onPlay = onPlay
        super.init()
        if let videoURL = videoURL {
            setupPlayer(with: videoURL)
        }
    }
    
    deinit {
        teardown()
    }
    
    // MARK: - Player Setup & Lifecycle
    public func setupPlayer(with targetURL: URL) {
        teardown()
        currentURL = targetURL
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback)
            try session.setActive(true)
        } catch {
            print("VideoPlayerManager: AudioSession configuration failed - \(error)")
        }
        
        isLoading = true
        isFailed = false
        
        let asset = AVURLAsset(
            url: targetURL,
            options: ["AVURLAssetHTTPHeaderFieldsKey": ["User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)"]]
        )
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredForwardBufferDuration = 15.0 // Maintain generous forward buffer in RAM
        
        let newPlayer = AVPlayer(playerItem: playerItem)
        newPlayer.automaticallyWaitsToMinimizeStalling = true
        newPlayer.isMuted = isMuted
        self.player = newPlayer
        
        // 1. Observe AVPlayerItem status (ready / failed)
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .readyToPlay:
                    self.isLoading = false
                    self.isFailed = false
                    if let item = self.player?.currentItem {
                        let sec = item.duration.seconds
                        if sec.isFinite && sec > 0 {
                            self.duration = sec
                            self.updateBufferedProgress(for: item)
                        }
                    }
                case .failed:
                    self.isLoading = false
                    self.isFailed = true
                    print("VideoPlayerManager: AVPlayerItem failed - \(String(describing: playerItem.error))")
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // 2. Observe loadedTimeRanges for Secondary Buffer / Cache Progress Bar
        playerItem.publisher(for: \.loadedTimeRanges)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeRanges in
                guard let self = self else { return }
                self.updateBufferedProgress(from: timeRanges)
            }
            .store(in: &cancellables)
        
        // 3. Observe buffer empty & likely to keep up states
        playerItem.publisher(for: \.isPlaybackBufferEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                if isEmpty {
                    self?.isLoading = true
                }
            }
            .store(in: &cancellables)
            
        playerItem.publisher(for: \.isPlaybackLikelyToKeepUp)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLikely in
                guard let self = self else { return }
                if isLikely && self.isPlaying {
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
        
        // 4. Observe AVPlayer timeControlStatus (playing / paused / buffering)
        newPlayer.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .playing:
                    self.isPlaying = true
                    self.isLoading = false
                case .paused:
                    self.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    self.isLoading = true
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // 5. Periodic Time Observer for smooth timeline updates
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, time.isValid && !time.isIndefinite else { return }
            self.currentTime = time.seconds
            if self.duration > 0 {
                self.progress = self.currentTime / self.duration
            }
            if let item = newPlayer.currentItem {
                let dur = item.duration.seconds
                if dur.isFinite && dur > 0 && self.duration == 0 {
                    self.duration = dur
                    self.isLoading = false
                }
            }
        }
        
        // 6. Notification for playback completion
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isPlaying = false
                self.showControls = true
                self.player?.seek(to: .zero)
                self.currentTime = 0
                self.progress = 0
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Buffer Calculation Helper
    private func updateBufferedProgress(for item: AVPlayerItem) {
        updateBufferedProgress(from: item.loadedTimeRanges)
    }
    
    private func updateBufferedProgress(from timeRanges: [NSValue]) {
        guard let timeRangeValue = timeRanges.first else { return }
        let timeRange = timeRangeValue.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSeconds = CMTimeGetSeconds(timeRange.duration)
        let totalLoaded = startSeconds + durationSeconds
        
        if totalLoaded.isFinite && totalLoaded >= 0 {
            self.bufferedDuration = totalLoaded
            if self.duration > 0 {
                self.bufferedProgress = min(max(totalLoaded / self.duration, 0.0), 1.0)
            }
        }
    }
    
    public func retryWithFallback() {
        setupPlayer(with: Self.fallbackOnlineURL)
    }
    
    public func teardown() {
        dismissTimerCancellable?.cancel()
        dismissTimerCancellable = nil
        
        pipPossibleObservation?.invalidate()
        pipPossibleObservation = nil
        if pipController?.isPictureInPictureActive == true {
            pipController?.stopPictureInPicture()
        }
        pipController = nil
        isPictureInPictureActive = false
        
        player?.pause()
        isPlaying = false
        bufferedProgress = 0
        bufferedDuration = 0
        
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        cancellables.removeAll()
        player = nil
    }
    
    // MARK: - Picture in Picture (PiP) Configuration & Controls
    public func attachPlayerLayer(_ playerLayer: AVPlayerLayer) {
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }
        
        if pipController?.playerLayer === playerLayer {
            return
        }
        
        pipPossibleObservation?.invalidate()
        pipPossibleObservation = nil
        
        let controller = AVPictureInPictureController(playerLayer: playerLayer)
        controller?.delegate = self
        if #available(iOS 14.2, *) {
            controller?.canStartPictureInPictureAutomaticallyFromInline = true
        }
        self.pipController = controller
        
        pipPossibleObservation = controller?.observe(\.isPictureInPicturePossible, options: [.initial, .new]) { [weak self] pip, _ in
            DispatchQueue.main.async {
                self?.isPictureInPicturePossible = pip.isPictureInPicturePossible
            }
        }
    }
    
    public func startPictureInPicture() {
        guard let pipController = pipController, pipController.isPictureInPicturePossible else { return }
        pipController.startPictureInPicture()
    }
    
    public func stopPictureInPicture() {
        pipController?.stopPictureInPicture()
    }
    
    public func togglePictureInPicture() {
        if isPictureInPictureActive {
            stopPictureInPicture()
        } else {
            startPictureInPicture()
        }
    }
    
    // MARK: - Playback Controls
    public func play() {
        guard let player = player else {
            if let url = currentURL {
                setupPlayer(with: url)
            } else {
                setupPlayer(with: Self.defaultOnlineURL)
            }
            return
        }
        onPlay?() // Coordinate with other audio sources
        player.play()
        isPlaying = true
        scheduleControlsDismiss()
    }
    
    public func pause() {
        player?.pause()
        isPlaying = false
        showControls = true
        dismissTimerCancellable?.cancel()
    }
    
    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    public func toggleMute() {
        isMuted.toggle()
        player?.isMuted = isMuted
    }
    
    public func seek(to timeInSeconds: Double) {
        guard let player = player else { return }
        let clampedTime = max(0, min(timeInSeconds, duration > 0 ? duration : timeInSeconds))
        let targetCMTime = CMTime(seconds: clampedTime, preferredTimescale: 600)
        player.seek(to: targetCMTime, toleranceBefore: .zero, toleranceAfter: .zero)
        self.currentTime = clampedTime
        if duration > 0 {
            self.progress = clampedTime / duration
        }
    }
    
    public func seek(progress newProgress: Double) {
        guard duration > 0 else { return }
        let clamped = max(0, min(newProgress, 1.0))
        seek(to: clamped * duration)
    }
    
    public func skip(by seconds: Double) {
        let newTime = max(0, min(currentTime + seconds, max(duration, 1)))
        seek(to: newTime)
    }
    
    public func skipForward(_ seconds: Double = 15) {
        skip(by: seconds)
    }
    
    public func skipBackward(_ seconds: Double = 15) {
        skip(by: -seconds)
    }
    
    // MARK: - Controls Visibility & Auto-Dismiss
    public func toggleControls() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showControls.toggle()
        }
        if showControls && isPlaying {
            scheduleControlsDismiss()
        }
    }
    
    public func setControls(visible: Bool) {
        withAnimation(.easeInOut(duration: 0.25)) {
            showControls = visible
        }
        if visible && isPlaying {
            scheduleControlsDismiss()
        }
    }
    
    public func scheduleControlsDismiss(after seconds: Double = 3.5) {
        dismissTimerCancellable?.cancel()
        dismissTimerCancellable = Timer.publish(every: seconds, on: .main, in: .common)
            .autoconnect()
            .prefix(1)
            .sink { [weak self] _ in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    if self.isPlaying {
                        self.showControls = false
                    }
                }
            }
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
    
    public func formatTime(_ time: Double) -> String {
        guard !time.isNaN && !time.isInfinite && time >= 0 else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - AVPictureInPictureControllerDelegate
extension VideoPlayerManager: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPictureInPictureActive = true
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPictureInPictureActive = true
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // Pre-stop transition
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPictureInPictureActive = false
    }
    
    public func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        isPictureInPictureActive = false
        print("VideoPlayerManager: PiP failed to start - \(error.localizedDescription)")
    }
    
    public func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        // Return completionHandler(true) to allow smooth restore transition
        completionHandler(true)
    }
}
