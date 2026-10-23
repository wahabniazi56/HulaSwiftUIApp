//
//  MainTabView.swift
//  Glass Window
//
//  Created by mac on 24/09/2026.
//

import SwiftUI

public enum MainTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case overview = "Overview"
    case bible = "Bible"
    case spiritualGuide = "Ask AI"
    case discover = "Discover"
    case church = "Church"
    case me = "Me"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .overview: return "chart.bar.fill"
        case .bible: return "book.closed.fill"
        case .spiritualGuide: return "sparkles"
        case .discover: return "magnifyingglass"
        case .church: return "building.columns.fill"
        case .me: return "person.crop.circle.fill"
        }
    }
}

public struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @ObservedObject private var videoPlayer = VideoPlayerManager.shared
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Home Tab
                RouterView {
                    HomeView()
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(MainTab.home)
                
                // Bible Tab
                RouterView {
                    BibleView()
                }
                .tabItem {
                    Label("Bible", systemImage: "book.closed.fill")
                }
                .tag(MainTab.bible)
                
                // Discover Tab
                RouterView {
                    DiscoverView()
                }
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
                .tag(MainTab.discover)
                
                // Church Tab
                RouterView {
                    ChurchView()
                }
                .tabItem {
                    Label("Church", systemImage: "building.columns.fill")
                }
                .tag(MainTab.church)
                
                // Me Tab
                RouterView {
                    MeView()
                }
                .tabItem {
                    Label("Me", systemImage: "person.crop.circle.fill")
                }
                .tag(MainTab.me)
            }
            .tint(.white)
            
            // Persistent Mini-Player (Floats directly above the Tab Bar across all screens)
            if audioPlayer.shouldShowMiniPlayer {
                MiniPlayerView()
                    .padding(.horizontal, 12)
                    .padding(.bottom, 54)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
            }
            
            // Fullscreen Video Player Modal Overlay
            if videoPlayer.isFullScreen {
                FullScreenVideoModal(
                    player: videoPlayer.player,
                    title: videoPlayer.currentTitle,
                    onDismiss: {
                        OrientationManager.rotate(to: .portrait)
                        withAnimation(.easeInOut(duration: 0.25)) {
                            videoPlayer.isFullScreen = false
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(999)
                .ignoresSafeArea()
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: audioPlayer.shouldShowMiniPlayer)
        .animation(.easeInOut(duration: 0.25), value: videoPlayer.isFullScreen)
    }
}

#Preview {
    MainTabView()
}


