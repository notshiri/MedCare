//
//  DoseLog.swift
//  MedCare
//
//  MODEL — records a single scheduled dose for a prescription and
//  whether the user took it, missed it, or hasn't responded yet.
//

import Foundation

enum DoseStatus: String, Codable {
    case pending
    case taken
    case missed
}

struct DoseLog: Identifiable, Codable, Equatable {
    let id: UUID
    let prescriptionId: UUID
    var scheduledDate: Date   
    var status: DoseStatus
    var respondedAt: Date?

    init(
        id: UUID = UUID(),
        prescriptionId: UUID,
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
