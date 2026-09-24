//
//  PrescriptionController.swift
//  MedCare


import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class PrescriptionController: ObservableObject {

    @Published private(set) var prescriptions: [Prescription] = []
    @Published private(set) var doseLogs: [DoseLog] = []

    private let service = FirestoreService()
    private var userId: String?
    private var prescriptionListener: ListenerRegistration?
    private var doseLogListener: ListenerRegistration?

    // MARK: - Session lifecycle
    func startListening(userId: String) {
        guard self.userId != userId else { return }
        stopListening()
        self.userId = userId

        prescriptionListener = service.listenToPrescriptions(userId: userId) { [weak self] items in
            Task { @MainActor in
                self?.prescriptions = items
                self?.generateTodaysDoseLogsIfNeeded()
            }
        }
        doseLogListener = service.listenToDoseLogs(userId: userId) { [weak self] items in
            Task { @MainActor in
                self?.doseLogs = items
            }
        }
    }

    func stopListening() {
        prescriptionListener?.remove()
        doseLogListener?.remove()
        prescriptionListener = nil
        doseLogListener = nil
        userId = nil
        prescriptions = []
        doseLogs = []
    }

    // MARK: - Prescription CRUD

    func addPrescription(_ prescription: Prescription, notifier: NotificationController) {
        guard let userId else { return }
        Task {
            do {
                let saved = try await service.addPrescription(prescription, userId: userId)
                notifier.scheduleReminders(for: saved)
            } catch {
                print("Failed to add prescription: \(error)")
            }
        }
    }

    func updatePrescription(_ prescription: Prescription, notifier: NotificationController) {
        guard let userId else { return }
        Task {
            do {
                try await service.updatePrescription(prescription, userId: userId)
                if let id = prescription.id {
                    notifier.cancelReminders(for: id)
                }
                notifier.scheduleReminders(for: prescription)
            } catch {
                print("Failed to update prescription: \(error)")
            }
        }
    }

    func deletePrescription(_ prescription: Prescription, notifier: NotificationController) {
        guard let userId, let id = prescription.id else { return }
        Task {
            do {
                try await service.deletePrescription(id: id, userId: userId)
                try await service.deleteDoseLogs(prescriptionId: id, userId: userId)
                notifier.cancelReminders(for: id)
            } catch {
                print("Failed to delete prescription: \(error)")
            }
        }
    }

    // MARK: - Dose generation

    func generateTodaysDoseLogsIfNeeded() {
        guard let userId else { return }
        let calendar = Calendar.current
        let today = Date()

        for prescription in prescriptions where prescription.isActive {
            guard let prescriptionId = prescription.id else { continue }
            for comps in prescription.reminderTimes {
                guard let scheduled = calendar.date(
                    bySettingHour: comps.hour ?? 8,
                    minute: comps.minute ?? 0,
                    second: 0,
                    of: today
                ) else { continue }

                let alreadyExists = doseLogs.contains {
                    $0.prescriptionId == prescriptionId &&
                    calendar.isDate($0.scheduledDate, equalTo: scheduled, toGranularity: .minute)
                }
                if !alreadyExists {
                    let newLog = DoseLog(prescriptionId: prescriptionId, scheduledDate: scheduled)
                    Task {
                        try? await service.addDoseLog(newLog, userId: userId)
                    }
                }
            }
        }
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
        guard let userId else { return }
        var updated = doseLog
        updated.status = status
        updated.respondedAt = Date()

        Task {
            do {
                try await service.updateDoseLog(updated, userId: userId)
                if status == .taken {
                    await decrementPillCount(for: doseLog.prescriptionId)
                }
            } catch {
                print("Failed to mark dose: \(error)")
            }
        }
    }

    private func decrementPillCount(for prescriptionId: String) async {
        guard let userId else { return }
        guard let index = prescriptions.firstIndex(where: { $0.id == prescriptionId }) else { return }
        guard let remaining = prescriptions[index].pillsRemaining, remaining > 0 else { return }

        let wasAboveThreshold = !prescriptions[index].isLowOnRefill
        var updated = prescriptions[index]
        updated.pillsRemaining = remaining - 1

        do {
            try await service.updatePrescription(updated, userId: userId)
            if wasAboveThreshold && updated.isLowOnRefill {
                NotificationController.sendRefillAlert(for: updated)
            }
        } catch {
            print("Failed to update pill count: \(error)")
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
}
