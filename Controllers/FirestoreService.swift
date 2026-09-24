//
//  FirestoreService.swift
//  MedCare


import Foundation
import Combine
import FirebaseFirestore

final class FirestoreService {
    private let db = Firestore.firestore()

    private func prescriptionsCollection(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("prescriptions")
    }

    private func doseLogsCollection(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("doseLogs")
    }

    // MARK: - Live listeners (used by PrescriptionController)

    func listenToPrescriptions(
        userId: String,
        onChange: @escaping ([Prescription]) -> Void
    ) -> ListenerRegistration {
        prescriptionsCollection(for: userId).addSnapshotListener { snapshot, _ in
            let items = snapshot?.documents.compactMap { try? $0.data(as: Prescription.self) } ?? []
            onChange(items)
        }
    }

    func listenToDoseLogs(
        userId: String,
        onChange: @escaping ([DoseLog]) -> Void
    ) -> ListenerRegistration {
        doseLogsCollection(for: userId).addSnapshotListener { snapshot, _ in
            let items = snapshot?.documents.compactMap { try? $0.data(as: DoseLog.self) } ?? []
            onChange(items)
        }
    }

    // MARK: - Prescriptions

    /// Adds a new prescription and returns it with its assigned Firestore id.
    func addPrescription(_ prescription: Prescription, userId: String) async throws -> Prescription {
        let ref = prescriptionsCollection(for: userId).document()
        var saved = prescription
        saved.id = ref.documentID
        try ref.setData(from: saved)
        return saved
    }

    func updatePrescription(_ prescription: Prescription, userId: String) async throws {
        guard let id = prescription.id else { return }
        try prescriptionsCollection(for: userId).document(id).setData(from: prescription, merge: true)
    }

    func deletePrescription(id: String, userId: String) async throws {
        try await prescriptionsCollection(for: userId).document(id).delete()
    }

    // MARK: - Dose logs

    func addDoseLog(_ doseLog: DoseLog, userId: String) async throws {
        let ref = doseLogsCollection(for: userId).document()
        var saved = doseLog
        saved.id = ref.documentID
        try ref.setData(from: saved)
    }

    func updateDoseLog(_ doseLog: DoseLog, userId: String) async throws {
        guard let id = doseLog.id else { return }
        try doseLogsCollection(for: userId).document(id).setData(from: doseLog, merge: true)
    }

    func deleteDoseLogs(prescriptionId: String, userId: String) async throws {
        let snapshot = try await doseLogsCollection(for: userId)
            .whereField("prescriptionId", isEqualTo: prescriptionId)
            .getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}
