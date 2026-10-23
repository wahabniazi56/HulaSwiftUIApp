//
//  NotificationManager.swift
//  Glass Window
//
//  Created by mac on 13/10/2026.
//

import Foundation
import UserNotifications

/// Manages local notifications for user inactivity reminders and background alerts.
public final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    public static let shared = NotificationManager()
    
    /// Unique identifier for the inactivity reminder notification request
    private let inactivityIdentifier = "app_inactivity_notification"
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Permission Request
    /// Requests notification permissions (alert, sound, badge) from the user
    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("NotificationManager: Authorization error - \(error.localizedDescription)")
            } else {
                print("NotificationManager: Notification permission granted: \(granted)")
            }
        }
    }
    
    // MARK: - Scheduling
    /// Schedules a local notification to fire after the app has been closed or backgrounded for the specified duration.
    /// - Parameter minutes: Delay in minutes before the notification triggers (default is 20 minutes).
    public func scheduleInactivityNotification(minutes: Double = 20) {
        // Remove any prior pending inactivity notifications to prevent duplicates
        cancelInactivityNotification()
        
        let content = UNMutableNotificationContent()
        content.title = "Glass Window"
        content.body = "your app is cloese more then 20 mins"
        content.sound = .default
        
        // 20 minutes = 1200 seconds (minimum interval for UNTimeIntervalNotificationTrigger is > 0)
        let timeIntervalInSeconds = max(minutes * 60, 5)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalInSeconds, repeats: false)
        let request = UNNotificationRequest(identifier: inactivityIdentifier, content: content, trigger: trigger)
        
        // Add directly to iOS notification system daemon (works immediately even if app is terminated)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("NotificationManager: Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("NotificationManager: Notification scheduled successfully for \(timeIntervalInSeconds)s from now.")
            }
        }
    }
    
    // MARK: - Cancellation
    /// Cancels any pending or already delivered inactivity notification when the user returns to the app.
    public func cancelInactivityNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [inactivityIdentifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [inactivityIdentifier])
        print("NotificationManager: Inactivity notification cancelled.")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    /// Allows the notification banner and sound to present even if the app happens to be in foreground
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
