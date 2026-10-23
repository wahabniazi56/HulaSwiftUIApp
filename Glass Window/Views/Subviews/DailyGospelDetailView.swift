//
//  DailyGospelDetailView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct DailyGospelDetailView: View {
    @EnvironmentObject private var router: Router
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    
    public let title: String
    public let subtitle: String
    
    public init(
        title: String = "Thu Sep 24: Daily Gospel",
        subtitle: String = "Thursday of the Twenty-Fifth Week in Ordinary Time"
    ) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    Color.clear.frame(height: 54)
                    
                    // Hero Glass Artwork (Static)
                    heroArtworkCard
                    
                    // Audio Player Glass Console (Dynamic AVFoundation Player)
                    playerConsoleCard
                    
                    // Online Video Reflection Player Section (Dynamic Online Stream)
                    videoReflectionSection
                    
                    // Gospel Reading Text Card (Static)
                    gospelTextCard
                    
                    // Liturgical Reflection Points (Static)
                    reflectionPointsCard
                    
                    // Bottom spacing
                    Color.clear.frame(height: 32)
                }
                .padding(.horizontal, 18)
            }
            
            // Glass Navigation Bar
            glassNavBar
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            AudioPlayerManager.shared.isFullPlayerPresented = true
            if audioPlayer.trackTitle != title {
                audioPlayer.loadAudio(named: "inspiring-cinematic-ambient-116199", title: title, subtitle: subtitle)
            }
        }
        .onDisappear {
            AudioPlayerManager.shared.isFullPlayerPresented = false
        }
    }
    
    // MARK: - Navigation Bar
    private var glassNavBar: some View {
        HStack {
            Button {
                router.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 42, height: 42)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("Daily Gospel")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Spacer()
            
            Button {
                // Share action
                let shareText = "\(title)\n\(subtitle)\n\nLuke 9:7-9"
                let av = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                if let root = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows.first?.rootViewController {
                    root.present(av, animated: true)
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 42, height: 42)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(Color.white.opacity(0.12)).frame(height: 0.8)
                }
        }
    }
    
    // MARK: - Hero Artwork (Static)
    private var heroArtworkCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.42, blue: 0.35),
                            Color(red: 0.06, green: 0.22, blue: 0.20),
                            Color(red: 0.03, green: 0.10, blue: 0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 220)
            
            // Atmospheric Glow & Cathedral Window Silhouette
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 110, height: 160)
                    .rotationEffect(.degrees(8))
                    .offset(x: 20, y: -20)
            }
            .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("TODAY'S GOSPEL")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.18), in: Capsule())
                
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .lineLimit(2)
            }
            .padding(20)
        }
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Player Console Card (Dynamic & Interactive)
    private var playerConsoleCard: some View {
        VStack(spacing: 16) {
            // Guide Info & Speed Control
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.25, green: 0.45, blue: 0.40))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Narrated by Jonathan Roumie")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    
                    Text("Audio Track • \(audioPlayer.duration > 0 ? audioPlayer.formattedDuration : "8 mins")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.65))
                }
                
                Spacer()
                
                // Playback Speed Toggle Button
                Button {
                    audioPlayer.cyclePlaybackSpeed()
                } label: {
                    Text(audioPlayer.playbackSpeed)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .liquidGlassCapsule()
                }
                .buttonStyle(.plain)
            }
            
            // Interactive Progress Scrubber
            VStack(spacing: 6) {
                Slider(
                    value: Binding(
                        get: { audioPlayer.progress },
                        set: { newValue in
                            audioPlayer.seek(to: newValue)
                        }
                    ),
                    in: 0...1,
                    onEditingChanged: { isScrubbing in
                        audioPlayer.onScrubbingChanged(isScrubbing: isScrubbing, progressValue: audioPlayer.progress)
                    }
                )
                .tint(Color.white)
                
                HStack {
                    Text(audioPlayer.formattedCurrentTime)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.75))
                    
                    Spacer()
                    
                    Text(audioPlayer.formattedRemainingTime)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
            }
            
            // Audio Controls (Rewind 15s, Play/Pause, Forward 15s)
            HStack(spacing: 38) {
                // Rewind 15s
                Button {
                    audioPlayer.skipBackward(by: 15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.white)
                        .frame(width: 44, height: 44)
                        .liquidGlassCircle()
                }
                .buttonStyle(.plain)
                
                // Play / Pause Button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        audioPlayer.togglePlayPause()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 62, height: 62)
                            .shadow(color: audioPlayer.isPlaying ? Color.white.opacity(0.35) : Color.black.opacity(0.25), radius: audioPlayer.isPlaying ? 12 : 8, x: 0, y: 4)
                        
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.black.opacity(0.85))
                            .offset(x: audioPlayer.isPlaying ? 0 : 2)
                    }
                }
                .buttonStyle(.plain)
                
                // Forward 15s
                Button {
                    audioPlayer.skipForward(by: 15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.white)
                        .frame(width: 44, height: 44)
                        .liquidGlassCircle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22)
    }
    
    // MARK: - Online Video Reflection Section
    private var videoReflectionSection: some View {
        GlassVideoPlayerView(
            videoURL: URL(string: "https://vjs.zencdn.net/v/oceans.mp4")!,
            title: "Gospel Reflection Video",
            subtitle: "Visual Homily & Sacred Meditation",
            onPlay: {
                audioPlayer.pause()
            }
        )
    }
    
    // MARK: - Gospel Text Card (Static)
    private var gospelTextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("THE HOLY GOSPEL")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.50))
                
                Spacer()
                
                Text("Luke 9:7-9")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            
            Text("Herod the tetrarch heard about all that was happening, and he was greatly perplexed because some were saying, 'John has been raised from the dead'; others were saying, 'Elijah has appeared'; still others, 'One of the ancient prophets has arisen.'")
                .font(.system(size: 15, weight: .regular, design: .serif))
                .lineSpacing(6)
                .foregroundStyle(Color.white.opacity(0.92))
            
            Text("But Herod said, 'John I beheaded. Who then is this about whom I hear such things?' And he kept trying to see him.")
                .font(.system(size: 15, weight: .regular, design: .serif))
                .lineSpacing(6)
                .foregroundStyle(Color.white.opacity(0.92))
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22)
    }
    
    // MARK: - Reflection Points Card (Static)
    private var reflectionPointsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Daily Reflection")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            reflectionItem(number: "1", text: "Notice Herod's curiosity versus true faith. Do we seek Jesus out of curiosity, or with an open heart ready to be transformed?")
            reflectionItem(number: "2", text: "Take two minutes of silence to bring any uncertainties in your life before Christ today.")
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22)
    }
    
    private func reflectionItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .frame(width: 26, height: 26)
                .liquidGlassCircle()
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .lineSpacing(4)
                .foregroundStyle(Color.white.opacity(0.85))
        }
    }
}

#Preview {
    RouterView {
        DailyGospelDetailView()
    }
}
