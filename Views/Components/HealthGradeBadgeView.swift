//
//  HealthGradeBadgeView.swift
//  MedCare


import SwiftUI

struct HealthGradeBadgeView: View {
    let grade: HealthGrade
    var size: CGFloat = 90

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.color(for: grade).opacity(0.18))
                .frame(width: size, height: size)
            Circle()
                .stroke(Theme.color(for: grade), lineWidth: 4)
                .frame(width: size, height: size)
            Text(grade.rawValue)
                .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
                .foregroundColor(Theme.color(for: grade))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Health grade \(grade.rawValue), \(grade.label)")
    }
}

#Preview {
    HStack(spacing: 16) {
        HealthGradeBadgeView(grade: .a)
        HealthGradeBadgeView(grade: .c)
        HealthGradeBadgeView(grade: .f)
    }
    .padding()
    .background(Theme.cream)
}
