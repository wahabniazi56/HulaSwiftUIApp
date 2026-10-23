//
//  ChurchFinderDetailView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct ParishModel: Identifiable {
    public let id = UUID()
    public let name: String
    public let city: String
    public let distance: String
    public let massSchedule: String
    public let confessionSchedule: String
    public let isJoined: Bool
}

public struct ChurchFinderDetailView: View {
    @EnvironmentObject private var router: Router
    
    @State private var searchText: String = ""
    @State private var joinedParishId: UUID?
    
    private let sampleParishes: [ParishModel] = [
        ParishModel(
            name: "St. Patrick's Cathedral",
            city: "New York, NY",
            distance: "1.2 miles",
            massSchedule: "Sun: 7am, 9am, 10:15am, 12pm, 5:30pm",
            confessionSchedule: "Mon-Fri: 11:30am - 12pm",
            isJoined: false
        ),
        ParishModel(
            name: "Holy Family Catholic Church",
            city: "Manhattan, NY",
            distance: "2.8 miles",
            massSchedule: "Sun: 8:30am, 11am, 6pm",
            confessionSchedule: "Sat: 4:00pm - 5:00pm",
            isJoined: true
        ),
        ParishModel(
            name: "St. Michael's Parish",
            city: "Brooklyn, NY",
            distance: "4.5 miles",
            massSchedule: "Sun: 9:00am, 11:30am",
            confessionSchedule: "Sun: 30 mins before Mass",
            isJoined: false
        )
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 54)
                    
                    // Search bar
                    searchField
                    
                    // Nearby header
                    HStack {
                        Text("Parishes Near You")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                        Spacer()
                    }
                    
                    // Parish Cards
                    ForEach(sampleParishes) { parish in
                        parishCard(parish)
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
            
            Text("Find a Church")
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
    
    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(Color.white.opacity(0.65))
            
            TextField("City, State, or Parish Name", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlassCapsule()
    }
    
    private func parishCard(_ parish: ParishModel) -> some View {
        let isCurrent = joinedParishId == parish.id || parish.isJoined
        
        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(parish.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    
                    Text("\(parish.city) • \(parish.distance)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.65))
                }
                
                Spacer()
                
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.50))
                    .frame(width: 40, height: 40)
                    .liquidGlassCircle()
            }
            
            Divider().background(Color.white.opacity(0.15))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.white.opacity(0.6))
                    Text("Mass Times:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                Text(parish.massSchedule)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.85))
                
                HStack(spacing: 6) {
                    Image(systemName: "cross.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.white.opacity(0.6))
                    Text("Confession:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                .padding(.top, 4)
                Text(parish.confessionSchedule)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.85))
            }
            
            // Join Button
            Button {
                withAnimation {
                    joinedParishId = parish.id
                }
            } label: {
                Text(isCurrent ? "Joined on Hallow" : "Join this Parish")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(isCurrent ? Color.black : Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if isCurrent {
                            Capsule().fill(Color.white)
                        } else {
                            Capsule().strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                        }
                    }
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22)
    }
}

#Preview {
    RouterView {
        ChurchFinderDetailView()
    }
}
