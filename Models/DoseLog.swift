//
//  DoseLog.swift
//  MedCare

import Foundation
import FirebaseFirestore

enum DoseStatus: String, Codable {
    case pending
    case taken
    case missed
}

struct DoseLog: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let prescriptionId: String
    var scheduledDate: Date
    var status: DoseStatus
    var respondedAt: Date?

    init(
        id: String? = nil,
        prescriptionId: String,
        scheduledDate: Date,
        status: DoseStatus = .pending,
        respondedAt: Date? = nil
    ) {
        self.id = id
        self.prescriptionId = prescriptionId
        self.scheduledDate = scheduledDate
        self.status = status
        self.respondedAt = respondedAt
    }
}
