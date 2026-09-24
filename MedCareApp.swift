//
//  MedCareApp.swift
//  MedCare

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MedCareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authController = AuthController()
    @StateObject private var prescriptionController = PrescriptionController()
    @StateObject private var notificationController = NotificationController()
    @StateObject private var accessibilitySettings = AccessibilitySettings()
    @StateObject private var localization = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authController)
                .environmentObject(prescriptionController)
                .environmentObject(notificationController)
                .environmentObject(accessibilitySettings)
                .environmentObject(localization)
                .dynamicTypeSize(accessibilitySettings.dynamicTypeRange)
                .preferredColorScheme(accessibilitySettings.appearanceMode.colorScheme)
                .onAppear {
                    notificationController.requestAuthorization()
                }
        }
    }
}
