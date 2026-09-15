//
//  WeeklyAdherenceChartView.swift
//  MedCare

import SwiftUI
import Charts

struct WeeklyAdherenceChartView: View {
    let data: [(date: Date, percentage: Double?)]

    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { _, entry in
                BarMark(
                    x: .value("Day", weekdayFormatter.string(from: entry.date)),
                    y: .value("Adherence", entry.percentage ?? 0)
                )
                .foregroundStyle(barColor(for: entry.percentage))
                .cornerRadius(6)
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 50, 100]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)%")
                    }
                }
            }
        }
        .frame(height: 160)
    }

    private func barColor(for percentage: Double?) -> Color {
        guard let percentage else { return Theme.sage.opacity(0.3) }
        return Theme.color(for: HealthGrade.from(percentage: percentage))
    }
}

#Preview {
    let sampleData: [(date: Date, percentage: Double?)] = (0..<7).map { offset in
        let day = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
        return (day, Double.random(in: 40...100))
    }.reversed()

    return WeeklyAdherenceChartView(data: sampleData)
        .padding()
        .background(Theme.cream)
}
