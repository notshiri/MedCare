//
//  Prescription.swift
//  MedCare
//
//  MODEL — plain data type describing a medicine the user is tracking.
//  Contains no business logic or UI code (that belongs to the
//  Controller and View layers respectively).
//

import Foundation
import SwiftUI

struct Prescription: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var dosage: String
    var instructions: String
    var colorTag: PrescriptionColor
    var reminderTimes: [DateComponents]
    var isActive: Bool
    var createdAt: Date

    var pillsRemaining: Int?
    var refillThreshold: Int?

    init(
        id: UUID = UUID(),
        name: String,
        dosage: String,
        instructions: String = "",
        colorTag: PrescriptionColor = .leaf,
        reminderTimes: [DateComponents] = [],
        isActive: Bool = true,
        createdAt: Date = Date(),
        pillsRemaining: Int? = nil,
        refillThreshold: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.instructions = instructions
        self.colorTag = colorTag
        self.reminderTimes = reminderTimes
        self.isActive = isActive
        self.createdAt = createdAt
        self.pillsRemaining = pillsRemaining
        self.refillThreshold = refillThreshold
    }

    var formattedTimes: [String] {
        reminderTimes.map { comps in
            let cal = Calendar.current
            let date = cal.date(from: comps) ?? Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }

    var isLowOnRefill: Bool {
        guard let remaining = pillsRemaining, let threshold = refillThreshold else { return false }
        return remaining <= threshold
    }
}

enum PrescriptionColor: String, Codable, CaseIterable {
    case leaf, sun, petal, bark

    var color: Color {
        switch self {
        case .leaf:  return Theme.leafGreen
        case .sun:   return Theme.sunAccent
        case .petal: return Theme.petalPink
        case .bark:  return Theme.bark
        }
    }

    var displayName: String {
        switch self {
        case .leaf:  return "Teal"
        case .sun:   return "Amber"
        case .petal: return "Coral"
        case .bark:  return "Navy"
        }
    }
}
