//
//  Theme.swift
//  MedCare


import SwiftUI

enum Theme {
    // MARK: - Colors (Ocean Mint palette)
    static let leafGreen      = Color(red: 0.10, green: 0.47, blue: 0.49)  // primary — ocean teal
    static let deepFern       = Color(red: 0.07, green: 0.20, blue: 0.28)  // headings / primary text — deep navy
    static let sage           = Color(red: 0.66, green: 0.87, blue: 0.83)  // soft mint — tints, tracks, empty states
    static let cream          = Color.white                                 // app + card backgrounds
    static let bark           = Color(red: 0.24, green: 0.38, blue: 0.46)  // secondary accent — slate navy
    static let sunAccent      = Color(red: 0.87, green: 0.62, blue: 0.20)  // warning / refill — amber
    static let petalPink      = Color(red: 0.85, green: 0.38, blue: 0.34)  // danger / missed — coral

    static let cardBackground = Color.white

    // MARK: - Grade Colors
    static func color(for grade: HealthGrade) -> Color {
        switch grade {
        case .a: return leafGreen
        case .b: return Color(red: 0.24, green: 0.58, blue: 0.52)
        case .c: return sunAccent
        case .d: return Color(red: 0.82, green: 0.48, blue: 0.22)
        case .f: return petalPink
        }
    }

    // MARK: - Typography
    static let titleFont    = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont  = Font.system(.title2, design: .rounded).weight(.bold)
    static let bodyFont     = Font.system(.title3, design: .rounded).weight(.medium)
    static let captionFont  = Font.system(.callout, design: .rounded).weight(.medium)

    // MARK: - Accessible text colors
    static func primaryText(highContrast: Bool) -> Color {
        highContrast ? .black : deepFern
    }

    static func secondaryText(highContrast: Bool) -> Color {
        highContrast ? Color.black.opacity(0.75) : bark.opacity(0.85)
    }

    // MARK: - Reusable Modifiers
    static let cornerRadius: CGFloat = 20
    static let minTapTarget: CGFloat = 44
}

struct BotanicalBackgroundView: View {
    var body: some View {
        Color.white.ignoresSafeArea()
    }
}

struct CardBackground: ViewModifier {
    @EnvironmentObject var accessibility: AccessibilitySettings

    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(
                        accessibility.isHighContrastMode ? Color.black.opacity(0.6) : Theme.sage.opacity(0.6),
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

    func body(content: Content) -> some View {
        content.foregroundColor(Theme.secondaryText(highContrast: accessibility.isHighContrastMode))
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
