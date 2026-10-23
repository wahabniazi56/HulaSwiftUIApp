//
//  GuideProfileDetailView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct GuideProfileDetailView: View {
    @EnvironmentObject private var router: Router
    
    public let guideName: String
    public let role: String
    public let iconName: String
    
    @State private var isFollowing: Bool = false
    
    public init(
        guideName: String = "Jonathan Roumie",
        role: String = "Actor & Narrator",
        iconName: String = "person.crop.circle.fill"
    ) {
        self.guideName = guideName
        self.role = role
        self.iconName = iconName
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 54)
                    
                    // Profile Header Card
                    profileHeaderCard
                    
                    // Featured Series by Guide
                    seriesSection
                    
                    // Popular Prayers Section
                    popularPrayersSection
                    
                    Color.clear.frame(height: 32)
                }
                .padding(.horizontal, 18)
            }
            
            // Glass Navigation Bar
            glassNavBar
        }
        .navigationBarBackButtonHidden(true)
    }
    
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
            
            Text(guideName)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Spacer()
            
            Color.clear.frame(width: 42, height: 42)
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
    
    private var profileHeaderCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.65, green: 0.45, blue: 0.25), Color(red: 0.30, green: 0.18, blue: 0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 86, height: 86)
                
                Image(systemName: iconName)
                    .font(.system(size: 48))
                    .foregroundStyle(Color.white.opacity(0.9))
            }
            .overlay(Circle().strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5))
            
            VStack(spacing: 3) {
                Text(guideName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Text(role)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            
            Text("Known for portraying Jesus in The Chosen, Jonathan leads peaceful daily gospel audio reflections and sacred scriptures on Hallow.")
                .font(.system(size: 13, weight: .regular))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white.opacity(0.8))
                .padding(.horizontal, 10)
            
            // Follow button
            Button {
                withAnimation { isFollowing.toggle() }
            } label: {
                Text(isFollowing ? "Following" : "Follow Guide")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(isFollowing ? Color.white : Color.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background {
                        if isFollowing {
                            Capsule().strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                        } else {
                            Capsule().fill(Color.white)
                        }
                    }
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 24)
    }
    
    private var seriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Series")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            HStack(spacing: 12) {
                seriesItem(title: "The Chosen Reflections", count: "14 Sessions", gradient: [Color(red: 0.18, green: 0.40, blue: 0.50), Color(red: 0.08, green: 0.18, blue: 0.25)])
                seriesItem(title: "Daily Gospel Companion", count: "Daily Refresh", gradient: [Color(red: 0.50, green: 0.25, blue: 0.35), Color(red: 0.22, green: 0.10, blue: 0.16)])
            }
        }
    }
    
    private func seriesItem(title: String, count: String, gradient: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 100)
                
                Text(count)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.4), in: Capsule())
                    .padding(10)
            }
            
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var popularPrayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Audio Tracks")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            VStack(spacing: 10) {
                trackRow(title: "The Lord's Prayer", duration: "3 min")
                trackRow(title: "Peace at the Close of Day", duration: "10 min")
                trackRow(title: "Sermon on the Mount Reflection", duration: "8 min")
            }
        }
    }
    
    private func trackRow(title: String, duration: String) -> some View {
        Button {
            router.present(.dailyGospelDetail(title: title, subtitle: "\(guideName) • \(duration)"), style: .push)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white)
                    .frame(width: 34, height: 34)
                    .liquidGlassCircle()
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Text(duration)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.6))
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            .padding(12)
            .liquidGlass(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RouterView {
        GuideProfileDetailView()
    }
}
