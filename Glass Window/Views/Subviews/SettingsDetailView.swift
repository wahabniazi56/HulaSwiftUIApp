//
//  SettingsDetailView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct SettingsDetailView: View {
    @EnvironmentObject private var router: Router
    
    @State private var notificationsEnabled: Bool = true
    @State private var downloadOverWifiOnly: Bool = true
    @State private var audioQualityHigh: Bool = true
    @State private var selectedVoice: String = "Jonathan Roumie"
    
    private let voices = ["Jonathan Roumie", "Fr. Mike Schmitz", "Sr. Miriam James", "Mark Wahlberg"]
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 54)
                    
                    // Subscription status card
                    subscriptionStatusCard
                    
                    // Audio & Playback section
                    audioPreferencesSection
                    
                    // Notifications section
                    notificationsSection
                    
                    // App information
                    appInfoSection
                    
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
            
            Text("Settings")
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
    
    private var subscriptionStatusCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "crown.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.40))
                .frame(width: 48, height: 48)
                .liquidGlassCircle()
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Hallow Plus Member")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                Text("All content, audio guides & music unlocked")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22)
    }
    
    private var audioPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Audio & Playback")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Default Guide Voice")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Menu {
                        ForEach(voices, id: \.self) { voice in
                            Button(voice) { selectedVoice = voice }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedVoice)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.white.opacity(0.85))
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .liquidGlassCapsule()
                    }
                }
                
                Divider().background(Color.white.opacity(0.15))
                
                Toggle("High Quality Lossless Audio", isOn: $audioQualityHigh)
                    .tint(Color.white)
                    .foregroundStyle(Color.white)
                
                Divider().background(Color.white.opacity(0.15))
                
                Toggle("Download Over Wi-Fi Only", isOn: $downloadOverWifiOnly)
                    .tint(Color.white)
                    .foregroundStyle(Color.white)
            }
            .padding(18)
            .liquidGlass(cornerRadius: 20)
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Notifications")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            VStack(spacing: 12) {
                Toggle("Daily Gospel & Streak Alerts", isOn: $notificationsEnabled)
                    .tint(Color.white)
                    .foregroundStyle(Color.white)
            }
            .padding(18)
            .liquidGlass(cornerRadius: 20)
        }
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 8) {
            Text("Liquid Glass Edition • Version 2.0.0 (2026)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
}

#Preview {
    RouterView {
        SettingsDetailView()
    }
}
