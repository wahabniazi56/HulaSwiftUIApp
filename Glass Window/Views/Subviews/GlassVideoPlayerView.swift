//
//  GlassVideoPlayerView.swift
//  Glass Window
//
//  Created by mac on 29/09/2026.
//

import SwiftUI
import AVKit

public struct GlassVideoPlayerView: View {
    // MARK: - Properties
    public let videoURL: URL
    public let title: String
    public let subtitle: String
    public var onPlay: (() -> Void)?
    
    // Convenience references to VideoPlayerManager static streams
    public static let defaultOnlineURL = VideoPlayerManager.defaultOnlineURL
    public static let fallbackOnlineURL = VideoPlayerManager.fallbackOnlineURL
    
    // MARK: - State Management
    @ObservedObject private var playerManager: VideoPlayerManager
    
    // MARK: - Initializer
    public init(
        videoURL: URL = VideoPlayerManager.defaultOnlineURL,
        title: String = "Gospel Video Reflection",
        subtitle: String = "Visual Homily & Sacred Meditation",
        playerManager: VideoPlayerManager = .shared,
        onPlay: (() -> Void)? = nil
    ) {
        self.videoURL = videoURL
        self.title = title
        self.subtitle = subtitle
        self.playerManager = playerManager
        self.onPlay = onPlay
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            sectionHeader
            
            // Video Screen Container
            ZStack {
                // Video Stream Surface
                playerSurface
                
                // Dark Gradient for Controls Contrast
                if playerManager.showControls || !playerManager.isPlaying || playerManager.isFailed {
                    controlsGradientOverlay
                }
                
                // Loading Spinner
                if playerManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.4)
                }
                
                // Error State with Retry
                if playerManager.isFailed {
                    failedStateOverlay
                }
                
                // Active Controls Overlay
                if (playerManager.showControls || !playerManager.isPlaying) && !playerManager.isFailed {
                    controlsOverlay
                }
            }
            .frame(height: 220)
            .liquidGlass(cornerRadius: 22)
            .contentShape(Rectangle())
            .onTapGesture {
                playerManager.toggleControls()
            }
        }
        .onAppear {
            playerManager.currentTitle = title
            playerManager.currentSubtitle = subtitle
            playerManager.onPlay = onPlay
            if playerManager.player == nil {
                playerManager.setupPlayer(with: videoURL)
            }
        }
        .onDisappear {
            if !playerManager.isPictureInPictureActive && !playerManager.isFullScreen {
                playerManager.teardown()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var sectionHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "video.fill")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.50))
            
            Text("VIDEO REFLECTION")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(1.2)
                .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.50))
            
            Spacer()
            
            Text("Online Stream")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.85))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .liquidGlassCapsule()
        }
        .padding(.horizontal, 4)
    }
    
    private var playerSurface: some View {
        Group {
            if playerManager.player != nil {
                VideoPlayerLayerRepresentable(playerManager: playerManager)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.22, blue: 0.35),
                                Color(red: 0.08, green: 0.12, blue: 0.20)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }
    
    private var controlsGradientOverlay: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.65),
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.75)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .transition(.opacity)
    }
    
    private var failedStateOverlay: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.orange)
            
            Text("Stream Unavailable")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Button {
                playerManager.retryWithFallback()
            } label: {
                Text("Retry Connection")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
    
    private var controlsOverlay: some View {
        VStack {
            // Top Bar (Title, Mute, Fullscreen)
            topControlBar
            
            Spacer()
            
            // Center Playback Buttons (Rewind 15s, Play/Pause Orb, Forward 15s)
            centerControlBar
            
            Spacer()
            
            // Bottom Timeline & Scrubber
            bottomTimelineBar
        }
        .transition(.opacity)
    }
    
    private var topControlBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Picture in Picture Button
            if playerManager.isPictureInPictureSupported {
                Button {
                    playerManager.togglePictureInPicture()
                } label: {
                    Image(systemName: playerManager.isPictureInPictureActive ? "pip.exit" : "pip.enter")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 34, height: 34)
                        .liquidGlassCircle()
                }
                .buttonStyle(.plain)
                .opacity(playerManager.isPictureInPicturePossible ? 1.0 : 0.45)
                .disabled(!playerManager.isPictureInPicturePossible)
            }
            
            // Mute Button
            Button {
                playerManager.toggleMute()
            } label: {
                Image(systemName: playerManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 34, height: 34)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
            
            // Fullscreen Button
            Button {
                OrientationManager.rotate(to: .landscape)
                playerManager.isFullScreen = true
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 34, height: 34)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }
    
    private var centerControlBar: some View {
        HStack(spacing: 36) {
            // Rewind 15s
            Button {
                playerManager.skipBackward(15)
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.white)
                    .frame(width: 42, height: 42)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
            
            // Central Play / Pause Orb
            Button {
                playerManager.togglePlayPause()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 58, height: 58)
                        .shadow(
                            color: playerManager.isPlaying ? Color.white.opacity(0.35) : Color.black.opacity(0.3),
                            radius: playerManager.isPlaying ? 10 : 6,
                            x: 0,
                            y: 3
                        )
                    
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .offset(x: playerManager.isPlaying ? 0 : 2)
                }
            }
            .buttonStyle(.plain)
            
            // Forward 15s
            Button {
                playerManager.skipForward(15)
            } label: {
                Image(systemName: "goforward.15")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.white)
                    .frame(width: 42, height: 42)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
        }
    }
    
    @State private var isDraggingScrubber: Bool = false
    @State private var scrubProgress: Double = 0
    
    private var bottomTimelineBar: some View {
        VStack(spacing: 6) {
            // YouTube / Apple TV style Layered Scrubber Bar
            GeometryReader { geometry in
                let width = max(0, geometry.size.width)
                let activeProgress = isDraggingScrubber ? scrubProgress : playerManager.progress
                let bufferedProgress = playerManager.bufferedProgress
                
                ZStack(alignment: .leading) {
                    // 1. Background Track
                    Capsule()
                        .fill(Color.white.opacity(0.20))
                        .frame(height: isDraggingScrubber ? 6 : 4)
                    
                    // 2. Secondary Loaded/Buffered Cache Track (Translucent buffer window)
                    Capsule()
                        .fill(Color.white.opacity(0.42))
                        .frame(width: width * CGFloat(bufferedProgress), height: isDraggingScrubber ? 6 : 4)
                        .animation(.easeInOut(duration: 0.25), value: bufferedProgress)
                    
                    // 3. Active Playhead Track
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(red: 0.95, green: 0.82, blue: 0.55)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width * CGFloat(activeProgress), height: isDraggingScrubber ? 6 : 4)
                    
                    // 4. Interactive Scrubber Thumb (Knob)
                    Circle()
                        .fill(Color.white)
                        .frame(width: isDraggingScrubber ? 15 : 11, height: isDraggingScrubber ? 15 : 11)
                        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 1)
                        .offset(x: max(0, min(width * CGFloat(activeProgress) - (isDraggingScrubber ? 7.5 : 5.5), width - (isDraggingScrubber ? 15 : 11))))
                }
                .frame(height: 24)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDraggingScrubber = true
                            let newProgress = max(0.0, min(Double(value.location.x / width), 1.0))
                            scrubProgress = newProgress
                        }
                        .onEnded { value in
                            let finalProgress = max(0.0, min(Double(value.location.x / width), 1.0))
                            playerManager.seek(progress: finalProgress)
                            isDraggingScrubber = false
                        }
                )
            }
            .frame(height: 20)
            
            // Timestamps
            HStack {
                Text(isDraggingScrubber ? playerManager.formatTime(scrubProgress * playerManager.duration) : playerManager.formattedCurrentTime)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.85))
                
                Spacer()
                
                // Buffer percentage indicator & remaining time
