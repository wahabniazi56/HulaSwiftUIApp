//
//  Glass_WindowApp.swift
//  Glass Window
//
//  Created by mac on 24/09/2026.
//

import SwiftUI
import SuperwallKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return OrientationManager.orientationLock
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Request notification authorization on app launch
        NotificationManager.shared.requestAuthorization()
        // Step 3: Configure Superwall SDK with your Public API Key (pk_...)
        Superwall.configure(apiKey: "pk_rC2koLEQGmczc8Q3FmKy7")
               
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Guarantees notification is scheduled even if the app is terminated completely
        NotificationManager.shared.scheduleInactivityNotification(minutes: 10.0 / 60.0)
    }
}

@main
struct Glass_WindowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background:
                // App is closed or sent to background -> schedule notification for 20 mins
                NotificationManager.shared.scheduleInactivityNotification(minutes: 20)
            case .active:
                // App reopened before 20 mins -> cancel scheduled notification
                NotificationManager.shared.cancelInactivityNotification()
            default:
                break
            }
        }
    }
}

