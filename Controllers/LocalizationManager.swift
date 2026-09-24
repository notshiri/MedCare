//
//  LocalizationManager.swift
//  MedCare
//
//  CONTROLLER — holds the user's chosen app language (English or
//  Tagalog) and resolves UI strings against a small translation table.
//  Implemented as a code-based dictionary (rather than .strings/.lproj
//  resource files) so language switching is instant, in-app, and
//  doesn't depend on the user's device system language — appropriate
//  for a small, defined set of UI strings like this app's.
//

import Foundation
import Combine

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case tagalog = "tl"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .tagalog: return "Tagalog"
        }
    }
}

@MainActor
final class LocalizationManager: ObservableObject {

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Keys.language) }
    }

    private enum Keys {
        static let language = "medcare.language"
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: Keys.language)
        self.language = AppLanguage(rawValue: saved ?? "") ?? .english
    }

    /// Looks up `key` in the translation table for the current language.
    /// Falls back to the key itself (English) if no translation exists,
    /// so an untranslated string never renders blank.
    func t(_ key: String) -> String {
        translations[key]?[language] ?? key
    }

    // MARK: - Translation table
    // Covers the app's primary navigation, actions, and labels. Dynamic
    // content (medicine names, dosages the user typed, dates) is never
    // translated — only the app's own interface chrome.
    private let translations: [String: [AppLanguage: String]] = [
        // Tab bar / navigation titles
        "Today": [.english: "Today", .tagalog: "Ngayon"],
        "Medicines": [.english: "Medicines", .tagalog: "Gamot"],
        "Health Grade": [.english: "Health Grade", .tagalog: "Marka ng Kalusugan"],
        "Settings": [.english: "Settings", .tagalog: "Mga Setting"],

        // Dashboard
        "Today's Doses": [.english: "Today's Doses", .tagalog: "Dosis Ngayong Araw"],
        "Your Health Grade": [.english: "Your Health Grade", .tagalog: "Iyong Marka ng Kalusugan"],
        "No doses scheduled for today": [
            .english: "No doses scheduled for today",
            .tagalog: "Walang naka-iskedyul na dosis ngayon"
        ],

        // Dose actions
        "Taken": [.english: "Taken", .tagalog: "Nainom"],
        "Missed": [.english: "Missed", .tagalog: "Nakaligtaan"],
        "Pending": [.english: "Pending", .tagalog: "Naghihintay"],

        // Medicines list
        "No medicines yet": [.english: "No medicines yet", .tagalog: "Wala pang gamot"],
        "Add Prescription": [.english: "Add Prescription", .tagalog: "Magdagdag ng Reseta"],
        "Search medicines": [.english: "Search medicines", .tagalog: "Maghanap ng gamot"],
        "Paused": [.english: "Paused", .tagalog: "Nakapausa"],
        "Refill": [.english: "Refill", .tagalog: "Padagdag"],

        // Add / Edit Prescription form
        "New Prescription": [.english: "New Prescription", .tagalog: "Bagong Reseta"],
        "Edit Prescription": [.english: "Edit Prescription", .tagalog: "I-edit ang Reseta"],
        "Save": [.english: "Save", .tagalog: "I-save"],
        "Cancel": [.english: "Cancel", .tagalog: "Kanselahin"],
        "Delete Prescription": [.english: "Delete Prescription", .tagalog: "Burahin ang Reseta"],
        "Edit": [.english: "Edit", .tagalog: "I-edit"],

        // Health Grade
        "Grade Scale": [.english: "Grade Scale", .tagalog: "Sukatan ng Marka"],
        "By Medicine": [.english: "By Medicine", .tagalog: "Ayon sa Gamot"],
        "Last 7 Days": [.english: "Last 7 Days", .tagalog: "Nakaraang 7 Araw"],

        // Settings
        "Notifications": [.english: "Notifications", .tagalog: "Mga Abiso"],
        "Accessibility": [.english: "Accessibility", .tagalog: "Accessibility"],
        "Account": [.english: "Account", .tagalog: "Account"],
        "About": [.english: "About", .tagalog: "Tungkol"],
        "Data": [.english: "Data", .tagalog: "Datos"],
        "Language": [.english: "Language", .tagalog: "Wika"],
        "Sign Out": [.english: "Sign Out", .tagalog: "Mag-sign Out"],
        "Reset All Data": [.english: "Reset All Data", .tagalog: "I-reset ang Lahat ng Datos"],

        // Auth
        "Sign In": [.english: "Sign In", .tagalog: "Mag-sign In"],
        "Sign Up": [.english: "Sign Up", .tagalog: "Mag-sign Up"],
        "Create Account": [.english: "Create Account", .tagalog: "Gumawa ng Account"],
        "Email": [.english: "Email", .tagalog: "Email"],
        "Password": [.english: "Password", .tagalog: "Password"],
        "Forgot Password?": [.english: "Forgot Password?", .tagalog: "Nakalimutan ang Password?"],
        "Don't have an account? ": [
            .english: "Don't have an account? ",
            .tagalog: "Wala ka pang account? "
        ],
        "Create one": [.english: "Create one", .tagalog: "Gumawa ng isa"],

        // Onboarding
        "Next": [.english: "Next", .tagalog: "Susunod"],
        "Get Started": [.english: "Get Started", .tagalog: "Simulan Na"],
        "Skip": [.english: "Skip", .tagalog: "Laktawan"],
    ]
}
