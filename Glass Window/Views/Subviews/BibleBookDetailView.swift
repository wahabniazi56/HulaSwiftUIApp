//
//  BibleBookDetailView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct BibleBookDetailView: View {
    @EnvironmentObject private var router: Router
    
    public let bookName: String
    public let chaptersCount: Int
    
    @State private var selectedChapter: Int? = 1
    @State private var searchChapterText: String = ""
    
    public init(bookName: String = "Genesis", chaptersCount: Int = 50) {
        self.bookName = bookName
        self.chaptersCount = chaptersCount
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 54)
                    
                    // Book Info Hero Card
                    bookHeroCard
                    
                    // Chapter Grid
                    chapterGridSection
                    
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
            
            Text(bookName)
                .font(.system(size: 18, weight: .bold, design: .rounded))
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
    
    private var bookHeroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(bookName.uppercased())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Text("\(chaptersCount) Chapters")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .liquidGlassCapsule()
            }
            
            Text("The first book of the Holy Bible recounting the creation of the world, early human history, and the patriarchs of Israel.")
                .font(.system(size: 13, weight: .regular))
                .lineSpacing(4)
                .foregroundStyle(Color.white.opacity(0.75))
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22)
    }
    
    private var chapterGridSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Select Chapter")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                ForEach(1...chaptersCount, id: \.self) { chapter in
                    let isSelected = selectedChapter == chapter
                    
                    Button {
                        selectedChapter = chapter
                    } label: {
                        Text("\(chapter)")
                            .font(.system(size: 15, weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundStyle(isSelected ? Color.black : Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white)
                                } else {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white.opacity(0.08))
                                }
                            }
                            .liquidGlass(cornerRadius: 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22)
    }
}

#Preview {
    RouterView {
        BibleBookDetailView()
    }
}
