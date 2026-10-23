//
//  ChurchView.swift
//  Glass Window
//
//  Created by mac on 24/09/2026.
//

import SwiftUI

public struct ChurchReflectionItem: Identifiable {
    public let id = UUID()
    public let author: String
    public let quote: String
}

public struct ChurchView: View {
    @EnvironmentObject private var router: Router
    @State private var searchChurchText: String = ""
    @State private var activeReflectionIndex: Int = 0
    
    // Testimonial quotes from screenshots 1 & 2
    private let reflections: [ChurchReflectionItem] = [
        ChurchReflectionItem(
            author: "St. Michael's Catholic Church",
            quote: "It is a beautiful thing to see our parish praying for each other. Can't wait to launch our next prayer challenge!"
        ),
        ChurchReflectionItem(
            author: "Deb",
            quote: "Thank you for bringing peace, joy, and the Father into my life each day."
        ),
        ChurchReflectionItem(
            author: "Father Thomas • Holy Family Parish",
            quote: "Our community has grown so much deeper in communion through daily scripture and shared intentions."
        )
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Atmospheric Background
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Safe Area Space for Sticky Header
//                    Color.clear.frame(height: 54)
                    
                    // 1. Hero Church Artwork & Search Section
                    heroChurchSection
                        .padding(.top, -70)
                        .ignoresSafeArea(.all)
                    
                    // 2. Parish Community Testimonial / Reflection Quotes
                    parishReflectionSection
                    
                    // 3. "Need help finding a church?" Glass Card
                    needHelpFindingChurchCard
                    
                    // 4. Scripture Footer (Matthew 18:20)
                    scriptureFooterSection
                    
                    // Bottom Spacing for Tab Bar
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16)
            }
            
            // Glass Sticky Header ("Pray Together")
//            glassHeader
        }
    }
    
    // MARK: - Glass Top Bar
    private var glassHeader: some View {
        HStack {
            // Menu Button (matching screenshot top-left)
            Button {
                // Menu action
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .liquidGlassCircle()
            }
            .buttonStyle(.plain)
            
            Text("Pray Together")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            Spacer()
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
    
    // MARK: - 1. Hero Church Artwork & Search Section
    private var heroChurchSection: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .top) {
                // Architectural Church Illustration Backdrop
                ZStack(alignment: .bottom) {
                    // Sky & Scene Gradient
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.32, blue: 0.65),
                            Color(red: 0.42, green: 0.22, blue: 0.48),
                            Color(red: 0.18, green: 0.10, blue: 0.25)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Buildings Perspective and Church Steeple Silhouette
                    HStack(alignment: .bottom, spacing: 0) {
                        // Left Building
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.52, green: 0.28, blue: 0.32), Color(red: 0.28, green: 0.12, blue: 0.18)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 65, height: 260)
                            .overlay(
                                VStack(spacing: 14) {
                                    ForEach(0..<4) { _ in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 24, height: 38)
                                    }
                                }
                                .padding(.top, 10)
                            )
                        
                        Spacer()
                        
                        // Center Church Steeple with Cross
                        VStack(spacing: 0) {
                            Image(systemName: "cross.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color(red: 0.95, green: 0.78, blue: 0.42))
                            
                            // Steeple Spire
                            Path { path in
                                path.move(to: CGPoint(x: 20, y: 0))
                                path.addLine(to: CGPoint(x: 40, y: 80))
                                path.addLine(to: CGPoint(x: 0, y: 80))
                                path.closeSubpath()
                            }
                            .fill(Color(red: 0.38, green: 0.25, blue: 0.38))
                            .frame(width: 40, height: 80)
                            
                            // Church Belfry Tower
                            Rectangle()
                                .fill(Color(red: 0.92, green: 0.88, blue: 0.82))
                                .frame(width: 58, height: 45)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.22, green: 0.15, blue: 0.25))
                                        .frame(width: 22, height: 32)
                                )
                        }
                        
                        Spacer()
                        
                        // Right Building
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.48, green: 0.25, blue: 0.30), Color(red: 0.22, green: 0.10, blue: 0.15)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 65, height: 260)
                            .overlay(
                                VStack(spacing: 14) {
                                    ForEach(0..<4) { _ in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 24, height: 38)
                                    }
                                }
                                .padding(.top, 10)
                            )
                    }
                    .frame(height: 260)
                    
                    // Autumn Tree Canopy Layer
                    HStack(spacing: -20) {
                        Circle()
                            .fill(Color(red: 0.65, green: 0.38, blue: 0.48).opacity(0.85))
                            .frame(width: 140, height: 140)
                        Circle()
                            .fill(Color(red: 0.72, green: 0.42, blue: 0.52).opacity(0.85))
                            .frame(width: 160, height: 160)
                        Circle()
                            .fill(Color(red: 0.65, green: 0.38, blue: 0.48).opacity(0.85))
                            .frame(width: 140, height: 140)
                    }
                    .offset(y: 35)
                }
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
                
                VStack{
                    HStack {
                        // Menu Button (matching screenshot top-left)
                        Button {
                            // Menu action
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.white)
                                .frame(width: 40, height: 40)
                                .liquidGlassCircle()
                        }
                        .buttonStyle(.plain)
                        
                        Text("Pray Together")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 55)
                    .padding(.bottom, 15)
                    
                    // Get Started & Title Header
                    VStack(spacing: 8) {
                        Text("Get started")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.85))
                        
                        Text("Join your church\non Hallow")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .lineSpacing(2.5)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.white)
                            .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
                    }
//                    .padding(.top, 28)
                    
                    Spacer()
                    
                    // "Find your church" Search Bar
                    Button {
                        router.present(.churchFinder, style: .push)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.7))
                            
                            Text(searchChurchText.isEmpty ? "Find your church" : searchChurchText)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(Color.white.opacity(searchChurchText.isEmpty ? 0.7 : 1))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .liquidGlassCapsule()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 30)
                    }
                    .buttonStyle(.plain)
                }
            }
            .liquidGlass(cornerRadius: 0)
            
            
        }
    }
    
    // MARK: - 2. Parish Community Testimonials (Screenshots 1 & 2)
    private var parishReflectionSection: some View {
        VStack(spacing: 12) {
            TabView(selection: $activeReflectionIndex) {
                ForEach(Array(reflections.enumerated()), id: \.offset) { idx, item in
                    VStack(spacing: 10) {
                        Text(item.author)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.65))
                        
                        Text("\"\(item.quote)\"")
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 8)
                    }
                    .padding(20)
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 160)
        }
    }
    
    // MARK: - 3. "Need help finding a church?" Card
    private var needHelpFindingChurchCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Need help finding a church?")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Text("We'd love to help introduce you to a Hallow Partner Church in your area.")
                    .font(.system(size: 13, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white.opacity(0.75))
                    .padding(.horizontal, 10)
            }
            
            // "Find a Church" Glass Pill Button
            Button {
                router.present(.churchFinder, style: .push)
            } label: {
                Text("Find a Church")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .liquidGlassCapsule()
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .liquidGlass(cornerRadius: 22)
    }
    
    // MARK: - 4. Scripture Footer (Matthew 18:20)
    private var scriptureFooterSection: some View {
        VStack(spacing: 6) {
            Text("Matthew 18:20")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(Color.white.opacity(0.6))
            
            Text("\"For where two or three are gathered in my name, I am there among them.\"")
                .font(.system(size: 15, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .foregroundStyle(Color.white.opacity(0.85))
                .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    RouterView {
        ChurchView()
    }
}
