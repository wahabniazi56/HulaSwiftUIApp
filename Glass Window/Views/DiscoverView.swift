//
//  DiscoverView.swift
//  Glass Window
//
//  Created by mac on 24/09/2026.
//

import SwiftUI

public struct DiscoverCategoryCardItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let iconName: String
    public let gradientColors: [Color]
    public let illustrationStyle: IllustrationType
    
    public enum IllustrationType {
        case halo
        case moonTree
        case priest
        case churchNight
        case rosaryHands
        case openBookCoffee
        case reachingHands
        case microphone
        case ringingBells
        case stainedGlass
        case zenTree
        case cathedralTower
    }
}

public struct DiscoverGuideItem: Identifiable {
    public let id = UUID()
    public let name: String
    public let role: String
    public let avatarGradient: [Color]
    public let iconName: String
}

public struct DiscoverView: View {
    @EnvironmentObject private var router: Router
    @State private var searchText = ""
    
    // 12 Discover Categories directly matching the screenshot
    private let categories: [DiscoverCategoryCardItem] = [
        DiscoverCategoryCardItem(
            title: "Daily Prayers",
            iconName: "circle.circle",
            gradientColors: [Color(red: 0.15, green: 0.52, blue: 0.42), Color(red: 0.08, green: 0.28, blue: 0.22)],
            illustrationStyle: .halo
        ),
        DiscoverCategoryCardItem(
            title: "Sleep",
            iconName: "moon.stars.fill",
            gradientColors: [Color(red: 0.12, green: 0.20, blue: 0.50), Color(red: 0.06, green: 0.10, blue: 0.26)],
            illustrationStyle: .moonTree
        ),
        DiscoverCategoryCardItem(
            title: "Bible in a Year",
            iconName: "person.crop.rectangle.fill",
            gradientColors: [Color(red: 0.68, green: 0.52, blue: 0.18), Color(red: 0.35, green: 0.24, blue: 0.08)],
            illustrationStyle: .priest
        ),
        DiscoverCategoryCardItem(
            title: "Music",
            iconName: "music.note.house.fill",
            gradientColors: [Color(red: 0.38, green: 0.18, blue: 0.58), Color(red: 0.18, green: 0.08, blue: 0.30)],
            illustrationStyle: .churchNight
        ),
        DiscoverCategoryCardItem(
            title: "Rosaries",
            iconName: "hands.sparkles.fill",
            gradientColors: [Color(red: 0.18, green: 0.38, blue: 0.32), Color(red: 0.08, green: 0.18, blue: 0.15)],
            illustrationStyle: .rosaryHands
        ),
        DiscoverCategoryCardItem(
            title: "Daily Scripture",
            iconName: "book.closed.fill",
            gradientColors: [Color(red: 0.22, green: 0.48, blue: 0.58), Color(red: 0.10, green: 0.24, blue: 0.32)],
            illustrationStyle: .openBookCoffee
        ),
        DiscoverCategoryCardItem(
            title: "Plans",
            iconName: "hand.raised.fill",
            gradientColors: [Color(red: 0.65, green: 0.30, blue: 0.26), Color(red: 0.32, green: 0.12, blue: 0.10)],
            illustrationStyle: .reachingHands
        ),
        DiscoverCategoryCardItem(
            title: "Podcasts",
            iconName: "mic.fill",
            gradientColors: [Color(red: 0.15, green: 0.45, blue: 0.58), Color(red: 0.06, green: 0.20, blue: 0.30)],
            illustrationStyle: .microphone
        ),
        DiscoverCategoryCardItem(
            title: "Kids & Families",
            iconName: "bell.and.waveform.fill",
            gradientColors: [Color(red: 0.18, green: 0.58, blue: 0.68), Color(red: 0.08, green: 0.30, blue: 0.38)],
            illustrationStyle: .ringingBells
        ),
        DiscoverCategoryCardItem(
            title: "Saints Alive",
            iconName: "shield.fill",
            gradientColors: [Color(red: 0.12, green: 0.45, blue: 0.50), Color(red: 0.06, green: 0.22, blue: 0.26)],
            illustrationStyle: .stainedGlass
        ),
        DiscoverCategoryCardItem(
            title: "Meditate",
            iconName: "wind",
            gradientColors: [Color(red: 0.28, green: 0.48, blue: 0.35), Color(red: 0.12, green: 0.25, blue: 0.18)],
            illustrationStyle: .zenTree
        ),
        DiscoverCategoryCardItem(
            title: "Chant",
            iconName: "music.quarternote.3",
            gradientColors: [Color(red: 0.48, green: 0.22, blue: 0.52), Color(red: 0.24, green: 0.08, blue: 0.28)],
            illustrationStyle: .cathedralTower
        )
    ]
    
