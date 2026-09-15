//
//  DashboardView.swift
//  MedCare


import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var controller: PrescriptionController

    private var todaysDoses: [DoseLog] {
        controller.todaysDoses()
    }

    var body: some View {
        ZStack {
            BotanicalBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    HStack {
                        HealthGradeBadgeView(grade: controller.currentHealthGrade(), size: 70)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Health Grade")
                                .font(Theme.captionFont)
                                .secondaryTextStyle()
                            Text(controller.currentHealthGrade().label)
                                .font(Theme.headingFont)
                            Text("\(Int(controller.adherencePercentage()))% adherence • \(controller.currentStreak())-day streak")
                                .font(Theme.captionFont)
                                .secondaryTextStyle()
                        }
                        Spacer()
                    }
                    .cardStyle()

                    Text("Today's Doses")
                        .font(Theme.headingFont)
                        .padding(.horizontal, 4)

                    if todaysDoses.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 12) {
                            ForEach(todaysDoses) { dose in
                                if let prescription = controller.prescription(for: dose) {
                                    DoseRowView(prescription: prescription, doseLog: dose) { status in
                                        controller.markDose(dose, as: status)
                                    }
                                    .cardStyle()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("MedCare 🌿")
        .onAppear {
            controller.generateTodaysDoseLogsIfNeeded()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 44))
                .foregroundColor(Theme.leafGreen)
            Text("No doses scheduled for today")
                .font(Theme.bodyFont)
                .secondaryTextStyle()
            Text("Add a prescription in the Medicines tab to get started.")
                .font(Theme.captionFont)
                .secondaryTextStyle()
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(PrescriptionController())
            .environmentObject(NotificationController())
            .environmentObject(AccessibilitySettings())
    }
}
