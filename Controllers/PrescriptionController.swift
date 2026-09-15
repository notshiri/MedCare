//
//  PrescriptionController.swift
//  MedCare

import Foundation
import Combine

@MainActor
final class PrescriptionController: ObservableObject {

    @Published private(set) var prescriptions: [Prescription] = []
    @Published private(set) var doseLogs: [DoseLog] = []

    private let store = PersistenceStore()

    init() {
        prescriptions = store.loadPrescriptions()
        doseLogs = store.loadDoseLogs()
        generateTodaysDoseLogsIfNeeded()
    }

    // MARK: - Prescription CRUD
    func addPrescription(_ prescription: Prescription, notifier: NotificationController) {
        prescriptions.append(prescription)
        persistPrescriptions()
        generateTodaysDoseLogsIfNeeded()
        notifier.scheduleReminders(for: prescription)
    }

    func updatePrescription(_ prescription: Prescription, notifier: NotificationController) {
        guard let index = prescriptions.firstIndex(where: { $0.id == prescription.id }) else { return }
        prescriptions[index] = prescription
        persistPrescriptions()
        notifier.cancelReminders(for: prescription.id)
        notifier.scheduleReminders(for: prescription)
    }

    func deletePrescription(_ prescription: Prescription, notifier: NotificationController) {
        prescriptions.removeAll { $0.id == prescription.id }
        doseLogs.removeAll { $0.prescriptionId == prescription.id }
        persistPrescriptions()
        persistDoseLogs()
        notifier.cancelReminders(for: prescription.id)
    }

    // MARK: - Dose generation

    func generateTodaysDoseLogsIfNeeded() {
        let calendar = Calendar.current
        let today = Date()

        for prescription in prescriptions where prescription.isActive {
            for comps in prescription.reminderTimes {
                guard let scheduled = calendar.date(
                    bySettingHour: comps.hour ?? 8,
                    minute: comps.minute ?? 0,
                    second: 0,
                    of: today
                ) else { continue }

                let alreadyExists = doseLogs.contains {
                    $0.prescriptionId == prescription.id &&
                    calendar.isDate($0.scheduledDate, equalTo: scheduled, toGranularity: .minute)
                }
                if !alreadyExists {
                    doseLogs.append(DoseLog(prescriptionId: prescription.id, scheduledDate: scheduled))
                }
            }
        }
        persistDoseLogs()
    }

    func todaysDoses() -> [DoseLog] {
        let calendar = Calendar.current
        return doseLogs
            .filter { calendar.isDateInToday($0.scheduledDate) }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    func prescription(for doseLog: DoseLog) -> Prescription? {
        prescriptions.first { $0.id == doseLog.prescriptionId }
    }

    func doseLogs(for prescription: Prescription) -> [DoseLog] {
        doseLogs
            .filter { $0.prescriptionId == prescription.id }
            .sorted { $0.scheduledDate > $1.scheduledDate }
    }

    // MARK: - Marking doses
    func markDose(_ doseLog: DoseLog, as status: DoseStatus) {
        guard let index = doseLogs.firstIndex(where: { $0.id == doseLog.id }) else { return }
        doseLogs[index].status = status
        doseLogs[index].respondedAt = Date()
        persistDoseLogs()

        if status == .taken {
            decrementPillCount(for: doseLog.prescriptionId)
        }
    }

    private func decrementPillCount(for prescriptionId: UUID) {
        guard let index = prescriptions.firstIndex(where: { $0.id == prescriptionId }) else { return }
        guard let remaining = prescriptions[index].pillsRemaining, remaining > 0 else { return }

        let wasAboveThreshold = !prescriptions[index].isLowOnRefill
        prescriptions[index].pillsRemaining = remaining - 1
        persistPrescriptions()

        if wasAboveThreshold && prescriptions[index].isLowOnRefill {
            NotificationController.sendRefillAlert(for: prescriptions[index])
        }
    }

    func lowRefillPrescriptions() -> [Prescription] {
        prescriptions.filter { $0.isLowOnRefill }
    }

    // MARK: - Health Grade / Adherence
    func adherencePercentage() -> Double {
        let responded = doseLogs.filter { $0.status != .pending }
        guard !responded.isEmpty else { return 100 } // no history yet -> benefit of the doubt
        let takenCount = responded.filter { $0.status == .taken }.count
        return (Double(takenCount) / Double(responded.count)) * 100
    }

    func currentHealthGrade() -> HealthGrade {
        HealthGrade.from(percentage: adherencePercentage())
    }

    func adherencePercentage(for prescription: Prescription) -> Double {
        let responded = doseLogs(for: prescription).filter { $0.status != .pending }
        guard !responded.isEmpty else { return 100 }
        let takenCount = responded.filter { $0.status == .taken }.count
        return (Double(takenCount) / Double(responded.count)) * 100
    }

    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var day = calendar.startOfDay(for: Date())

        while true {
            let dosesForDay = doseLogs.filter { calendar.isDate($0.scheduledDate, inSameDayAs: day) }
            guard !dosesForDay.isEmpty else { break }
            let allTaken = dosesForDay.allSatisfy { $0.status == .taken }
            if allTaken {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
                day = previous
            } else {
                break
            }
        }
        return streak
    }

    func weeklyAdherenceData() -> [(date: Date, percentage: Double?)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let dosesForDay = doseLogs.filter {
                calendar.isDate($0.scheduledDate, inSameDayAs: day) && $0.status != .pending
            }
            guard !dosesForDay.isEmpty else { return (day, nil) }
            let taken = dosesForDay.filter { $0.status == .taken }.count
            let percentage = (Double(taken) / Double(dosesForDay.count)) * 100
            return (day, percentage)
        }
    }

    // MARK: - Persistence helpers
    private func persistPrescriptions() {
        store.savePrescriptions(prescriptions)
    }

    private func persistDoseLogs() {
        store.saveDoseLogs(doseLogs)
    }
}
