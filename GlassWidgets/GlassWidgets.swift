//
//  GlassWidgets.swift
//  GlassWidgets
//
//  Created by mac on 25/09/2026.
//

import WidgetKit
import SwiftUI

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

// MARK: - Widget Timeline Provider
struct PrayerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerWidgetEntry {
        PrayerWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerWidgetEntry) -> Void) {
        let shared = SharedWidgetData.read()
        let entry = PrayerWidgetEntry(
            date: Date(),
            isAudioPlaying: shared.isPlaying,
            playbackStartTime: shared.startTime,
            playingTrackTitle: shared.title,
            playingTrackSubtitle: shared.subtitle
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerWidgetEntry>) -> Void) {
        let shared = SharedWidgetData.read()
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Truncate to the start of the current minute (:00 seconds)
        // so each timeline entry activates exactly at the turn of the minute.
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
        let startOfCurrentMinute = calendar.date(from: components) ?? currentDate
        
        var entries: [PrayerWidgetEntry] = []
        
        // Generate entries for the next 60 minutes (1 entry per minute).
        // WidgetKit switches to the next entry at the start of each minute,
        // allowing Text(entry.date, style: .time) to update continuously and accurately.
        for minuteOffset in 0..<60 {
            guard let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: startOfCurrentMinute) else {
                continue
            }
            
            let entry = PrayerWidgetEntry(
                date: entryDate,
                streakCount: 14,
                dailyGospelTitle: "Thu Sep 24: Daily Gospel",
                scriptureRef: "Philippians 4:6",
                scriptureQuote: "Have no anxiety about anything, but in everything by prayer and supplication with thanksgiving let your requests be made known to God.",
                nextRoutineName: "Night Examen & Gratitude",
                nextRoutineTime: "10:00 PM",
                isAudioPlaying: shared.isPlaying,
                playbackStartTime: shared.startTime,
                playingTrackTitle: shared.title,
                playingTrackSubtitle: shared.subtitle
            )
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget Timeline Entry
public struct PrayerWidgetEntry: TimelineEntry {
    public let date: Date
    public let streakCount: Int
    public let dailyGospelTitle: String
    public let scriptureRef: String
    public let scriptureQuote: String
    public let nextRoutineName: String
    public let nextRoutineTime: String
    
    // Live Audio / Activity State
    public let isAudioPlaying: Bool
    public let playbackStartTime: Date?
    public let playingTrackTitle: String
    public let playingTrackSubtitle: String
    
    public init(
        date: Date = Date(),
        streakCount: Int = 14,
        dailyGospelTitle: String = "Thu Sep 24: Daily Gospel",
        scriptureRef: String = "Philippians 4:6",
        scriptureQuote: String = "Have no anxiety about anything, but in everything by prayer and supplication with thanksgiving let your requests be made known to God.",
        nextRoutineName: String = "Night Examen & Gratitude",
        nextRoutineTime: String = "10:00 PM",
        isAudioPlaying: Bool = false,
        playbackStartTime: Date? = nil,
        playingTrackTitle: String = "Daily Gospel Narration",
        playingTrackSubtitle: String = "Narrated by Jonathan Roumie"
    ) {
        self.date = date
        self.streakCount = streakCount
        self.dailyGospelTitle = dailyGospelTitle
        self.scriptureRef = scriptureRef
        self.scriptureQuote = scriptureQuote
        self.nextRoutineName = nextRoutineName
        self.nextRoutineTime = nextRoutineTime
        self.isAudioPlaying = isAudioPlaying
        self.playbackStartTime = playbackStartTime
        self.playingTrackTitle = playingTrackTitle
        self.playingTrackSubtitle = playingTrackSubtitle
    }
}

// MARK: - Main Widget Entry View (Routes by Widget Family)
struct PrayerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: PrayerWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallGlassWidgetView(entry: entry)
        case .systemMedium:
            MediumGlassWidgetView(entry: entry)
        case .systemLarge:
            LargeGlassWidgetView(entry: entry)
        default:
            MediumGlassWidgetView(entry: entry)
        }
    }
}

