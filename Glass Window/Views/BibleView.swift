//
//  BibleView.swift
//  Glass Window
//
//  Created by mac on 24/09/2026.
//

import SwiftUI

public struct BibleView: View {
    @EnvironmentObject private var router: Router
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 54)
                    
                    // Audio Bible Featured Card
                    Button {
                        router.present(
                            .dailyGospelDetail(
                                title: "Gospel of Luke: Chapter 9",
                                subtitle: "Audio Bible • 14 mins"
                            ),
                            style: .push
                        )
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Gospel of Luke: Chapter 9")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.white)
                                Text("Audio Bible • 14 mins")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(Color.white.opacity(0.7))
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .liquidGlass(cornerRadius: 22)
                    }
                    .buttonStyle(.plain)
                    
                    // Today's Mass Readings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Mass Readings")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                        
                        readingRow(
                            type: "First Reading",
                            title: "Haggai 1:1-8",
                            passage: "Thus says the LORD of hosts: These people say: 'The time has not yet come to rebuild the house of the LORD.' Then this word of the LORD came through Haggai the prophet: Is it time for you to dwell in your paneled houses, while this house lies in ruins?"
                        )
                        readingRow(
                            type: "Responsorial Psalm",
                            title: "Psalm 149:1-6a, 9b",
                            passage: "Sing to the LORD a new song of praise in the assembly of the faithful. Let Israel be glad in their maker, let the children of Zion rejoice in their king."
                        )
                        readingRow(
                            type: "The Holy Gospel",
                            title: "Luke 9:7-9",
                            passage: "Herod the tetrarch heard about all that was happening, and he was greatly perplexed because some were saying, 'John has been raised from the dead'; others were saying, 'Elijah has appeared'; still others, 'One of the ancient prophets has arisen.'"
                        )
                    }
                    
                    // Books of Sacred Scripture
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Books of Scripture")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            bookCard(name: "Genesis", count: 50)
                            bookCard(name: "Psalms", count: 150)
                            bookCard(name: "Matthew", count: 28)
                            bookCard(name: "Luke", count: 24)
                        }
                    }
                    
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 18)
            }
            
            // Header
            HStack {
                Text("Bible")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                Spacer()
                Text("NABRE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .liquidGlassCapsule()
            }
            .padding(.horizontal, 20)
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
    }
    
    private func readingRow(type: String, title: String, passage: String) -> some View {
        Button {
            router.present(.readingDetail(type: type, title: title, passageText: passage), style: .push)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .frame(width: 36, height: 36)
                    .liquidGlassCircle()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.6))
                        .textCase(.uppercase)
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .padding(14)
            .liquidGlass(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
    
    private func bookCard(name: String, count: Int) -> some View {
        Button {
            router.present(.bibleBookDetail(bookName: name, chaptersCount: count), style: .push)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                Text("\(count) ch")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RouterView {
        BibleView()
    }
}
