//
//  Theme.swift
//  MedCare
//
//  Centralized "Ocean Mint" visual theme — teal, navy, and mint on a
//  clean white background — so every screen looks consistent without
//  repeating hex codes everywhere. Also home to the accessibility-aware
//  text and card styles used throughout the app.
//
//  Note: color property NAMES are kept from the app's original palette
//  (leafGreen, deepFern, sage, cream, bark, sunAccent, petalPink) even
//  though the actual colors below are now Ocean Mint — every screen
//  references these same names, so the palette can be re-themed here
//  in one place without touching any other file.
//

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
    // Ocean-Mint-tinted grade scale: teal for top marks, sliding through
    // mint-green, amber, orange, and coral as adherence drops.
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
    // Sized a step larger than iOS defaults, with slightly heavier
    // weights, since low-vision and older users benefit from bolder,
    // bigger type even before Dynamic Type scaling kicks in.
    static let titleFont    = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont  = Font.system(.title2, design: .rounded).weight(.bold)
    static let bodyFont     = Font.system(.title3, design: .rounded).weight(.medium)
    static let captionFont  = Font.system(.callout, design: .rounded).weight(.medium)

    // MARK: - Accessible text colors
    // `.secondary` text can be too low-contrast for some users, so every
    // screen should call these instead of `.foregroundStyle(.secondary)`.
    static func primaryText(highContrast: Bool) -> Color {
        highContrast ? .black : deepFern
    }

    static func secondaryText(highContrast: Bool) -> Color {
        highContrast ? Color.black.opacity(0.75) : bark.opacity(0.85)
    }

    // MARK: - Reusable Modifiers
    static let cornerRadius: CGFloat = 20
    /// Minimum comfortable tap target per Apple's accessibility guidance.
    static let minTapTarget: CGFloat = 44
}

/// The app's background, per the client's request: a clean, plain white
/// behind every screen (Ocean Mint accents live in cards, icons, and
/// text instead of a background wash). Kept as its own view — rather
/// than inlining `Color.white` on every screen — so the whole app's
/// background can be changed again from this one place later.
struct BotanicalBackgroundView: View {
    var body: some View {
        Color.white.ignoresSafeArea()
    }
}

/// A reusable "card" container. On a white page background, cards get a
/// soft shadow plus a hairline mint border so they still read as
/// distinct surfaces rather than disappearing into the page. Reads
/// AccessibilitySettings so High Contrast Mode swaps that hairline for
/// a bolder black outline automatically, everywhere `.cardStyle()` is used.
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

/// Drop-in replacement for `.foregroundStyle(.secondary)` that stays
/// legible in both normal and High Contrast Mode.
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
