//
//  RoutineDetailView.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI

public struct RoutineStep: Identifiable {
    public let id = UUID()
    public var title: String
    public var duration: String
    public var icon: String
    public var isCompleted: Bool
}

public struct RoutineDetailView: View {
    @EnvironmentObject private var router: Router
    
    public let routineTitle: String
    public let duration: String
    
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date()
    @State private var reminderEnabled: Bool = true
    
    @State private var steps: [RoutineStep] = [
        RoutineStep(title: "1. Morning Offering & Consecration", duration: "3 mins", icon: "sun.max.fill", isCompleted: true),
        RoutineStep(title: "2. Daily Gospel & Reflection", duration: "8 mins", icon: "book.closed.fill", isCompleted: false),
        RoutineStep(title: "3. Sacred Silence & Thanksgiving", duration: "4 mins", icon: "heart.fill", isCompleted: false)
    ]
    
    public init(
        routineTitle: String = "Daily Routine",
        duration: String = "15 mins"
    ) {
        self.routineTitle = routineTitle
        self.duration = duration
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            LiquidAtmosphereBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 54)
                    
                    // Routine Hero
                    routineHeroCard
                    
                    // Reminder Time Setting
                    reminderTimeCard
                    
                    // Routine Steps Checklist
                    routineStepsSection
                    
                    // Start Button
                    startRoutineButton
                    
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
            
            Text("Routine Details")
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
    
    private var routineHeroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(routineTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Text(duration)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .liquidGlassCapsule()
            }
            
            Text("Stay consistent in prayer with structured daily milestones tailored for your morning.")
                .font(.system(size: 13, weight: .regular))
                .lineSpacing(4)
                .foregroundStyle(Color.white.opacity(0.75))
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22)
    }
    
    private var reminderTimeCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.orange)
                
                Text("Daily Notification Reminder")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Toggle("", isOn: $reminderEnabled)
                    .labelsHidden()
            }
            
            if reminderEnabled {
                Divider().background(Color.white.opacity(0.15))
                
                DatePicker(
                    "Reminder Time",
                    selection: $reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .tint(Color.orange)
                .foregroundStyle(Color.white)
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 20)
    }
    
    private var routineStepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Routine Steps")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
            
            VStack(spacing: 10) {
                ForEach(steps.indices, id: \.self) { idx in
                    HStack(spacing: 12) {
                        Button {
                            withAnimation {
                                steps[idx].isCompleted.toggle()
                            }
                        } label: {
                            Image(systemName: steps[idx].isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundStyle(steps[idx].isCompleted ? Color.green : Color.white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(steps[idx].title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.white)
                            Text(steps[idx].duration)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                        
                        Spacer()
                    }
                    .padding(14)
                    .liquidGlass(cornerRadius: 16)
                }
            }
        }
    }
    
    private var startRoutineButton: some View {
        Button {
            // Start routine action
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text("Start Today's Routine")
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Color.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white, in: Capsule())
            .shadow(color: Color.white.opacity(0.25), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
    }
}

#Preview {
    RouterView {
        RoutineDetailView()
    }
}
