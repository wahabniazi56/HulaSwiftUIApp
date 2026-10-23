//
//  ReadingDetailView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct ReadingDetailView: View {
    @EnvironmentObject private var router: Router
    
    public let type: String
    public let title: String
    public let passageText: String
    
    @State private var fontSize: CGFloat = 16
    @State private var isAudioReading: Bool = false
    
    public init(
        type: String = "First Reading",
        title: String = "Haggai 1:1-8",
        passageText: String = """
        Thus says the LORD of hosts:
        These people say: "The time has not yet come to rebuild the house of the LORD."
        Then this word of the LORD came through Haggai the prophet:
        Is it time for you to dwell in your paneled houses, while this house lies in ruins?
        
        Now thus says the LORD of hosts:
        Consider your ways!
        You have sown much, but have brought in little;
        you have eaten, but have not been satisfied;
        you have drunk, but have not been exhilarated;
        have clothed yourselves, but not been warmed;
        and whoever earned wages earned them for a bag with holes in it.
        
        Thus says the LORD of hosts:
        Consider your ways!
        Go up into the hill country; bring timber, and build the house,
        that I may take pleasure in it and receive my glory, says the LORD.
        """
    ) {
        self.type = type
        self.title = title
        self.passageText = passageText
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 54)
                    
                    // Header Tag & Reading Reference
                    readingHeaderCard
                    
                    // Audio Reader Quick Bar
                    audioControlBar
                    
                    // Scripture Passage Box
                    passageTextCard
                    
                    // Liturgical Prayer Response
                    prayerResponseCard
                    
                    Color.clear.frame(height: 32)
                }
                .padding(.horizontal, 18)
            }
            
            // Navigation Bar
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
            
            Text(type)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Spacer()
            
            // Text size adjuster
            Menu {
                Button("Smaller Text") { fontSize = max(13, fontSize - 2) }
                Button("Default Text") { fontSize = 16 }
                Button("Larger Text") { fontSize = min(22, fontSize + 2) }
            } label: {
                Image(systemName: "textformat.size")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 42, height: 42)
                    .liquidGlassCircle()
            }
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
    
    private var readingHeaderCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(type.uppercased())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.50))
            
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Text("Thursday of the 25th Week in Ordinary Time")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .liquidGlass(cornerRadius: 22)
    }
    
    private var audioControlBar: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { isAudioReading.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isAudioReading ? "pause.fill" : "play.fill")
                    Text(isAudioReading ? "Pause Audio" : "Listen to Reading")
                }
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("3 min read")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlassCapsule()
    }
    
    private var passageTextCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(passageText)
                .font(.system(size: fontSize, weight: .regular, design: .serif))
                .lineSpacing(7)
                .foregroundStyle(Color.white.opacity(0.92))
            
            Divider().background(Color.white.opacity(0.15))
            
            HStack {
                Text("The Word of the Lord.")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.white.opacity(0.75))
                Spacer()
                Text("R. Thanks be to God.")
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundStyle(Color.white)
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22)
    }
    
    private var prayerResponseCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Meditation Note")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Text("The Prophet Haggai calls us to re-evaluate our priorities. Are we investing time into our interior spiritual temple, or merely worldly pursuits?")
                .font(.system(size: 13, weight: .regular))
                .lineSpacing(4)
                .foregroundStyle(Color.white.opacity(0.8))
        }
        .padding(18)
        .liquidGlass(cornerRadius: 20)
    }
}

#Preview {
    RouterView {
        ReadingDetailView()
    }
}