    // Featured Guides & Narrators matching bottom of screenshot
    private let guides: [DiscoverGuideItem] = [
        DiscoverGuideItem(
            name: "Jonathan Roumie",
            role: "Actor & Narrator",
            avatarGradient: [Color(red: 0.55, green: 0.42, blue: 0.28), Color(red: 0.25, green: 0.18, blue: 0.10)],
            iconName: "person.crop.circle.fill"
        ),
        DiscoverGuideItem(
            name: "Mark Wahlberg",
            role: "Guest Host",
            avatarGradient: [Color(red: 0.32, green: 0.42, blue: 0.52), Color(red: 0.15, green: 0.20, blue: 0.28)],
            iconName: "person.crop.circle.fill"
        ),
        DiscoverGuideItem(
            name: "Sr. Miriam James",
            role: "Author & Speaker",
            avatarGradient: [Color(red: 0.48, green: 0.38, blue: 0.48), Color(red: 0.22, green: 0.16, blue: 0.24)],
            iconName: "person.crop.circle.fill"
        )
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Refractive Atmospheric Background
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Safe Area Space for Sticky Header
                    Color.clear.frame(height: 54)
                    
                    // Glass Search Bar matching screenshot placeholder
                    searchBar
                    
                    // 2-Column Categories Grid (Tailored for iPhone)
                    categoriesGrid
                    
                    // Featured Guides & Narrators Section
                    guidesSection
                    
                    // Bottom Spacing
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16)
            }
            
            // Glass Sticky Header
            glassHeader
        }
    }
    
    // MARK: - Glass Top Bar
    private var glassHeader: some View {
        HStack {
            Text("Discover")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Spacer()
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
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.65))
            
            TextField("Prayers, Categories, Bible and More", text: $searchText)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .liquidGlassCapsule()
    }
    
    // MARK: - Categories Grid (2 Columns for iPhone)
    private var categoriesGrid: some View {
        let filteredCategories = categories.filter { item in
            searchText.isEmpty || item.title.localizedCaseInsensitiveContains(searchText)
        }
        
        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(filteredCategories) { item in
                categoryCard(item: item)
            }
        }
    }
    
    // MARK: - Category Card with Rich Graphic Artwork & Glass Container
    @ViewBuilder
    private func categoryCard(item: DiscoverCategoryCardItem) -> some View {
        Button {
            router.present(.categoryDetail(categoryTitle: item.title, iconName: item.iconName), style: .push)
        } label: {
            ZStack(alignment: .bottom) {
                // Artwork Box with Gradient
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: item.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Graphic Illustration Silhouette
                illustrationView(for: item.illustrationStyle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                
                // Dark Gradient Shadow at bottom for text contrast
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.65)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                // Card Title at Bottom
                Text(item.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 14)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 125)
            .liquidGlass(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Illustration Graphics
    @ViewBuilder
    private func illustrationView(for type: DiscoverCategoryCardItem.IllustrationType) -> some View {
        ZStack {
            switch type {
            case .halo:
                // Glowing Orb with Halo
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(Color.white.opacity(0.75))
                    .frame(width: 38, height: 38)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                            .frame(width: 32, height: 12)
                            .offset(y: -24)
                    }
                
            case .moonTree:
                // Night Moon & Tree Silhouette
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .offset(x: 20, y: 10)
                    
                    Image(systemName: "moon.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .offset(x: -30, y: -20)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .offset(x: -10, y: -30)
                }
                
            case .priest:
                // Priest Silhouette / Book
                ZStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .offset(y: 10)
                    
                    Image(systemName: "cross.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .offset(y: 2)
                }
                
            case .churchNight:
                // City / Church Facade
                ZStack {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(Color.white.opacity(0.65))
                        .offset(y: 5)
                    
                    Image(systemName: "umbrella.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .offset(x: -45, y: 15)
                }
                
            case .rosaryHands:
                // Rosary Beads & Hands
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "cross.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .offset(y: 26)
                    
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .offset(y: -5)
                }
                
            case .openBookCoffee:
                // Open Scripture Book & Cup
                ZStack {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .offset(x: -15, y: 5)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.white.opacity(0.8))
                        .offset(x: 35, y: -10)
                }
                
            case .reachingHands:
                // Creation of Adam Reaching Hands
                ZStack {
                    Image(systemName: "hand.point.right.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .offset(x: -25, y: -5)
                    
                    Image(systemName: "hand.point.left.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .offset(x: 25, y: 5)
                }
                
            case .microphone:
                // Retro Studio Mic
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .offset(y: -5)
                }
                
            case .ringingBells:
                // Church Bells
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill").font(.system(size: 20)).offset(y: -10)
                    Image(systemName: "bell.fill").font(.system(size: 24)).offset(y: -18)
                    Image(systemName: "bell.fill").font(.system(size: 20)).offset(y: -10)
                }
                .foregroundStyle(Color.white.opacity(0.75))
                
            case .stainedGlass:
                // Stained Glass Arch
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.4), lineWidth: 2)
                        .frame(width: 50, height: 70)
                        .offset(y: -5)
                    
                    Image(systemName: "shield.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.white.opacity(0.8))
                        .offset(y: -5)
                }
                
            case .zenTree:
                // Tree on Hill
                ZStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .offset(y: -12)
                    
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .offset(x: 15, y: 10)
                }
                
            case .cathedralTower:
                // Monastery & Tower
                ZStack {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Color.white.opacity(0.65))
                        .offset(x: -15, y: 8)
                    
                    Image(systemName: "cross.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .offset(x: 25, y: -15)
                }
            }
        }
    }
    
    // MARK: - Guides & Narrators Section
    private var guidesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Guides & Voices")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .padding(.top, 6)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(guides) { guide in
                        Button {
                            router.present(
                                .guideProfileDetail(
                                    guideName: guide.name,
                                    role: guide.role,
                                    iconName: guide.iconName
                                ),
                                style: .push
                            )
                        } label: {
                            VStack(spacing: 8) {
                                // Avatar Box
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: guide.avatarGradient,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: guide.iconName)
                                        .font(.system(size: 42))
                                        .foregroundStyle(Color.white.opacity(0.85))
                                }
                                .liquidGlass(cornerRadius: 16)
                                
                                VStack(spacing: 2) {
                                    Text(guide.name)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.white)
                                        .lineLimit(1)
                                    
                                    Text(guide.role)
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(Color.white.opacity(0.65))
                                        .lineLimit(1)
                                }
                                .frame(width: 100)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    RouterView {
        DiscoverView()
    }
}
