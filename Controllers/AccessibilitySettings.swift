//
//  AccessibilitySettings.swift
//  MedCare


import Foundation
import Combine
import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case system, light, dark

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

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
    @Published var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: Keys.appearance) }
    }

    private enum Keys {
        static let largeText = "medcare.accessibility.largeText"
        static let highContrast = "medcare.accessibility.highContrast"
        static let haptics = "medcare.accessibility.haptics"
        static let appearance = "medcare.display.appearance"
    }

    init() {
        let defaults = UserDefaults.standard
        self.isLargeTextMode = defaults.bool(forKey: Keys.largeText)
        self.isHighContrastMode = defaults.bool(forKey: Keys.highContrast)
        self.isHapticFeedbackEnabled = defaults.object(forKey: Keys.haptics) == nil
            ? true
            : defaults.bool(forKey: Keys.haptics)
        self.appearanceMode = AppearanceMode(rawValue: defaults.string(forKey: Keys.appearance) ?? "") ?? .system
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
