//
//  DailyScriptureDetailView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct DailyScriptureDetailView: View {
    @EnvironmentObject private var router: Router
    
    public let reference: String
    public let quote: String
    
    @State private var isBookmarked: Bool = false
    @State private var selectedThemeIndex: Int = 0
    
    private let cardGradients: [[Color]] = [
        [Color(red: 0.12, green: 0.38, blue: 0.32), Color(red: 0.05, green: 0.18, blue: 0.16)],
        [Color(red: 0.20, green: 0.30, blue: 0.55), Color(red: 0.08, green: 0.12, blue: 0.25)],
        [Color(red: 0.48, green: 0.22, blue: 0.35), Color(red: 0.20, green: 0.08, blue: 0.15)],
        [Color(red: 0.55, green: 0.40, blue: 0.15), Color(red: 0.22, green: 0.15, blue: 0.05)]
    ]
    
    public init(
        reference: String = "Philippians 4:6",
        quote: String = "Have no anxiety about anything, but in everything by prayer and supplication with thanksgiving let your requests be made known to God."
    ) {
        self.reference = reference
        self.quote = quote
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    Color.clear.frame(height: 54)
                    
                    // Shareable Quote Hero Card
                    quoteShareHeroCard
                    
                    // Theme Selector for Sharing
                    themeSelectorRow
                    
                    // Passage Context & Commentary
                    passageContextCard
                    
                    // Action Buttons (Copy, Bookmark, Audio)
                    actionButtonsRow
                    
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
            
            Text("Daily Scripture")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Spacer()
            
            Button {
                isBookmarked.toggle()
            } label: {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .semibold))
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
    
    private var quoteShareHeroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: cardGradients[selectedThemeIndex],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(spacing: 14) {
                    Text(reference.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.50))
                    
                    Text("\"\(quote)\"")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 10))
                        Text("Hallow Daily Scripture")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(Color.white.opacity(0.65))
                    .padding(.top, 8)
                }
                .padding(26)
            }
            .frame(minHeight: 250)
            .liquidGlass(cornerRadius: 24)
        }
    }
    
    private var themeSelectorRow: some View {
        HStack(spacing: 12) {
            Text("Card Style:")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.7))
            
            Spacer()
            
            ForEach(0..<cardGradients.count, id: \.self) { idx in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedThemeIndex = idx
                    }
                } label: {
                    Circle()
                        .fill(cardGradients[idx][0])
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle().strokeBorder(selectedThemeIndex == idx ? Color.white : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .liquidGlassCapsule()
    }
    
    private var passageContextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Context & Prayer Prompt")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Text("Saint Paul wrote this epistle while imprisoned in Rome, yet joy permeates every line. He reminds us that peace is not the absence of trouble, but the presence of God through constant prayer and thanksgiving.")
                .font(.system(size: 14, weight: .regular))
                .lineSpacing(5)
                .foregroundStyle(Color.white.opacity(0.85))
            
            Divider().background(Color.white.opacity(0.15))
            
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.50))
                Text("Reflection: What is one thing causing you anxiety today? Offer it up now with a prayer of thanksgiving.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.8))
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22)
    }
    
    private var actionButtonsRow: some View {
        HStack(spacing: 12) {
            Button {
                UIPasteboard.general.string = "\"\(quote)\" — \(reference)"
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy")
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .liquidGlass(cornerRadius: 16)
            }
            .buttonStyle(.plain)
            
            Button {
                // Share sheet
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .liquidGlass(cornerRadius: 16)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    RouterView {
        DailyScriptureDetailView()
    }
}
