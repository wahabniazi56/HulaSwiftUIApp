//
//  LiveActivityManager.swift
//  Glass Window
//
//  Created by mac on 19/10/2026.
//

import Foundation
import ActivityKit
import WidgetKit

// MARK: - Activity Attributes (Shared model matching GlassWidgetsLiveActivity)
public struct GlassWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var isPlaying: Bool
        public var title: String
        public var subtitle: String
        public var startTime: Date
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

// MARK: - Shared App Group Data Access
public struct SharedWidgetData {
    public static let appGroupID = "group.com.test.Glass-Window"
    private static var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }
    
    public static func read() -> (isPlaying: Bool, title: String, subtitle: String, startTime: Date?) {
        let isPlaying = userDefaults.bool(forKey: "isAudioPlaying")
        let title = userDefaults.string(forKey: "playingTrackTitle") ?? "Daily Gospel Narration"
        let subtitle = userDefaults.string(forKey: "playingTrackSubtitle") ?? "Narrated by Jonathan Roumie"
        let timestamp = userDefaults.double(forKey: "playbackStartTime")
        let startTime = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        return (isPlaying, title, subtitle, startTime)
    }
    
    public static func write(isPlaying: Bool, title: String, subtitle: String, startTime: Date?) {
        let defaults = userDefaults
        defaults.set(isPlaying, forKey: "isAudioPlaying")
        defaults.set(title, forKey: "playingTrackTitle")
        defaults.set(subtitle, forKey: "playingTrackSubtitle")
        defaults.set(startTime?.timeIntervalSince1970 ?? 0, forKey: "playbackStartTime")
        defaults.synchronize()
    }
}

// MARK: - Live Activity & Widget Coordinator
public final class LiveActivityManager {
    public static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<GlassWidgetsAttributes>?
    private var playbackStartTime: Date?
    
    private init() {}
    
    /// Starts a real-time Live Activity, Dynamic Island session, and updates Home Screen Widget
    public func startActivity(title: String, subtitle: String, duration: TimeInterval) {
        let startTime = Date()
        self.playbackStartTime = startTime
        
        // 1. Update Shared App Group & Reload Home Screen Widget
        SharedWidgetData.write(isPlaying: true, title: title, subtitle: subtitle, startTime: startTime)
        WidgetCenter.shared.reloadTimelines(ofKind: "GlassWidgets")
        
        // 2. Start / Update Live Activity & Dynamic Island
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("LiveActivityManager: Live Activities are disabled by the user or system.")
            return
        }
        
        if let activity = currentActivity {
            updateActivity(isPlaying: true, title: title, subtitle: subtitle)
            return
        }
        
        let attributes = GlassWidgetsAttributes(routineName: "Daily Prayer")
        let contentState = GlassWidgetsAttributes.ContentState(
            isPlaying: true,
            title: title,
            subtitle: subtitle,
            startTime: startTime,
            totalDuration: duration
        )
        
        do {
            if #available(iOS 16.2, *) {
                currentActivity = try Activity.request(
                    attributes: attributes,
                    content: .init(state: contentState, staleDate: nil)
                )
            } else {
                currentActivity = try Activity.request(
                    attributes: attributes,
                    contentState: contentState
                )
            }
            print("LiveActivityManager: Started Live Activity successfully.")
        } catch {
            print("LiveActivityManager: Failed to start Live Activity: \(error.localizedDescription)")
        }
    }
    
    /// Updates the Live Activity and Home Screen Widget (e.g. when paused or resumed)
    public func updateActivity(isPlaying: Bool, title: String? = nil, subtitle: String? = nil) {
        // 1. Sync with Shared App Group & Reload Home Screen Widget
        let sharedState = SharedWidgetData.read()
        let resolvedTitle = title ?? sharedState.title
        let resolvedSubtitle = subtitle ?? sharedState.subtitle
        SharedWidgetData.write(isPlaying: isPlaying, title: resolvedTitle, subtitle: resolvedSubtitle, startTime: playbackStartTime)
        WidgetCenter.shared.reloadTimelines(ofKind: "GlassWidgets")
        
        // 2. Update Live Activity & Dynamic Island
        guard let activity = currentActivity else { return }
        let currentState = activity.content.state
        let updatedState = GlassWidgetsAttributes.ContentState(
            isPlaying: isPlaying,
            title: resolvedTitle,
            subtitle: resolvedSubtitle,
            startTime: playbackStartTime ?? Date(),
            totalDuration: currentState.totalDuration
        )
        
        Task {
            if #available(iOS 16.2, *) {
                await activity.update(.init(state: updatedState, staleDate: nil))
            } else {
                await activity.update(using: updatedState)
            }
        }
    }
    
    /// Ends and removes the Live Activity, restoring Home Screen Widget to idle state
    public func endActivity() {
        // 1. Sync with Shared App Group & Reload Home Screen Widget
        let sharedState = SharedWidgetData.read()
        SharedWidgetData.write(isPlaying: false, title: sharedState.title, subtitle: sharedState.subtitle, startTime: nil)
        WidgetCenter.shared.reloadTimelines(ofKind: "GlassWidgets")
        
        // 2. Dismiss Live Activity & Dynamic Island
        guard let activity = currentActivity else { return }
        let currentState = activity.content.state
        let finalState = GlassWidgetsAttributes.ContentState(
            isPlaying: false,
            title: currentState.title,
            subtitle: currentState.subtitle,
            startTime: playbackStartTime ?? Date(),
            totalDuration: currentState.totalDuration
        )
        
        Task {
            if #available(iOS 16.2, *) {
                await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            } else {
                await activity.end(using: finalState, dismissalPolicy: .immediate)
            }
        }
        self.currentActivity = nil
        self.playbackStartTime = nil
    }
}
