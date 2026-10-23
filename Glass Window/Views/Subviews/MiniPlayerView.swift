//
//  MiniPlayerView.swift
//  Glass Window
//
//  Created by mac on 13/10/2026.
//

import SwiftUI

/// Floating, persistent Mini-Player docked directly above the bottom tab bar.
/// Mirrors the exact design, typography, and controls from the Dominican Sisters Open Mic player screenshot.
public struct MiniPlayerView: View {
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    @EnvironmentObject private var router: Router
    
    @State private var isDraggingProgress: Bool = false
    @State private var dragProgress: Double = 0
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 12){
            
            // MARK: - 1. Left Thumbnail Artwork
            thumbnailArtwork
            
            VStack(spacing: 2){
                HStack(spacing: 12){
                    
                    
                    // MARK: - 2. Track Title (Dynamic & Single Line)
                    Text(audioPlayer.trackTitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: - 3. Controls (Rewind 15s, Play/Pause, Forward 15s, Options)
                    HStack(spacing: 14) {
                        // Rewind 15 Seconds
                        Button {
                            audioPlayer.skipBackward(15)
                        } label: {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(Color.white)
                        }
                        .buttonStyle(.plain)
                        
                        // Play / Pause Toggle
                        Button {
                            audioPlayer.togglePlayPause()
                        } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(Color.white)
                        }
                        .buttonStyle(.plain)
                        
                        // Forward 15 Seconds
                        Button {
                            audioPlayer.skipForward(15)
                        } label: {
                            Image(systemName: "goforward.15")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(Color.white)
                        }
                        .buttonStyle(.plain)
                        
                        // Options Menu (...)
                        Menu {
                            Section("Playback Speed") {
                                Button("0.75x") { setSpeed("0.75x") }
                                Button("1.0x (Normal)") { setSpeed("1.0x") }
                                Button("1.25x") { setSpeed("1.25x") }
                                Button("1.5x") { setSpeed("1.5x") }
                                Button("2.0x") { setSpeed("2.0x") }
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    audioPlayer.dismissMiniPlayer()
                                }
                            } label: {
                                Label("Close Player", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(Color.white)
                                .frame(width: 26, height: 26)
                        }
                    }
                }
                
                // MARK: - 4. Dynamic Interactive Progress Bar
                dynamicProgressBar
//                    .padding(.horizontal, 14)
                    .padding(.bottom, 3)
            }
            
        }
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .padding(.vertical, 10)
        .background {
            // Dark navy slate pill container matching the reference screenshot
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.08, green: 0.16, blue: 0.24))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.45), radius: 10, x: 0, y: 4)
        }
        .frame(height: 70)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//        .onTapGesture {
//            // Tapping body outside buttons reopens the Gospel player
//            router.present(
//                .dailyGospelDetail(title: audioPlayer.trackTitle, subtitle: audioPlayer.trackSubtitle),
//                style: .push
//            )
//        }
    }
    
    // MARK: - Dynamic Progress Bar
    private var dynamicProgressBar: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let rawProgress = (audioPlayer.progress.isNaN || audioPlayer.progress.isInfinite) ? 0.0 : audioPlayer.progress
            let currentProgress = isDraggingProgress ? dragProgress : rawProgress
            let clampedProgress = max(0.0, min(1.0, currentProgress))
            let progressWidth = totalWidth * CGFloat(clampedProgress)
            
            ZStack(alignment: .leading) {
                // Inactive Background Track
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(height: 2.5)
                
                // Active Progress Fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.45, green: 0.75, blue: 0.95), Color.white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, progressWidth), height: 2.5)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard totalWidth > 0 else { return }
                        isDraggingProgress = true
                        let percentage = max(0.0, min(1.0, Double(value.location.x / totalWidth)))
                        dragProgress = percentage
                        audioPlayer.onScrubbingChanged(isScrubbing: true, progressValue: percentage)
                    }
                    .onEnded { value in
                        guard totalWidth > 0 else { return }
                        let percentage = max(0.0, min(1.0, Double(value.location.x / totalWidth)))
                        audioPlayer.onScrubbingChanged(isScrubbing: false, progressValue: percentage)
                        isDraggingProgress = false
                    }
            )
            .animation(isDraggingProgress ? nil : .linear(duration: 0.2), value: audioPlayer.progress)
        }
        .frame(height: 12)
    }
    
    // MARK: - Artwork Thumbnail
    private var thumbnailArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.18, blue: 0.28), Color(red: 0.04, green: 0.10, blue: 0.16)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
            
            Image(systemName: "waveform")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 0.45, green: 0.75, blue: 0.95))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.8)
        }
    }
    
    private func setSpeed(_ speed: String) {
        // Cycle until matching speed is reached
        while audioPlayer.playbackSpeed != speed {
            audioPlayer.cyclePlaybackSpeed()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        MiniPlayerView()
            .padding(.horizontal, 12)
    }
}
