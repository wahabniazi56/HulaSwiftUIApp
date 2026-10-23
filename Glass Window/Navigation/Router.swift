//
//  Router.swift
//  Glass Window
//
//  Created by mac on 28/09/2026.
//

import SwiftUI
import Combine

// MARK: - 1. AppRoute Enum
public enum AppRoute: Hashable, Identifiable {
    case dailyGospelDetail(title: String, subtitle: String)
    case whatsOnYourHeart
    case dailyScriptureDetail(reference: String, quote: String)
    case readingDetail(type: String, title: String, passageText: String)
    case bibleBookDetail(bookName: String, chaptersCount: Int)
    case categoryDetail(categoryTitle: String, iconName: String)
    case guideProfileDetail(guideName: String, role: String, iconName: String)
    case churchFinder
    case routineDetail(routineTitle: String, duration: String)
    case settings
    case spiritualChat
    
    public var id: String {
        switch self {
        case .dailyGospelDetail(let title, let subtitle):
            return "dailyGospel_\(title)_\(subtitle)"
        case .whatsOnYourHeart:
            return "whatsOnYourHeart"
        case .dailyScriptureDetail(let reference, _):
            return "dailyScripture_\(reference)"
        case .readingDetail(let type, let title, _):
            return "reading_\(type)_\(title)"
        case .bibleBookDetail(let bookName, let chaptersCount):
            return "bibleBook_\(bookName)_\(chaptersCount)"
        case .categoryDetail(let categoryTitle, let iconName):
            return "category_\(categoryTitle)_\(iconName)"
        case .guideProfileDetail(let guideName, let role, _):
            return "guide_\(guideName)_\(role)"
        case .churchFinder:
            return "churchFinder"
        case .routineDetail(let routineTitle, let duration):
            return "routine_\(routineTitle)_\(duration)"
        case .settings:
            return "settings"
        case .spiritualChat:
            return "spiritualChat"
        }
    }
}

// MARK: - Presentation Style
public enum PresentationStyle {
    case push
    case sheet
    case mediumSheet
    case fullScreenCover
}

// MARK: - 2. Router Observable Object
public final class Router: ObservableObject {
    @Published public var stack: [AppRoute] = []
    @Published public var sheet: AppRoute?
    @Published public var mediumSheet: AppRoute?
    @Published public var fullScreenCover: AppRoute?
    
    public init() {}
    
    public func present(_ route: AppRoute, style: PresentationStyle = .push) {
        switch style {
        case .push:
            stack.append(route)
        case .sheet:
            sheet = route
        case .mediumSheet:
            mediumSheet = route
        case .fullScreenCover:
            fullScreenCover = route
        }
    }
    
    public func dismiss() {
        if fullScreenCover != nil {
            fullScreenCover = nil
        } else if sheet != nil {
            sheet = nil
        } else if mediumSheet != nil {
            mediumSheet = nil
        } else if !stack.isEmpty {
            stack.removeLast()
        }
    }
    
    public func popToRoot() {
        stack.removeAll()
        sheet = nil
        mediumSheet = nil
        fullScreenCover = nil
    }
}

// MARK: - 3. RouterView Container
public struct RouterView<Content: View>: View {
    @StateObject private var router = Router()
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        NavigationStack(path: $router.stack) {
            content
                .navigationDestination(for: AppRoute.self) { route in
                    router.view(for: route)
                }
        }
        .environmentObject(router)
        .sheet(item: $router.sheet) { route in
            router.view(for: route)
                .environmentObject(router)
        }
        .sheet(item: $router.mediumSheet) { route in
            router.view(for: route)
                .environmentObject(router)
                .presentationDetents([.medium, .large])
        }
        .fullScreenCover(item: $router.fullScreenCover) { route in
            router.view(for: route)
                .environmentObject(router)
        }
    }
}

// MARK: - 4. Router View Factory
extension Router {
    @ViewBuilder
    public func view(for route: AppRoute) -> some View {
        switch route {
        case .dailyGospelDetail(let title, let subtitle):
            DailyGospelDetailView(title: title, subtitle: subtitle)
        case .whatsOnYourHeart:
            WhatsOnYourHeartView()
        case .dailyScriptureDetail(let reference, let quote):
            DailyScriptureDetailView(reference: reference, quote: quote)
        case .readingDetail(let type, let title, let passageText):
            ReadingDetailView(type: type, title: title, passageText: passageText)
        case .bibleBookDetail(let bookName, let chaptersCount):
            BibleBookDetailView(bookName: bookName, chaptersCount: chaptersCount)
        case .categoryDetail(let categoryTitle, let iconName):
            CategoryDetailView(categoryTitle: categoryTitle, iconName: iconName)
        case .guideProfileDetail(let guideName, let role, let iconName):
            GuideProfileDetailView(guideName: guideName, role: role, iconName: iconName)
        case .churchFinder:
            ChurchFinderDetailView()
        case .routineDetail(let routineTitle, let duration):
            RoutineDetailView(routineTitle: routineTitle, duration: duration)
        case .settings:
            SettingsDetailView()
        case .spiritualChat:
            SpiritualGuideChatView()
        }
    }
}
