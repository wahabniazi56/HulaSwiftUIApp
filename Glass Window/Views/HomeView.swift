//
//  HomeView.swift
//  Glass Window
//
//  Created by mac on 24/09/2026.
//

import SwiftUI
import SuperwallKit

public struct HomeView: View {
    @EnvironmentObject private var router: Router
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Refractive Atmospheric Background
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Safe Area Space for Top Header
                    Color.clear.frame(height: 54)
                    
                    // 1. Hero Card: Daily Gospel
                    heroDailyGospelCard
                    
                    // 2. 4 Quick Action Glass Buttons
                    quickActionsGrid
                    
                    // 3. "What's on your heart today?" Card
                    whatsOnYourHeartCard
                    
                    // 4. Daily Scripture Glass Card (Philippians 4:6)
                    dailyScriptureCard
                    
                    // 5. Trending Horizontal Section (Fulton Sheen)
                    trendingSection
                    
                    // 6. Join the Challenge Banner
                    joinChallengeCard
                    
                    // Bottom Spacing for Floating Button & Mini Player
                    Color.clear.frame(height: 70)
                }
                .padding(.horizontal, 18)
            }
            
            // Glass Sticky Header
            glassHeader
            
            // Floating Glass AI Action Button
            floatingAIButton
        }
    }
    
    // MARK: - Glass Top Bar
    private var glassHeader: some View {
        HStack {
            Text("Home")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Spacer()
            
            // Step 4: Glass Paywall Button
            Button {
                // Triggers the Superwall paywall campaign (matches placement name on your dashboard)
                Superwall.shared.register(placement: "show_paywall")
            } label: {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 0.96, green: 0.82, blue: 0.42))
                    .frame(width: 44, height: 44)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
            
            // Glass Notification Bell Button
            Button {
                // Action
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 44, height: 44)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 0.8)
                }
        }
    }
    
    // MARK: - 1. Hero Daily Gospel Card
    private var heroDailyGospelCard: some View {
        Button {
            router.present(
                .dailyGospelDetail(
                    title: "Thu Sep 34: Daily Gospel",
                    subtitle: "Thursday of the Twenty-Fifth Week in Ordinary Time"
                ),
                style: .mediumSheet
            )
        } label: {
            VStack(spacing: 12) {
                ZStack(alignment: .bottomLeading) {
                    // Hero Artwork Gradient
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(red: 0.12, green: 0.38, blue: 0.32), location: 0),
                                    .init(color: Color(red: 0.08, green: 0.24, blue: 0.22), location: 0.6),
                                    .init(color: Color(red: 0.04, green: 0.12, blue: 0.14), location: 1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Architectural Window Silhouette Overlay
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 2)
                                .frame(width: 120, height: 180)
                                .rotationEffect(.degrees(5))
                                .offset(x: 20, y: -30)
                            
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 110, height: 110)
                                .blur(radius: 20)
                                .offset(x: 10, y: -50)
                        }
                    }
                    .clipped()
                    
                    // Center Play Glass Orb
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 58, height: 58)
                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Color.black.opacity(0.85))
                                    .offset(x: 2)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .offset(y: -22)
                    
                    // Content Titles
                    VStack(alignment: .leading, spacing: 6) {
                        // Category Tag
                        Text("Daily Gospel")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.15), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.25), lineWidth: 0.8))
                        
                        Text("Thu Sep 24: Daily Gospel")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                        
                        Text("Thursday of the Twenty-Fifth Week in Ordinary Time")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.75))
                            .lineLimit(2)
                    }
                    .padding(18)
                }
                .frame(height: 290)
                .liquidGlass(cornerRadius: 24)
                
                // Pagination Indicator
                HStack(spacing: 6) {
                    Circle().fill(Color.white).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.35)).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.35)).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.35)).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.35)).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.35)).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.35)).frame(width: 6, height: 6)
                }
                .padding(.top, 2)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 2. Quick Actions 4-Grid
    private var quickActionsGrid: some View {
        HStack(spacing: 10) {
            Button {
                router.present(.categoryDetail(categoryTitle: "Favorites", iconName: "star.fill"), style: .push)
            } label: {
                quickActionLabel(title: "Favorites", icon: "star")
            }
            .buttonStyle(.plain)
            
            Button {
                router.present(.spiritualChat, style: .sheet)
            } label: {
                quickActionLabel(title: "Ask AI", icon: "sparkles")
            }
            .buttonStyle(.plain)
            
            Button {
                router.present(.routineDetail(routineTitle: "Daily Routine", duration: "15 mins"), style: .push)
            } label: {
                quickActionLabel(title: "Routine", icon: "calendar")
            }
            .buttonStyle(.plain)
            
            Button {
                router.present(.dailyGospelDetail(title: "Recent Gospel Reflection", subtitle: "Luke 9:7-9"), style: .push)
            } label: {
                quickActionLabel(title: "Recents", icon: "clock")
            }
            .buttonStyle(.plain)
        }
    }
    
    private func quickActionLabel(title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.white)
                .frame(height: 24)
            
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.85))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .liquidGlass(cornerRadius: 18)
    }
    
    // MARK: - 3. What's On Your Heart Card
    private var whatsOnYourHeartCard: some View {
        Button {
            router.present(.whatsOnYourHeart, style: .push)
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("What's on your heart today?")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    
                    Text("Find your next personalized prayer")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.68))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.65))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .liquidGlass(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 4. Daily Scripture Card (Philippians 4:6)
    private var dailyScriptureCard: some View {
        Button {
            router.present(
                .dailyScriptureDetail(
                    reference: "Philippians 4:6",
                    quote: "Have no anxiety about anything, but in everything by prayer and supplication with thanksgiving let your requests be made known to God."
                ),
                style: .push
            )
        } label: {
            VStack(spacing: 14) {
                Text("PHILIPPIANS 4:6")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundStyle(Color(red: 0.92, green: 0.78, blue: 0.52))
                
                Text("\"Have no anxiety about anything, but in everything by prayer and supplication with thanksgiving let your requests be made known to God.\"")
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 4)
                
                // View Details Button
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                    Text("Read Context & Reflections")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .liquidGlassCapsule()
                .padding(.top, 4)
            }
            .padding(20)
            .liquidGlass(cornerRadius: 24)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 5. Trending Section (Fulton Sheen)
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trending")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    trendingItem(
                        title: "Best of Fulton Sheen",
                        subtitle: "Life is Worth Living",
                        detail: "📹 7 sessions",
                        gradient: [Color(red: 0.55, green: 0.20, blue: 0.38), Color(red: 0.25, green: 0.10, blue: 0.20)],
                        icon: "video.fill"
                    )
                    
                    trendingItem(
                        title: "Ven. Fulton Sheen",
                        subtitle: "Saints Alive",
                        detail: "3 sessions",
                        gradient: [Color(red: 0.65, green: 0.42, blue: 0.18), Color(red: 0.30, green: 0.18, blue: 0.08)],
                        icon: "person.crop.circle"
                    )
                    
                    trendingItem(
                        title: "✪ Voice of Fulton Sheen",
                        subtitle: "Pray & Reflect",
                        detail: "5 sessions",
                        gradient: [Color(red: 0.18, green: 0.38, blue: 0.65), Color(red: 0.08, green: 0.18, blue: 0.35)],
                        icon: "mic.fill"
                    )
                }
            }
        }
    }
    
    private func trendingItem(title: String, subtitle: String, detail: String, gradient: [Color], icon: String) -> some View {
        Button {
            router.present(.dailyGospelDetail(title: title, subtitle: subtitle), style: .push)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Artwork Box
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 155, height: 115)
                    
                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
                .liquidGlass(cornerRadius: 16)
                
                // Text info
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Text(detail)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.55))
                }
                .frame(width: 155, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 6. Join The Challenge Banner
    private var joinChallengeCard: some View {
        Button {
            router.present(
                .dailyGospelDetail(
                    title: "Community Rosary Challenge",
                    subtitle: "Pray together daily with over 120,000 members."
                ),
                style: .push
            )
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text("Join the Challenge")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.22, green: 0.32, blue: 0.42),
                                    Color(red: 0.12, green: 0.18, blue: 0.24)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Community Rosary Challenge")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                        
                        Text("Pray together daily with over 120,000 members.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.75))
                    }
                    .padding(18)
                }
                .liquidGlass(cornerRadius: 22)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Floating Glass AI Action Button
    private var floatingAIButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    router.present(.spiritualChat, style: .sheet)
                } label: {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.95, green: 0.82, blue: 0.45),
                                            Color(red: 0.75, green: 0.55, blue: 0.20)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.black.opacity(0.85))
                        }
                        
                        Text("Spiritual AI")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .liquidGlass(cornerRadius: 24)
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.82, blue: 0.45).opacity(0.7),
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.9
                            )
                    )
                    .shadow(color: Color(red: 0.95, green: 0.82, blue: 0.45).opacity(0.25), radius: 10, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 18)
                .padding(.bottom, 62)
            }
        }
    }
}

#Preview {
    RouterView {
        HomeView()
    }
}
