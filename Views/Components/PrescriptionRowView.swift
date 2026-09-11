//
//  PrescriptionRowView.swift
//  MedCare
//
//  Reusable row used in PrescriptionListView.
//

import SwiftUI

struct PrescriptionRowView: View {
    let prescription: Prescription

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(prescription.colorTag.color.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: "pills.fill")
                    .foregroundColor(prescription.colorTag.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(prescription.name)
                    .font(Theme.bodyFont.weight(.semibold))
                Text(prescription.dosage)
                    .font(Theme.captionFont)
                    .secondaryTextStyle()
                if !prescription.formattedTimes.isEmpty {
                    Text(prescription.formattedTimes.joined(separator: ", "))
                        .font(Theme.captionFont)
                        .secondaryTextStyle()
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                if !prescription.isActive {
                    Text("Paused")
                        .font(Theme.captionFont)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                }
                if prescription.isLowOnRefill {
                    Label("Refill", systemImage: "exclamationmark.triangle.fill")
                        .font(Theme.captionFont)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.sunAccent.opacity(0.2))
                        .foregroundColor(Theme.bark)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var parts = ["\(prescription.name), \(prescription.dosage)"]
        if !prescription.formattedTimes.isEmpty {
            parts.append("reminders at \(prescription.formattedTimes.joined(separator: ", "))")
        }
        if !prescription.isActive { parts.append("paused") }
        if prescription.isLowOnRefill { parts.append("running low, refill soon") }
        return parts.joined(separator: ". ")
    }
}
