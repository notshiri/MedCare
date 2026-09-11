//
//  PrescriptionDetailView.swift
//  MedCare
//
//  SCREEN 4 — Detail view for a single prescription: shows its info,
//  its personal adherence percentage, refill status, dose history, and
//  lets the user edit, pause, or delete it.
//

import SwiftUI

struct PrescriptionDetailView: View {
    @EnvironmentObject var controller: PrescriptionController
    @EnvironmentObject var notifier: NotificationController
    @Environment(\.dismiss) private var dismiss

    let prescription: Prescription
    @State private var isShowingDeleteConfirm = false
    @State private var isShowingEditSheet = false

    /// Always reads the freshest copy from the controller (so edits made
    /// via the Edit sheet show up immediately) but falls back to the
    /// value passed in if it's somehow been deleted mid-view.
    private var current: Prescription {
        controller.prescriptions.first(where: { $0.id == prescription.id }) ?? prescription
    }

    private var history: [DoseLog] {
        controller.doseLogs(for: current)
    }

    var body: some View {
        ZStack {
            BotanicalBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(current.colorTag.color.opacity(0.18))
                                .frame(width: 60, height: 60)
                            Image(systemName: "pills.fill")
                                .font(.title2)
                                .foregroundColor(current.colorTag.color)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(current.name).font(Theme.headingFont)
                            Text(current.dosage).font(Theme.bodyFont).secondaryTextStyle()
                            if !current.instructions.isEmpty {
                                Text(current.instructions)
                                    .font(Theme.captionFont)
                                    .secondaryTextStyle()
                            }
                        }
                        Spacer()
                    }
                    .cardStyle()

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Adherence for this medicine")
                                .font(Theme.captionFont)
                                .secondaryTextStyle()
                            Text("\(Int(controller.adherencePercentage(for: current)))%")
                                .font(Theme.titleFont)
                        }
                        Spacer()
                        HealthGradeBadgeView(
                            grade: HealthGrade.from(percentage: controller.adherencePercentage(for: current)),
                            size: 60
                        )
                    }
                    .cardStyle()

                    if let remaining = current.pillsRemaining, let threshold = current.refillThreshold {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Refill Tracking").font(Theme.headingFont)
                                Text("\(remaining) pills remaining")
                                    .font(Theme.bodyFont)
                                    .secondaryTextStyle()
                                Text("Alert at \(threshold) pills")
                                    .font(Theme.captionFont)
                                    .secondaryTextStyle()
                            }
                            Spacer()
                            if current.isLowOnRefill {
                                Label("Refill Soon", systemImage: "exclamationmark.triangle.fill")
                                    .font(Theme.captionFont)
                                    .foregroundColor(Theme.bark)
                            }
                        }
                        .cardStyle()
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reminder Times").font(Theme.headingFont)
                        if current.formattedTimes.isEmpty {
                            Text("No reminders set").secondaryTextStyle()
                        } else {
                            ForEach(current.formattedTimes, id: \.self) { time in
                                Label(time, systemImage: "bell.fill")
                                    .font(Theme.bodyFont)
                            }
                        }
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Dose History").font(Theme.headingFont)
                        if history.isEmpty {
                            Text("No doses logged yet.").secondaryTextStyle()
                        } else {
                            ForEach(history.prefix(20)) { log in
                                HStack {
                                    Text(log.scheduledDate, style: .date)
                                        .font(Theme.captionFont)
                                    Text(log.scheduledDate, style: .time)
                                        .font(Theme.captionFont)
                                        .secondaryTextStyle()
                                    Spacer()
                                    statusLabel(for: log.status)
                                }
                            }
                        }
                    }
                    .cardStyle()

                    Button(role: .destructive) {
                        isShowingDeleteConfirm = true
                    } label: {
                        Text("Delete Prescription")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(Theme.petalPink)
                }
                .padding()
            }
        }
        .navigationTitle(current.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { isShowingEditSheet = true }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            PrescriptionFormView(mode: .edit(current))
        }
        .confirmationDialog(
            "Delete \(current.name)?",
            isPresented: $isShowingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                controller.deletePrescription(current, notifier: notifier)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func statusLabel(for status: DoseStatus) -> some View {
        switch status {
        case .taken:
            Label("Taken", systemImage: "checkmark.circle.fill").foregroundColor(Theme.leafGreen)
        case .missed:
            Label("Missed", systemImage: "xmark.circle.fill").foregroundColor(Theme.petalPink)
        case .pending:
            Label("Pending", systemImage: "clock").secondaryTextStyle()
        }
    }
}

#Preview {
    NavigationStack {
        PrescriptionDetailView(prescription: Prescription(name: "Metformin", dosage: "500mg"))
            .environmentObject(PrescriptionController())
            .environmentObject(NotificationController())
            .environmentObject(AccessibilitySettings())
    }
}
