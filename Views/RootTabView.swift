//
//  RootTabView.swift
//  MedCare

import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            RootTabView()
        } else {
            OnboardingView()
        }
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Today", systemImage: "leaf.fill")
            }

            NavigationStack {
                PrescriptionListView()
            }
            .tabItem {
                Label("Medicines", systemImage: "pills.fill")
            }

            NavigationStack {
                HealthGradeView()
            }
            .tabItem {
                Label("Health Grade", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
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
}
