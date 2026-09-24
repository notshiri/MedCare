//
//  SettingsView.swift
//  MedCare

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var notifier: NotificationController
    @EnvironmentObject var controller: PrescriptionController
    @EnvironmentObject var accessibility: AccessibilitySettings
    @EnvironmentObject var auth: AuthController
    @EnvironmentObject var loc: LocalizationManager
    @State private var isShowingResetConfirm = false
    @State private var isShowingSignOutConfirm = false

    var body: some View {
        ZStack {
            BotanicalBackgroundView()
            Form {
                Section(loc.t("Account")) {
                    HStack {
                        Text("Signed in as")
                        Spacer()
                        Text(auth.userEmail ?? "—").secondaryTextStyle()
                    }
                    Button(loc.t("Sign Out"), role: .destructive) {
                        isShowingSignOutConfirm = true
                    }
                    .frame(minHeight: Theme.minTapTarget)
                }

                Section(loc.t("Notifications")) {
                    HStack {
                        Text("Push Notifications")
                        Spacer()
                        Text(notifier.isAuthorized ? "Enabled" : "Not Enabled")
                            .foregroundStyle(notifier.isAuthorized ? Theme.leafGreen : Color.secondary)
                    }
                    if !notifier.isAuthorized {
                        Button("Request Permission") {
                            notifier.requestAuthorization()
                        }
                    }
                }

                Section {
                    Picker(loc.t("Language"), selection: $loc.language) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                } header: {
                    Text(loc.t("Language"))
                } footer: {
                    Text("Switches the app's own interface text. Medicine names and dosages you've entered are never translated.")
                }

                Section {
                    Picker("Appearance", selection: $accessibility.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("\"System\" follows your device's own Light/Dark Mode setting.")
                }

                Section {
                    Toggle(isOn: $accessibility.isLargeTextMode) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Large Text Mode")
                            Text("Makes all text significantly bigger throughout the app.")
                                .font(Theme.captionFont)
                                .secondaryTextStyle()
                        }
                    }
                    Toggle(isOn: $accessibility.isHighContrastMode) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("High Contrast Mode")
                            Text("Uses bold text and outlined borders for maximum readability.")
                                .font(Theme.captionFont)
                                .secondaryTextStyle()
                        }
                    }
                    Toggle(isOn: $accessibility.isHapticFeedbackEnabled) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Haptic Feedback")
                            Text("Feel a light tap when you mark a dose Taken or Missed.")
                                .font(Theme.captionFont)
                                .secondaryTextStyle()
                        }
                    }
                } header: {
                    Text(loc.t("Accessibility"))
                } footer: {
                    Text("These settings also respect your device's own Text Size and Bold Text settings in the iOS Settings app.")
                }

                Section(loc.t("About")) {
                    HStack {
                        Text("App")
                        Spacer()
                        Text("MedCare 🌿").secondaryTextStyle()
                    }
                    Text("MedCare helps you log prescriptions, get reminded when it's time to take them, and track your adherence with a real-time Health Grade.")
                        .font(Theme.captionFont)
                        .secondaryTextStyle()
                }

                Section(loc.t("Data")) {
                    Button(loc.t("Reset All Data"), role: .destructive) {
                        isShowingResetConfirm = true
                    }
                    .frame(minHeight: Theme.minTapTarget)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(loc.t("Settings"))
        .confirmationDialog(
            "This will delete all prescriptions and dose history.",
            isPresented: $isShowingResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset Everything", role: .destructive) {
                for prescription in controller.prescriptions {
                    controller.deletePrescription(prescription, notifier: notifier)
                }
            }
            Button(loc.t("Cancel"), role: .cancel) {}
        }
        .confirmationDialog(
            "Sign out of MedCare?",
            isPresented: $isShowingSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button(loc.t("Sign Out"), role: .destructive) {
                auth.signOut()
            }
            Button(loc.t("Cancel"), role: .cancel) {}
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(PrescriptionController())
            .environmentObject(NotificationController())
            .environmentObject(AccessibilitySettings())
            .environmentObject(AuthController())
            .environmentObject(LocalizationManager())
    }
}
