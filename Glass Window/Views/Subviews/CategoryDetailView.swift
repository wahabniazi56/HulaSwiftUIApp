//
//  CategoryDetailView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct CategoryDetailView: View {
    @EnvironmentObject private var router: Router
    
    public let categoryTitle: String
    public let iconName: String
    
    @State private var selectedFilter: String = "All"
    private let filterOptions = ["All", "Popular", "Short (< 10m)", "Series"]
    
    public init(categoryTitle: String = "Daily Prayers", iconName: String = "circle.circle") {
        self.categoryTitle = categoryTitle
        self.iconName = iconName
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 54)
                    
                    // Category Hero Banner
                    categoryHeroBanner
                    
                    // Filter Chips
                    filterChipsRow
                    
                    // Session list
                    sessionsListSection
                    
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
            
            Text(categoryTitle)
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
    
    private var categoryHeroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.18, green: 0.45, blue: 0.40), Color(red: 0.08, green: 0.20, blue: 0.20)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)
            
            HStack {
                Spacer()
                Image(systemName: iconName)
                    .font(.system(size: 72))
                    .foregroundStyle(Color.white.opacity(0.15))
                    .offset(x: 20, y: -10)
            }
            .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(categoryTitle)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Text("Explore guided audio sessions, meditations, and traditional prayers.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .lineLimit(2)
            }
            .padding(20)
        }
        .liquidGlass(cornerRadius: 24)
    }
    
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filterOptions, id: \.self) { filter in
                    let isSelected = selectedFilter == filter
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter)
                            .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundStyle(isSelected ? Color.black : Color.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background {
                                if isSelected {
                                    Capsule().fill(Color.white)
                                } else {
                                    Capsule().fill(Color.white.opacity(0.1))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var sessionsListSection: some View {
        VStack(spacing: 12) {
            sessionCard(title: "Morning Offering & Praise", duration: "6 mins", guide: "Jonathan Roumie", icon: "sun.max.fill")
            sessionCard(title: "The Angelus", duration: "4 mins", guide: "Sr. Miriam James", icon: "bell.fill")
            sessionCard(title: "Divine Mercy Chaplet", duration: "12 mins", guide: "Fr. Mike Schmitz", icon: "cross.fill")
            sessionCard(title: "Daily Examen for Peace", duration: "9 mins", guide: "Mark Wahlberg", icon: "moon.fill")
            sessionCard(title: "Prayer to St. Michael", duration: "3 mins", guide: "Bishop Barron", icon: "shield.fill")
        }
    }
    
    private func sessionCard(title: String, duration: String, guide: String, icon: String) -> some View {
        Button {
            router.present(.dailyGospelDetail(title: title, subtitle: "\(guide) • \(duration)"), style: .push)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    
                    HStack(spacing: 6) {
                        Text(guide)
                        Text("•")
                        Text(duration)
                    }
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.65))
                }
                
                Spacer()
                
                Image(systemName: "play.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 34, height: 34)
                    .liquidGlassCircle()
            }
            .padding(14)
            .liquidGlass(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RouterView {
        CategoryDetailView()
    }
}
