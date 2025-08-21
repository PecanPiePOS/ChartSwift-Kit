//
//  Date+Extensions.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import Foundation

extension Date {
    /// Get time interval for different time ranges
    static func timeInterval(for range: TimeRange) -> TimeInterval {
        switch range {
        case .hour: return 3600
        case .sixHours: return 3600 * 6
        case .twelveHours: return 3600 * 12
        case .day: return 3600 * 24
        case .week: return 3600 * 24 * 7
        case .month: return 3600 * 24 * 30
        }
    }
    
    /// Format for chart x-axis based on time range
    func formatForChart(timeRange: TimeRange) -> String {
        let formatter = DateFormatter()
        
        switch timeRange {
        case .hour, .sixHours, .twelveHours:
            formatter.dateFormat = "HH:mm"
        case .day:
            formatter.dateFormat = "HH:mm"
        case .week:
            formatter.dateFormat = "EEE"
        case .month:
            formatter.dateFormat = "MMM d"
        }
        
        return formatter.string(from: self)
    }
}
