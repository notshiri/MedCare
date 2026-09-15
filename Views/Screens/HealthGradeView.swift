//
//  HealthGradeView.swift
//  MedCare

import SwiftUI

struct HealthGradeView: View {
    @EnvironmentObject var controller: PrescriptionController

    var body: some View {
        ZStack {
            BotanicalBackgroundView()
            ScrollView {
                VStack(spacing: 24) {

                    VStack(spacing: 10) {
                        HealthGradeBadgeView(grade: controller.currentHealthGrade(), size: 140)
                        Text(controller.currentHealthGrade().label)
                            .font(Theme.headingFont)
                        Text("\(Int(controller.adherencePercentage()))% overall adherence")
                            .font(Theme.bodyFont)
                            .secondaryTextStyle()
                        Text("🔥 \(controller.currentStreak())-day streak")
                            .font(Theme.captionFont)
                            .secondaryTextStyle()
                    }
                    .frame(maxWidth: .infinity)
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last 7 Days")
                            .font(Theme.headingFont)
                        WeeklyAdherenceChartView(data: controller.weeklyAdherenceData())
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Grade Scale")
                            .font(Theme.headingFont)
                        ForEach(HealthGrade.allCases, id: \.self) { grade in
                            HStack {
                                HealthGradeBadgeView(grade: grade, size: 36)
                                VStack(alignment: .leading) {
                                    Text(grade.label).font(Theme.bodyFont.weight(.semibold))
                                    Text(rangeText(for: grade))
                                        .font(Theme.captionFont)
                                        .secondaryTextStyle()
                                }
                                Spacer()
                            }
                        }
                    }
                    .cardStyle()

                    if !controller.prescriptions.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("By Medicine")
                                .font(Theme.headingFont)
                            ForEach(controller.prescriptions) { prescription in
                                let percent = controller.adherencePercentage(for: prescription)
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(prescription.name).font(Theme.bodyFont)
                                        Spacer()
                                        Text("\(Int(percent))%")
                                            .font(Theme.captionFont)
                                            .secondaryTextStyle()
                                    }
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Theme.sage.opacity(0.4))
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(prescription.colorTag.color)
                                                .frame(width: geo.size.width * CGFloat(percent / 100))
                                        }
                                    }
                                    .frame(height: 10)
                                }
                            }
                        }
                        .cardStyle()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Health Grade")
    }

    private func rangeText(for grade: HealthGrade) -> String {
        switch grade {
        case .a: return "90–100%"
        case .b: return "80–89%"
        case .c: return "70–79%"
        case .d: return "60–69%"
        case .f: return "Below 60%"
        }
    }
}

#Preview {
    NavigationStack {
        HealthGradeView()
            .environmentObject(PrescriptionController())
            .environmentObject(NotificationController())
            .environmentObject(AccessibilitySettings())
    }
}
