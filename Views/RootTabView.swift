//
//  RootTabView.swift
//  MedCare


import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthController
    @EnvironmentObject var prescriptionController: PrescriptionController
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if !auth.isAuthenticated {
                LoginView()
            } else {
                RootTabView()
            }
        }
        .onChange(of: auth.userId) { _, newUserId in
            if let newUserId {
                prescriptionController.startListening(userId: newUserId)
            } else {
                prescriptionController.stopListening()
            }
        }
        .onAppear {
            if let userId = auth.userId {
                prescriptionController.startListening(userId: userId)
            }
        }
    }
}

struct RootTabView: View {
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label(loc.t("Today"), systemImage: "leaf.fill")
            }

            NavigationStack {
                PrescriptionListView()
            }
            .tabItem {
                Label(loc.t("Medicines"), systemImage: "pills.fill")
            }

            NavigationStack {
                HealthGradeView()
            }
            .tabItem {
                Label(loc.t("Health Grade"), systemImage: "chart.bar.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(loc.t("Settings"), systemImage: "gearshape.fill")
            }
        }
        .tint(Theme.deepFern)
    }
}

#Preview {
    RootView()
        .environmentObject(PrescriptionController())
        .environmentObject(NotificationController())
        .environmentObject(AccessibilitySettings())
        .environmentObject(AuthController())
        .environmentObject(LocalizationManager())
}
