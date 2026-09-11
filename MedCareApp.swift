//
//  MedCareApp.swift
//  MedCare
//
//  App entry point. Creates the shared Controllers (the "C" in MVC) as
//  StateObjects, injects them into the environment, and applies the
//  app-wide Dynamic Type range driven by AccessibilitySettings so every
//  screen respects Large Text Mode consistently.
//

import SwiftUI

@main
struct MedCareApp: App {

    // Single shared instances — this is our "Controller" layer.
    @StateObject private var prescriptionController = PrescriptionController()
    @StateObject private var notificationController = NotificationController()
    @StateObject private var accessibilitySettings = AccessibilitySettings()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(prescriptionController)
                .environmentObject(notificationController)
                .environmentObject(accessibilitySettings)
                .dynamicTypeSize(accessibilitySettings.dynamicTypeRange)
                .onAppear {
                    notificationController.requestAuthorization()
                }
        }
    }
}
