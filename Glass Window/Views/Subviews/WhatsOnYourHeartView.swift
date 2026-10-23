//
//  WhatsOnYourHeartView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct FeelingItem: Identifiable {
    public let id = UUID()
    public let name: String
    public let emoji: String
    public let prompt: String
    public let color: Color
}

public struct WhatsOnYourHeartView: View {
    @EnvironmentObject private var router: Router
    
    private let feelings: [FeelingItem] = [
        FeelingItem(name: "Peace", emoji: "🕊️", prompt: "Rest in God's comforting presence", color: Color(red: 0.18, green: 0.52, blue: 0.45)),
        FeelingItem(name: "Anxiety", emoji: "🌧️", prompt: "Surrender your worries and find calm", color: Color(red: 0.25, green: 0.35, blue: 0.65)),
        FeelingItem(name: "Gratitude", emoji: "☀️", prompt: "Count your blessings with thanksgiving", color: Color(red: 0.68, green: 0.48, blue: 0.18)),
        FeelingItem(name: "Grief", emoji: "💔", prompt: "Find hope and consolation in mourning", color: Color(red: 0.45, green: 0.22, blue: 0.48)),
        FeelingItem(name: "Hope", emoji: "🌱", prompt: "Renew your strength for tomorrow", color: Color(red: 0.22, green: 0.58, blue: 0.38)),
        FeelingItem(name: "Strength", emoji: "🛡️", prompt: "Equip your spirit with courage", color: Color(red: 0.62, green: 0.28, blue: 0.25))
    ]
    
    @State private var selectedFeeling: FeelingItem?
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {
                    Color.clear.frame(height: 54)
                    
                    // Header Introduction Card
                    VStack(spacing: 8) {
                        Text("How is your soul today?")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                        
                        Text("Select what you're experiencing, and we'll recommend curated prayers and scriptures.")
                            .font(.system(size: 14, weight: .regular))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.white.opacity(0.7))
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 10)
                    
                    // Mood Grid
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(feelings) { item in
                            feelingCard(item: item)
                        }
                    }
                    
                    // Recommended Prayers for Selected Feeling
                    if let selected = selectedFeeling {
                        recommendedSection(for: selected)
                    } else {
                        // Default general encouragement card
                        defaultEncouragementCard
                    }
                    
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
            
            Text("What's On Your Heart")
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
    
    private func feelingCard(item: FeelingItem) -> some View {
        let isSelected = selectedFeeling?.name == item.name
        
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedFeeling = item
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(item.emoji)
                        .font(.system(size: 28))
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    
                    Text(item.prompt)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(item.color.opacity(0.45))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.5)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                }
            }
            .liquidGlass(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }
    
    private func recommendedSection(for feeling: FeelingItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Prayers for \(feeling.name)")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                Spacer()
            }
            
            prayerTrackRow(title: "Surrender Novena: Day 1", subtitle: "O Jesus, I surrender myself to you • 5 min", icon: "sparkles")
            prayerTrackRow(title: "Psalm 23: The Lord is My Shepherd", subtitle: "Guided Meditative Chant • 8 min", icon: "music.note")
            prayerTrackRow(title: "Evening Examen on \(feeling.name)", subtitle: "Reflect on God's grace • 10 min", icon: "moon.fill")
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22)
    }
    
    private var defaultEncouragementCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.50))
            
            Text("Cast all your anxiety on him, because he cares for you.")
                .font(.system(size: 14, weight: .medium, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white.opacity(0.85))
            
            Text("1 Peter 5:7")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.55))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 20)
    }
    
    private func prayerTrackRow(title: String, subtitle: String, icon: String) -> some View {
        Button {
            router.present(.dailyGospelDetail(title: title, subtitle: subtitle), style: .push)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white)
                    .frame(width: 38, height: 38)
                    .liquidGlassCircle()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.65))
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            .padding(12)
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RouterView {
        WhatsOnYourHeartView()
    }
}