// MARK: - Main Widget Configuration
struct GlassWidgets: Widget {
    let kind: String = "GlassWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerWidgetProvider()) { entry in
            PrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Prayer & Streak")
        .description("Keep track of your prayer streak, daily gospel, and live audio with liquid glass styling.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - 1. Small Widget View (Streak, Daily Gospel & Live State)
public struct SmallGlassWidgetView: View {
    @Environment(\.widgetRenderingMode) private var renderingMode
    public let entry: PrayerWidgetEntry
    
    public init(entry: PrayerWidgetEntry = PrayerWidgetEntry()) {
        self.entry = entry
    }
    
    public var body: some View {
        if entry.isAudioPlaying {
            nowPlayingSmallView
        } else {
            defaultSmallView
        }
    }
    
    // Live "Now Playing" Small View with Ticking Seconds Timer
    private var nowPlayingSmallView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Live Indicator & Clock
            HStack(alignment: .center) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("PLAYING")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.green)
                        .widgetAccentable()
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3.5)
                .background {
                    Capsule()
                        .fill(Color.primary.opacity(renderingMode == .accented ? 0.15 : 0.08))
                }
                
                Spacer()
                
                // Real-Time Clock
                Text(entry.date, style: .time)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.secondary)
                    .widgetAccentable()
            }
            
            Spacer(minLength: 4)
            
            // Audio Artwork Waveform Orb
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.15, green: 0.35, blue: 0.40),
                                    Color(red: 0.08, green: 0.18, blue: 0.22)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "waveform")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                }
                Spacer()
            }
            
            Spacer(minLength: 4)
            
            // Track Title & Live Ticking Seconds
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.playingTrackTitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .widgetAccentable()
                
                HStack {
                    Text(entry.playingTrackSubtitle)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Live Ticking Seconds Timer
                    Text(entry.playbackStartTime ?? Date(), style: .timer)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                        .widgetAccentable()
                }
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.primary.opacity(renderingMode == .accented ? 0.12 : 0.08))
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
    
    // Default Idle Small View
    private var defaultSmallView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top: Streak Badge & Live Clock
            HStack(alignment: .center) {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.orange)
                        .widgetAccentable()
                    
                    Text("\(entry.streakCount)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .widgetAccentable()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(Color.primary.opacity(renderingMode == .accented ? 0.15 : 0.08))
                }
                
                Spacer()
                
                // Real-Time Live Clock
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 10, weight: .semibold))
                    Text(entry.date, style: .time)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(Color.secondary)
                .widgetAccentable()
            }
            
            Spacer(minLength: 8)
            
            // Bottom: Gospel Title Card
            VStack(alignment: .leading, spacing: 3) {
                Text("DAILY GOSPEL")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.secondary)
                    .tracking(0.5)
                
                Text(entry.dailyGospelTitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
                    .widgetAccentable()
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(renderingMode == .accented ? 0.12 : 0.08))
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - 2. Medium Widget View (Daily Scripture Quote, Streak & Live State)
public struct MediumGlassWidgetView: View {
    @Environment(\.widgetRenderingMode) private var renderingMode
    public let entry: PrayerWidgetEntry
    
    public init(entry: PrayerWidgetEntry = PrayerWidgetEntry()) {
        self.entry = entry
    }
    
    public var body: some View {
        if entry.isAudioPlaying {
            nowPlayingMediumView
        } else {
            defaultMediumView
        }
    }
    
    // Live "Now Playing" Medium View with Ticking Seconds Timer
    private var nowPlayingMediumView: some View {
        HStack(spacing: 12) {
            // Left Column: Artwork Orb & Streak
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.orange)
                    Text("\(entry.streakCount)d")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3.5)
                .background(Color.primary.opacity(0.08), in: Capsule())
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.15, green: 0.35, blue: 0.40),
                                    Color(red: 0.08, green: 0.18, blue: 0.22)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "waveform")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                }
            }
            .frame(width: 70)
            
            // Right Column: Track Details & Live Timer
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("NOW PLAYING")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.green)
                    }
                    
                    Spacer()
                    
                    Text(entry.date, style: .time)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.playingTrackTitle)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                    
                    Text(entry.playingTrackSubtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 4)
                
                // Live Ticking Seconds & Session Pill
                HStack {
                    Image(systemName: "headphones")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                    
                    Text("Session Time")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                    
                    Spacer()
                    
                    Text(entry.playbackStartTime ?? Date(), style: .timer)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
    
    // Default Idle Medium View
    private var defaultMediumView: some View {
        HStack(spacing: 12) {
            // Left Column: Streak & Next Routine
            VStack(alignment: .leading, spacing: 0) {
                // Streak Pill
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.orange)
                        .widgetAccentable()
                    
                    Text("\(entry.streakCount) Days")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .widgetAccentable()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(Color.primary.opacity(renderingMode == .accented ? 0.15 : 0.08))
                }
                
                Spacer(minLength: 8)
                
                // Next Routine Section
                VStack(alignment: .leading, spacing: 2) {
                    Text("NEXT ROUTINE")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                        .tracking(0.5)
                    
                    Text(entry.nextRoutineName)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                    
                    Text(entry.nextRoutineTime)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.primary.opacity(renderingMode == .accented ? 0.12 : 0.06))
                }
            }
            .frame(width: 116, alignment: .leading)
            
            // Right Column: Scripture Reference & Quote
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.scriptureRef.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(renderingMode == .fullColor ? Color(red: 0.95, green: 0.80, blue: 0.50) : Color.secondary)
                        .widgetAccentable()
                    
                    Spacer()
                    
                    // Real-Time Live Clock (updates every minute on the home screen)
                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 8))
                        Text(entry.date, style: .time)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundStyle(Color.secondary)
                    .widgetAccentable()
                }
                
                Text("\"\(entry.scriptureQuote)\"")
                    .font(.system(size: 11, weight: .medium, design: .serif))
                    .lineSpacing(3)
                    .foregroundStyle(Color.primary)
                    .lineLimit(4)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.primary.opacity(renderingMode == .accented ? 0.12 : 0.08))
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - 3. Large Widget View (Full Daily Dashboard & Live State)
public struct LargeGlassWidgetView: View {
    @Environment(\.widgetRenderingMode) private var renderingMode
    public let entry: PrayerWidgetEntry
    
