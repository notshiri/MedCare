//
//  AccessibilitySettings.swift
//  MedCare
//
//  CONTROLLER — holds the user's accessibility preferences (Large Text
//  Mode, High Contrast Mode, Haptic Feedback) as shared, persisted
//  state. Injected as an environment object so every screen and
//  reusable component can react to it live, without each screen
//  managing its own copy.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class AccessibilitySettings: ObservableObject {

    @Published var isLargeTextMode: Bool {
        didSet { UserDefaults.standard.set(isLargeTextMode, forKey: Keys.largeText) }
    }
    @Published var isHighContrastMode: Bool {
        didSet { UserDefaults.standard.set(isHighContrastMode, forKey: Keys.highContrast) }
    }
    @Published var isHapticFeedbackEnabled: Bool {
        didSet { UserDefaults.standard.set(isHapticFeedbackEnabled, forKey: Keys.haptics) }
    }

    private enum Keys {
        static let largeText = "medcare.accessibility.largeText"
        static let highContrast = "medcare.accessibility.highContrast"
        static let haptics = "medcare.accessibility.haptics"
    }

    init() {
        let defaults = UserDefaults.standard
        self.isLargeTextMode = defaults.bool(forKey: Keys.largeText)
        self.isHighContrastMode = defaults.bool(forKey: Keys.highContrast)
        // Default haptics ON unless the user has explicitly turned them off.
        self.isHapticFeedbackEnabled = defaults.object(forKey: Keys.haptics) == nil
            ? true
            : defaults.bool(forKey: Keys.haptics)
    }

    var dynamicTypeRange: ClosedRange<DynamicTypeSize> {
        isLargeTextMode
            ? DynamicTypeSize.accessibility1...DynamicTypeSize.accessibility5
            : DynamicTypeSize.large...DynamicTypeSize.accessibility3
    }

    func confirmationHaptic() {
        guard isHapticFeedbackEnabled else { return }
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}