//                HStack(spacing: 6) {
//                    if playerManager.bufferedProgress > 0 && playerManager.bufferedProgress < 1.0 {
//                        Text("\(Int(playerManager.bufferedProgress * 100))% buffered")
//                            .font(.system(size: 10, weight: .regular))
//                            .foregroundStyle(Color.white.opacity(0.55))
//                    }
                    
                    Text(playerManager.formattedRemainingTime)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.85))
//                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

// MARK: - Custom Video Player Layer Representable
public struct VideoPlayerLayerRepresentable: UIViewRepresentable {
    @ObservedObject public var playerManager: VideoPlayerManager
    
    public init(playerManager: VideoPlayerManager) {
        self.playerManager = playerManager
    }
    
    public func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = playerManager.player
        view.playerLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .black
        playerManager.attachPlayerLayer(view.playerLayer)
        return view
    }
    
    public func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if uiView.playerLayer.player !== playerManager.player {
            uiView.playerLayer.player = playerManager.player
        }
        playerManager.attachPlayerLayer(uiView.playerLayer)
    }
}

public class PlayerUIView: UIView {
    public override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    public var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

// MARK: - Fullscreen Video Modal
public struct FullScreenVideoModal: View {
    public let player: AVPlayer?
    public let title: String
    public let onDismiss: () -> Void
    
    public init(player: AVPlayer?, title: String, onDismiss: @escaping () -> Void) {
        self.player = player
        self.title = title
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }
            
            // Close Button
            Button {
                OrientationManager.rotate(to: .portrait)
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(20)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            OrientationManager.rotate(to: .landscape)
        }
        .onDisappear {
            OrientationManager.rotate(to: .portrait)
        }
    }
}

#Preview {
    ZStack {
        LiquidAtmosphereBackground()
        GlassVideoPlayerView()
            .padding()
    }
}
