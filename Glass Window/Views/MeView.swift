//
//  MeView.swift
//  Glass Window
//
//  Created by mac on 24/09/2026.
//

import SwiftUI

public struct RoutineCardItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let duration: String
    public let badgeCount: String?
    public let gradientColors: [Color]
    public let illustration: RoutineIllustration
    public let hasGetStartedButton: Bool
    
    public enum RoutineIllustration {
        case calendar
        case rosary
        case nightBible
    }
}

public struct MeView: View {
    @EnvironmentObject private var router: Router
    @State private var streakCount: Int = 0
    @State private var userName: String = "Muhammad"
    
    // Routine items matching the reference screenshot
    private let routineItems: [RoutineCardItem] = [
        RoutineCardItem(
            title: "Create Your Own Routine",
            subtitle: "Personalize your daily prayer schedule",
            duration: "",
            badgeCount: nil,
            gradientColors: [Color(red: 0.22, green: 0.45, blue: 0.85), Color(red: 0.12, green: 0.28, blue: 0.58)],
            illustration: .calendar,
            hasGetStartedButton: true
        ),
        RoutineCardItem(
            title: "Daily Rosary",
            subtitle: "Pray the Rosary every day",
            duration: "18-28 min",
            badgeCount: "121.2K praying daily",
            gradientColors: [Color(red: 0.10, green: 0.32, blue: 0.35), Color(red: 0.05, green: 0.16, blue: 0.20)],
            illustration: .rosary,
            hasGetStartedButton: false
        ),
        RoutineCardItem(
            title: "Bible in a Year",
            subtitle: "Journey through scripture with Fr. Mike Schmitz",
            duration: "15-35 min",
            badgeCount: "83.5K praying daily",
            gradientColors: [Color(red: 0.12, green: 0.18, blue: 0.48), Color(red: 0.06, green: 0.09, blue: 0.28)],
            illustration: .nightBible,
            hasGetStartedButton: false
        )
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Refractive Atmospheric Background
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    // Safe Area Space for Sticky Header
                    Color.clear.frame(height: 54)
                    
                    // 1. Streak Section
                    streakSection
                    
                    // 2. Create a Routine Carousel Section
                    createRoutineSection
                    
                    // 3. Favorites Section
                    favoritesSection
                    
                    // 4. Downloads Section
                    downloadsSection
                    
                    // Bottom Spacing for Tab Bar
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16)
            }
            
            // Glass Sticky Header (Profile Avatar, Name & Actions)
            glassHeader
        }
    }
    
    // MARK: - Glass Top Bar
    private var glassHeader: some View {
        HStack(spacing: 10) {
            // Profile Avatar with Glowing Ring
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color(red: 0.95, green: 0.45, blue: 0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 14, height: 14)
            }
            .overlay(Circle().strokeBorder(Color.white.opacity(0.35), lineWidth: 1))
            
            Text(userName)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Spacer()
            
            // Community Icon Button
            Button {
                // Community action
            } label: {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
            
            // Settings Gear Button
            Button {
                router.present(.settings, style: .push)
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
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
    
    // MARK: - 1. Streak Section
    private var streakSection: some View {
        Button {
            router.present(.routineDetail(routineTitle: "14-Day Streak", duration: "Milestones"), style: .push)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // Header with Chevron
                HStack(spacing: 4) {
                    Text("Streak")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                
                // Streak Glass Card
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Text("\(streakCount)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                    }
                    
                    Text("Pray today and start building a habit!")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .liquidGlass(cornerRadius: 18)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 2. Create a Routine Section
    private var createRoutineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Create a Routine")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            // Horizontal Carousel of Routine Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(routineItems) { item in
                        Button {
                            router.present(
                                .routineDetail(
                                    routineTitle: item.title,
                                    duration: item.duration.isEmpty ? "15 min" : item.duration
                                ),
                                style: .push
                            )
                        } label: {
                            routineCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Routine Card
    @ViewBuilder
    private func routineCard(item: RoutineCardItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Card Gradient Artwork Box
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: item.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Graphic Illustration
            illustrationForRoutine(item.illustration)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            // Badge in Top-Left (if present)
            if let badge = item.badgeCount {
                VStack {
                    HStack {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.35), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(14)
            }
            
            // Bottom Content
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                
                if !item.subtitle.isEmpty && !item.hasGetStartedButton {
                    Text(item.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .lineLimit(1)
                }
                
                if !item.duration.isEmpty {
                    Text(item.duration)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.85))
                }
                
                // Get Started Pill Button (for Card 1)
                if item.hasGetStartedButton {
                    Text("Get Started")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.white, in: Capsule())
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                        .padding(.top, 4)
                }
            }
            .padding(18)
        }
        .frame(width: 200, height: 260)
        .liquidGlass(cornerRadius: 22)
    }
    
    // MARK: - Routine Card Illustrations
    @ViewBuilder
    private func illustrationForRoutine(_ type: RoutineCardItem.RoutineIllustration) -> some View {
        ZStack {
            switch type {
            case .calendar:
                // Calendar Sheet with checkmarks
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.92))
                        .frame(width: 120, height: 110)
                        .rotationEffect(.degrees(4))
                        .offset(y: -40)
                        .overlay(
                            VStack(spacing: 6) {
                                Rectangle().fill(Color(red: 0.15, green: 0.55, blue: 0.45)).frame(height: 18)
                                Grid(horizontalSpacing: 8, verticalSpacing: 6) {
                                    GridRow {
                                        Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.45))
                                        Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.45))
                                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                                    }
                                    GridRow {
                                        Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.45))
                                        Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.45))
                                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                                    }
                                }
                            }
                            .padding(8)
                            .rotationEffect(.degrees(4))
                            .offset(y: -40)
                        )
                }
                
            case .rosary:
                // Hands holding rosary
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        .frame(width: 80, height: 80)
                        .offset(y: -20)
                    
                    Image(systemName: "cross.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color(red: 0.45, green: 0.85, blue: 0.75))
                        .offset(y: 10)
                    
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .offset(y: -35)
                }
                
            case .nightBible:
                // Moon, stars and open book
                ZStack {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .offset(x: 35, y: -55)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .offset(x: -25, y: -65)
                    
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .offset(y: -20)
                }
            }
        }
    }
    
    // MARK: - 3. Favorites Section
    private var favoritesSection: some View {
        Button {
            router.present(.categoryDetail(categoryTitle: "Favorites", iconName: "star.fill"), style: .push)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // Header with Chevron
                HStack(spacing: 4) {
                    Text("Favorites")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                
                // Favorites Empty State / Placeholder Card
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 120)
                    
                    Image(systemName: "star")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.35))
                }
                .liquidGlass(cornerRadius: 18)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 4. Downloads Section
    private var downloadsSection: some View {
        Button {
            router.present(.categoryDetail(categoryTitle: "Downloads", iconName: "arrow.down.circle.fill"), style: .push)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // Header with Chevron
                HStack(spacing: 4) {
                    Text("Downloads")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                
                // Downloads Empty State / Placeholder Card
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 90)
                    
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 26, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.35))
                }
                .liquidGlass(cornerRadius: 18)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RouterView {
        MeView()
    }
}

