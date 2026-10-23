//
//  GlassWidgetsLiveActivity.swift
//  GlassWidgets
//
//  Created by mac on 25/09/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes (Shared Data Model)
public struct GlassWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var isPlaying: Bool
        public var title: String
        public var subtitle: String
        public var startTime: Date // Reference for real-time second-by-second live timer
        public var totalDuration: TimeInterval
        
        public init(
            isPlaying: Bool = true,
            title: String = "Daily Gospel Narration",
            subtitle: String = "Narrated by Jonathan Roumie",
            startTime: Date = Date(),
            totalDuration: TimeInterval = 600
        ) {
            self.isPlaying = isPlaying
            self.title = title
            self.subtitle = subtitle
            self.startTime = startTime
            self.totalDuration = totalDuration
        }
    }

    public var routineName: String
    
    public init(routineName: String = "Daily Gospel") {
        self.routineName = routineName
    }
}

// MARK: - Live Activity Widget
struct GlassWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GlassWidgetsAttributes.self) { context in
            // Lock Screen / Notification Banner View
            HStack(spacing: 14) {
                // Audio Artwork Orb
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.20, green: 0.35, blue: 0.45),
                                    Color(red: 0.10, green: 0.18, blue: 0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: context.state.isPlaying ? "waveform" : "pause.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                }
                
                // Track Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(context.attributes.routineName.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.6))
                        .tracking(0.8)
                    
                    Text(context.state.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                    
                    Text(context.state.subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Real-Time Second-by-Second Live Timer
                VStack(alignment: .trailing, spacing: 3) {
                    if context.state.isPlaying {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.green)
                        }
                        
                        Text(context.state.startTime, style: .timer)
                            .font(.system(size: 17, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                    } else {
                        Text("PAUSED")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.orange)
                    }
                }
            }
            .padding(16)
            .activityBackgroundTint(Color(red: 0.08, green: 0.12, blue: 0.16).opacity(0.92))
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                        
                        Text(context.attributes.routineName)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                    }
                    .padding(.leading, 4)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    // Real-Time Second-by-Second Live Timer
                    if context.state.isPlaying {
                        Text(context.state.startTime, style: .timer)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                            .padding(.trailing, 4)
                    } else {
                        Text("Paused")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.orange)
                            .padding(.trailing, 4)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(context.state.title)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white)
                            .lineLimit(1)
                        
                        Text(context.state.subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                }
            } compactLeading: {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
            } compactTrailing: {
                // Compact real-time second-by-second live timer
                if context.state.isPlaying {
                    Text(context.state.startTime, style: .timer)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                        .frame(width: 44, alignment: .trailing)
                } else {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.orange)
                }
            } minimal: {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
            }
            .keylineTint(Color(red: 0.95, green: 0.82, blue: 0.45))
        }
    }
}
