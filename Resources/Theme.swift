//
//  Theme.swift
//  MedCare

import SwiftUI

extension Color {
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        self = light
        #endif
    }
}

enum Theme {
    // MARK: - Colors (Ocean Mint palette, light / dark variants)
    static let leafGreen = Color(
        light: Color(red: 0.10, green: 0.47, blue: 0.49),
        dark:  Color(red: 0.25, green: 0.62, blue: 0.64)
    )
    static let deepFern = Color(
        light: Color(red: 0.07, green: 0.20, blue: 0.28),
        dark:  Color(red: 0.93, green: 0.96, blue: 0.97)
    )
    static let sage = Color(
        light: Color(red: 0.66, green: 0.87, blue: 0.83),
        dark:  Color(red: 0.22, green: 0.38, blue: 0.38)
    )
    static let cream = Color(
        light: Color.white,
        dark:  Color(red: 0.07, green: 0.10, blue: 0.13)
    )
    static let bark = Color(
        light: Color(red: 0.24, green: 0.38, blue: 0.46),
        dark:  Color(red: 0.68, green: 0.78, blue: 0.82)
    )
    static let sunAccent = Color(
        light: Color(red: 0.87, green: 0.62, blue: 0.20),
        dark:  Color(red: 0.95, green: 0.72, blue: 0.32)
    )
    static let petalPink = Color(
        light: Color(red: 0.85, green: 0.38, blue: 0.34),
        dark:  Color(red: 0.93, green: 0.50, blue: 0.46)
    )

    static let cardBackground = cream

    // MARK: - Grade Colors
    
    static func color(for grade: HealthGrade) -> Color {
        switch grade {
        case .a: return leafGreen
        case .b: return Color(
            light: Color(red: 0.24, green: 0.58, blue: 0.52),
            dark:  Color(red: 0.38, green: 0.70, blue: 0.62)
        )
        case .c: return sunAccent
        case .d: return Color(
            light: Color(red: 0.82, green: 0.48, blue: 0.22),
            dark:  Color(red: 0.90, green: 0.58, blue: 0.32)
        )
        case .f: return petalPink
        }
    }

    // MARK: - Typography

    static let titleFont    = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont  = Font.system(.title2, design: .rounded).weight(.bold)
    static let bodyFont     = Font.system(.title3, design: .rounded).weight(.medium)
    static let captionFont  = Font.system(.callout, design: .rounded).weight(.medium)

    // MARK: - Accessible text colors

    static func primaryText(highContrast: Bool, colorScheme: ColorScheme) -> Color {
        guard highContrast else { return deepFern }
        return colorScheme == .dark ? .white : .black
    }

    static func secondaryText(highContrast: Bool, colorScheme: ColorScheme) -> Color {
        guard highContrast else { return bark.opacity(0.85) }
        return colorScheme == .dark ? Color.white.opacity(0.75) : Color.black.opacity(0.75)
    }

    // MARK: - Reusable Modifiers
    static let cornerRadius: CGFloat = 20
    static let minTapTarget: CGFloat = 44
}

struct BotanicalBackgroundView: View {
    var body: some View {
        Theme.cream.ignoresSafeArea()
    }
}

struct CardBackground: ViewModifier {
    @EnvironmentObject var accessibility: AccessibilitySettings
    @Environment(\.colorScheme) private var colorScheme

    private var highContrastLineColor: Color {
        colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6)
    }

    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(
                        accessibility.isHighContrastMode ? highContrastLineColor : Theme.sage.opacity(0.6),
                        lineWidth: accessibility.isHighContrastMode ? 1.5 : 1
                    )
            )
            .shadow(
                color: Theme.deepFern.opacity(accessibility.isHighContrastMode ? 0 : 0.06),
                radius: 8, x: 0, y: 4
            )
    }
}

struct SecondaryTextStyle: ViewModifier {
    @EnvironmentObject var accessibility: AccessibilitySettings
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.foregroundColor(
            Theme.secondaryText(highContrast: accessibility.isHighContrastMode, colorScheme: colorScheme)
        )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardBackground())
    }

    func secondaryTextStyle() -> some View {
        modifier(SecondaryTextStyle())
    }
}
