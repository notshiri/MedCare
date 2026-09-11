//
//  PersistenceStore.swift
//  MedCare
//
//  Lightweight local persistence using UserDefaults + JSON encoding.
//  Kept separate from PrescriptionController so the controller's
//  business logic isn't tangled up with storage details — swapping
//  this for Core Data or a backend later only touches this file.
//

import Foundation

final class PersistenceStore {
    private let defaults = UserDefaults.standard
    private let prescriptionsKey = "medcare.prescriptions"
    private let doseLogsKey = "medcare.doseLogs"

    func loadPrescriptions() -> [Prescription] {
        guard let data = defaults.data(forKey: prescriptionsKey),
              let decoded = try? JSONDecoder().decode([Prescription].self, from: data)
        else { return [] }
        return decoded
    }

    func savePrescriptions(_ prescriptions: [Prescription]) {
        guard let data = try? JSONEncoder().encode(prescriptions) else { return }
        defaults.set(data, forKey: prescriptionsKey)
    }

    func loadDoseLogs() -> [DoseLog] {
        guard let data = defaults.data(forKey: doseLogsKey),
              let decoded = try? JSONDecoder().decode([DoseLog].self, from: data)
        else { return [] }
        return decoded
    }

    func saveDoseLogs(_ doseLogs: [DoseLog]) {
        guard let data = try? JSONEncoder().encode(doseLogs) else { return }
        defaults.set(data, forKey: doseLogsKey)
    }
}
