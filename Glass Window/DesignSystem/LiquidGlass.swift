//
//  LiquidGlass.swift
//  Glass Window
//
//  Created by mac on 24/09/2026.
//

import SwiftUI

// MARK: - Glass Effect Styles
public enum GlassEffectStyle {
    case regular
    case prominent
    case thin
    case ultraThin
    
    var material: Material {
        switch self {
        case .regular: return .regularMaterial
        case .prominent: return .thickMaterial
        case .thin: return .thinMaterial
        case .ultraThin: return .ultraThinMaterial
        }
    }
}

// MARK: - Apple's Default Glass Background Effect Extensions
public extension View {
    /// Apple's default glass background effect with custom shape
    @ViewBuilder
    func glassBackgroundEffect<S: InsettableShape>(
        in shape: S
    ) -> some View {
        #if os(visionOS)
        self.glassBackgroundEffect(in: shape)
        #else
        self.glassEffect(.ultraThin, in: shape)
//        self.background(.ultraThinMaterial, in: shape)
        #endif
    }
    
    /// Apple's default glass background effect (default rounded rectangle)
    @ViewBuilder
    func glassBackgroundEffect() -> some View {
        #if os(visionOS)
        self.glassBackgroundEffect()
        #else
        self.glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
//        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        #endif
    }
    
    /// Apple's glassEffect with style and shape
    @ViewBuilder
    func glassEffect<S: InsettableShape>(
        _ style: GlassEffectStyle = .regular,
        in shape: S
    ) -> some View {
        self.glassEffect(.clear, in: shape)
//        self.background(style.material, in: shape)
    }
    
    /// Apple's glassEffect with default shape
    @ViewBuilder
    func glassEffect(
        _ style: GlassEffectStyle = .regular
    ) -> some View {
        self.glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
//        self.background(style.material, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    // Convenience helper methods
    func liquidGlass(cornerRadius: CGFloat = 24) -> some View {
        self.glassBackgroundEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    func liquidGlassCircle() -> some View {
        self.glassBackgroundEffect(in: Circle())
    }
    
    func liquidGlassCapsule() -> some View {
        self.glassBackgroundEffect(in: Capsule())
    }
}

// MARK: - Default Ambient Background (Dark Theme Canvas)
public struct LiquidAtmosphereBackground: View {
    /// Dark obsidian matte canvas matching the reference theme
    public static let darkCanvas = Color(red: 0.09, green: 0.09, blue: 0.10)
    
    public init() {}
    
    public var body: some View {
        Self.darkCanvas
            .ignoresSafeArea()
    }
}
