//
//  AppIntent.swift
//  GlassWidgets
//
//  Created by mac on 25/09/2026.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}

// MARK: - Interactive Audio Playback Intents (iOS 17+)

/// Toggle audio playback (Play / Pause) directly from the widget
public struct ToggleAudioIntent: AudioPlaybackIntent {
    public static var title: LocalizedStringResource = "Toggle Prayer Audio"
    public static var description = IntentDescription("Play or pause the current prayer audio narration.")

    public init() {}

    public func perform() async throws -> some IntentResult {
        let current = SharedWidgetData.read()
        let newPlayingState = !current.isPlaying
        
        // Optimistically calculate live start time for instant visual feedback
        let newStartTime = newPlayingState ? (current.startTime ?? Date()) : current.startTime
        
        SharedWidgetData.write(
            isPlaying: newPlayingState,
            title: current.title,
            subtitle: current.subtitle,
            startTime: newStartTime
        )
        
        // Post IPC command to main audio engine (Darwin notification + App Group)
        SharedWidgetData.postAudioCommand(newPlayingState ? "play" : "pause")
        
        // Instantly reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "GlassWidgets")
        
        return .result()
    }
}

/// Skip backward 15 seconds in the prayer audio
public struct SkipBackwardAudioIntent: AudioPlaybackIntent {
    public static var title: LocalizedStringResource = "Rewind 15s"
    public static var description = IntentDescription("Rewind the current prayer audio by 15 seconds.")

    public init() {}

    public func perform() async throws -> some IntentResult {
        SharedWidgetData.postAudioCommand("skipBackward")
        WidgetCenter.shared.reloadTimelines(ofKind: "GlassWidgets")
        return .result()
    }
}

/// Skip forward 15 seconds in the prayer audio
public struct SkipForwardAudioIntent: AudioPlaybackIntent {
    public static var title: LocalizedStringResource = "Fast Forward 15s"
    public static var description = IntentDescription("Skip forward 15 seconds in the current prayer audio.")

    public init() {}

    public func perform() async throws -> some IntentResult {
        SharedWidgetData.postAudioCommand("skipForward")
        WidgetCenter.shared.reloadTimelines(ofKind: "GlassWidgets")
        return .result()
    }
}
