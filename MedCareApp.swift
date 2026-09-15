//
//  MedCareApp.swift
//  MedCare

import SwiftUI

@main
struct MedCareApp: App {

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
