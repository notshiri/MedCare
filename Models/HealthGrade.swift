//
//  HealthGrade.swift
//  MedCare
//
//  MODEL — represents the app's signature A–F adherence grade.
//  Pure data + a pure mapping function; no business logic that
//  touches live app state (that lives in PrescriptionController).
//

import Foundation

enum HealthGrade: String, CaseIterable {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case f = "F"

    var label: String {
        switch self {
        case .a: return "Excellent"
        case .b: return "Good"
        case .c: return "Fair"
        case .d: return "Needs Attention"
        case .f: return "At Risk"
        }
    }

    /// Maps an adherence percentage (0...100) to a letter grade.
    static func from(percentage: Double) -> HealthGrade {
        switch percentage {
        case 90...100: return .a
        case 80..<90:  return .b
        case 70..<80:  return .c
        case 60..<70:  return .d
        default:       return .f
        }
    }
}
