//
//  SettingsView.swift
//  MedCare
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var notifier: NotificationController
    @EnvironmentObject var controller: PrescriptionController
    @EnvironmentObject var accessibility: AccessibilitySettings
    @State private var isShowingResetConfirm = false

    var body: some View {
        ZStack {
            BotanicalBackgroundView()
            Form {
                Section("Notifications") {
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
                            Text("Uses bold black text, plain white cards, and outlined borders for maximum readability.")
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
                    Text("Accessibility")
                } footer: {
                    Text("These settings also respect your device's own Text Size and Bold Text settings in the iOS Settings app.")
                }

                Section("About") {
                    HStack {
                        Text("App")
                        Spacer()
                        Text("MedCare 🌿").secondaryTextStyle()
                    }
                    Text("MedCare helps you log prescriptions, get reminded when it's time to take them, and track your adherence with a real-time Health Grade.")
                        .font(Theme.captionFont)
                        .secondaryTextStyle()
                }

                Section("Data") {
                    Button("Reset All Data", role: .destructive) {
                        isShowingResetConfirm = true
                    }
                    .frame(minHeight: Theme.minTapTarget)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
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
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(PrescriptionController())
            .environmentObject(NotificationController())
            .environmentObject(AccessibilitySettings())
    }
}
