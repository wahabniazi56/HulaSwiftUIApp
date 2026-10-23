//
//  OrientationManager.swift
//  Glass Window
//
//  Created by mac on 02/10/2026.
//

import SwiftUI
import UIKit

/// Manages dynamic device and window orientation locks for transitions like Fullscreen Video playback.
public final class OrientationManager {
    
    /// The currently allowed orientation mask (defaults to portrait for the app)
    public static var orientationLock: UIInterfaceOrientationMask = .portrait
    
    /// Updates the orientation lock mask
    public static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        self.orientationLock = orientation
    }
    
    /// Requests a smooth animated geometry update / device rotation to the target orientation mask
    public static func rotate(to orientation: UIInterfaceOrientationMask) {
        self.orientationLock = orientation
        
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first(where: {
                $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive
            }) as? UIWindowScene else {
                return
            }
            
            if #available(iOS 16.0, *) {
                let targetMask: UIInterfaceOrientationMask
                if orientation == .landscape || orientation == .landscapeRight || orientation == .landscapeLeft {
                    targetMask = .landscape
                } else {
                    targetMask = .portrait
                }
                
                let preferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: targetMask)
                scene.requestGeometryUpdate(preferences) { error in
                    print("OrientationManager: Geometry update error - \(error.localizedDescription)")
                }
                
                scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                let value: Int
                if orientation == .landscape || orientation == .landscapeRight {
                    value = UIInterfaceOrientation.landscapeRight.rawValue
                } else if orientation == .landscapeLeft {
                    value = UIInterfaceOrientation.landscapeLeft.rawValue
                } else {
                    value = UIInterfaceOrientation.portrait.rawValue
                }
                UIDevice.current.setValue(value, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}