    public init(entry: PrayerWidgetEntry = PrayerWidgetEntry()) {
        self.entry = entry
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Streak & App Branding / Clock
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.orange)
                        .widgetAccentable()
                    
                    Text("\(entry.streakCount) Day Streak")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .widgetAccentable()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule()
                        .fill(Color.primary.opacity(renderingMode == .accented ? 0.15 : 0.08))
                }
                
                Spacer()
                
                // Real-Time Live Clock
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                    Text(entry.date, style: .time)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(Color.secondary)
                .widgetAccentable()
            }
            
            // If Playing: Live "Now Playing" Banner with Ticking Seconds
            if entry.isAudioPlaying {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.15, green: 0.35, blue: 0.40),
                                        Color(red: 0.08, green: 0.18, blue: 0.22)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "waveform")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Circle().fill(Color.green).frame(width: 6, height: 6)
                            Text("NOW PLAYING")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.green)
                        }
                        
                        Text(entry.playingTrackTitle)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Live Ticking Seconds Timer
                    Text(entry.playbackStartTime ?? Date(), style: .timer)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.primary.opacity(renderingMode == .accented ? 0.14 : 0.09))
                }
            } else {
                // Daily Gospel Hero Section (Idle state)
                HStack(spacing: 12) {
                    Image(systemName: "sun.haze.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(renderingMode == .fullColor ? Color(red: 0.95, green: 0.80, blue: 0.50) : Color.secondary)
                        .widgetAccentable()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TODAY'S GOSPEL")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.5)
                        
                        Text(entry.dailyGospelTitle)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.primary)
                        .widgetAccentable()
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.primary.opacity(renderingMode == .accented ? 0.12 : 0.08))
                }
            }
            
            // Scripture Quote Card
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.scriptureRef.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(renderingMode == .fullColor ? Color(red: 0.95, green: 0.80, blue: 0.50) : Color.secondary)
                        .widgetAccentable()
                    
                    Spacer()
                    
                    Image(systemName: "quote.opening")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .widgetAccentable()
                }
                
                Text("\"\(entry.scriptureQuote)\"")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .lineSpacing(3)
                    .foregroundStyle(Color.primary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.primary.opacity(renderingMode == .accented ? 0.12 : 0.08))
            }
            
            Spacer(minLength: 0)
            
            // Next Routine Item
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(renderingMode == .fullColor ? Color.purple : Color.secondary)
                    .widgetAccentable()
                
                Text(entry.nextRoutineName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                Text(entry.nextRoutineTime)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(renderingMode == .accented ? 0.12 : 0.08))
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Previews
#Preview("Small - Idle", as: .systemSmall) {
    GlassWidgets()
} timeline: {
    PrayerWidgetEntry(isAudioPlaying: false)
}

#Preview("Small - Live Playing", as: .systemSmall) {
    GlassWidgets()
} timeline: {
    PrayerWidgetEntry(isAudioPlaying: true, playbackStartTime: Date().addingTimeInterval(-45))
}

#Preview("Medium - Live Playing", as: .systemMedium) {
    GlassWidgets()
} timeline: {
    PrayerWidgetEntry(isAudioPlaying: true, playbackStartTime: Date().addingTimeInterval(-120))
}

#Preview("Large - Live Playing", as: .systemLarge) {
    GlassWidgets()
} timeline: {
    PrayerWidgetEntry(isAudioPlaying: true, playbackStartTime: Date().addingTimeInterval(-300))
}
