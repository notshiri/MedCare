//
//  DoseRowView.swift
//  MedCare
//
//  Reusable row shown in the Dashboard's "Today" list — displays one
//  scheduled dose and lets the user mark it Taken or Missed.
//
//  Laid out with senior/low-vision users in mind: large labeled
//  buttons (not tiny icon-only taps), haptic confirmation, and full
//  VoiceOver labels that read as one clear sentence.
//

import SwiftUI

struct DoseRowView: View {
    @EnvironmentObject var accessibility: AccessibilitySettings

    let prescription: Prescription
    let doseLog: DoseLog
    let onMark: (DoseStatus) -> Void

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: doseLog.scheduledDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Circle()
                    .fill(prescription.colorTag.color)
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(prescription.name)
                        .font(Theme.bodyFont.weight(.bold))
                    Text("\(prescription.dosage) • \(timeString)")
                        .font(Theme.captionFont)
                        .secondaryTextStyle()
                }

                Spacer()

                if doseLog.status != .pending {
                    statusBadge
                }
            }

            if doseLog.status == .pending {
                HStack(spacing: 12) {
                    actionButton(title: "Missed", systemImage: "xmark.circle.fill", tint: Theme.petalPink) {
                        mark(.missed)
                    }
                    actionButton(title: "Taken", systemImage: "checkmark.circle.fill", tint: Theme.leafGreen) {
                        mark(.taken)
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch doseLog.status {
        case .taken:
            Label("Taken", systemImage: "checkmark.circle.fill")
                .font(Theme.captionFont.weight(.semibold))
                .foregroundColor(Theme.leafGreen)
        case .missed:
            Label("Missed", systemImage: "xmark.circle.fill")
                .font(Theme.captionFont.weight(.semibold))
                .foregroundColor(Theme.petalPink)
        case .pending:
            EmptyView()
        }
    }

    /// A large, clearly-labeled pill button — at least 44pt tall, with
    /// both an icon and text so it's never ambiguous what tapping it does.
    private func actionButton(
        title: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(Theme.bodyFont.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: Theme.minTapTarget)
                .background(tint.opacity(accessibility.isHighContrastMode ? 0.25 : 0.15))
                .foregroundColor(accessibility.isHighContrastMode ? .black : tint)
                .overlay(
                    Capsule().stroke(tint, lineWidth: accessibility.isHighContrastMode ? 2 : 0)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Mark \(prescription.name) as \(title)")
        .accessibilityAddTraits(.isButton)
    }

    private func mark(_ status: DoseStatus) {
        accessibility.confirmationHaptic()
        onMark(status)
    }

    private var accessibilityDescription: String {
        let base = "\(prescription.name), \(prescription.dosage), scheduled \(timeString)"
        switch doseLog.status {
        case .pending: return "\(base). Not yet responded."
        case .taken: return "\(base). Marked taken."
        case .missed: return "\(base). Marked missed."
        }
    }
}
