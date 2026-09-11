//
//  PrescriptionFormView.swift
//  MedCare
//
//  SCREEN 3 — Shared form used both for adding a brand-new prescription
//  and for editing an existing one, so the two flows can't drift apart.
//

import SwiftUI

struct PrescriptionFormView: View {
    enum Mode {
        case add
        case edit(Prescription)

        var title: String {
            switch self {
            case .add: return "New Prescription"
            case .edit: return "Edit Prescription"
            }
        }
    }

    @EnvironmentObject var controller: PrescriptionController
    @EnvironmentObject var notifier: NotificationController
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    @State private var name = ""
    @State private var dosage = ""
    @State private var instructions = ""
    @State private var colorTag: PrescriptionColor = .leaf
    @State private var reminderTimes: [Date] = [Date()]

    @State private var isTrackingRefills = false
    @State private var pillsRemainingText = ""
    @State private var refillThresholdText = ""

    // Refill Calculator — a small in-form utility (no extra screen) that
    // works out how many pills to buy for a given number of days,
    // based on how many reminder times (doses/day) are set above.
    @State private var calculatorDaysSupply = 30
    @State private var calculatorResultPills = 0
    @State private var isShowingCalculatorAlert = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !dosage.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Medicine Info") {
                    TextField("Name (e.g. Metformin)", text: $name)
                    TextField("Dosage (e.g. 500mg)", text: $dosage)
                    TextField("Instructions (optional)", text: $instructions)
                }

                Section("Color Tag") {
                    Picker("Color", selection: $colorTag) {
                        ForEach(PrescriptionColor.allCases, id: \.self) { tag in
                            HStack {
                                Circle().fill(tag.color).frame(width: 14, height: 14)
                                Text(tag.displayName)
                            }
                            .tag(tag)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Daily Reminder Times") {
                    ForEach(reminderTimes.indices, id: \.self) { index in
                        HStack {
                            DatePicker(
                                "Dose \(index + 1)",
                                selection: $reminderTimes[index],
                                displayedComponents: .hourAndMinute
                            )
                            if reminderTimes.count > 1 {
                                Button(role: .destructive) {
                                    reminderTimes.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Theme.petalPink)
                                }
                            }
                        }
                    }
                    Button {
                        reminderTimes.append(Date())
                    } label: {
                        Label("Add another time", systemImage: "plus.circle")
                    }
                }

                Section {
                    Toggle("Track Pill Count for Refills", isOn: $isTrackingRefills.animation())
                    if isTrackingRefills {
                        TextField("Pills remaining", text: $pillsRemainingText)
                            .keyboardType(.numberPad)
                        TextField("Alert me when this many are left", text: $refillThresholdText)
                            .keyboardType(.numberPad)

                        Stepper(
                            "Refill calculator: \(calculatorDaysSupply) day supply",
                            value: $calculatorDaysSupply,
                            in: 7...90,
                            step: 7
                        )
                        Button {
                            calculateRefill()
                        } label: {
                            Label("Calculate Pills Needed", systemImage: "function")
                        }
                    }
                } header: {
                    Text("Refill Reminders")
                } footer: {
                    Text("When enabled, MedCare will count down each time you mark a dose Taken and send a one-time refill alert once the count drops to your threshold. Use the calculator to work out how many pills to request based on your reminder schedule.")
                }
            }
            .navigationTitle(mode.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: populateIfEditing)
            .alert("Refill Calculator", isPresented: $isShowingCalculatorAlert) {
                Button("Use This Number") {
                    pillsRemainingText = String(calculatorResultPills)
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text(calculatorMessage)
            }
        }
    }

    private var calculatorMessage: String {
        let dosesPerDay = max(reminderTimes.count, 1)
        return "Based on \(dosesPerDay) dose\(dosesPerDay == 1 ? "" : "s") per day, you'll need approximately \(calculatorResultPills) pills to cover a \(calculatorDaysSupply)-day supply."
    }

    /// Processes the user's Stepper input (days supply) together with
    /// however many reminder times they've set, and produces a
    /// meaningful result: how many pills to request for that period.
    /// The result is surfaced via a genuine SwiftUI Alert.
    private func calculateRefill() {
        let dosesPerDay = max(reminderTimes.count, 1)
        calculatorResultPills = dosesPerDay * calculatorDaysSupply
        isShowingCalculatorAlert = true
    }

    private func populateIfEditing() {
        guard case let .edit(prescription) = mode else { return }
        name = prescription.name
        dosage = prescription.dosage
        instructions = prescription.instructions
        colorTag = prescription.colorTag

        let calendar = Calendar.current
        reminderTimes = prescription.reminderTimes.map { calendar.date(from: $0) ?? Date() }
        if reminderTimes.isEmpty { reminderTimes = [Date()] }

        if let remaining = prescription.pillsRemaining, let threshold = prescription.refillThreshold {
            isTrackingRefills = true
            pillsRemainingText = String(remaining)
            refillThresholdText = String(threshold)
        }
    }

    private func save() {
        let calendar = Calendar.current
        let components = reminderTimes.map {
            calendar.dateComponents([.hour, .minute], from: $0)
        }

        let pillsRemaining = isTrackingRefills ? Int(pillsRemainingText) : nil
        let refillThreshold = isTrackingRefills ? Int(refillThresholdText) : nil

        switch mode {
        case .add:
            let prescription = Prescription(
                name: name,
                dosage: dosage,
                instructions: instructions,
                colorTag: colorTag,
                reminderTimes: components,
                pillsRemaining: pillsRemaining,
                refillThreshold: refillThreshold
            )
            controller.addPrescription(prescription, notifier: notifier)

        case .edit(var prescription):
            prescription.name = name
            prescription.dosage = dosage
            prescription.instructions = instructions
            prescription.colorTag = colorTag
            prescription.reminderTimes = components
            prescription.pillsRemaining = pillsRemaining
            prescription.refillThreshold = refillThreshold
            controller.updatePrescription(prescription, notifier: notifier)
        }

        dismiss()
    }
}

#Preview {
    PrescriptionFormView(mode: .add)
        .environmentObject(PrescriptionController())
        .environmentObject(NotificationController())
            .environmentObject(AccessibilitySettings())
}
