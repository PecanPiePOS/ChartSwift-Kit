//
//  HealthData.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import UIKit

public enum HealthDataType {
    case heartRate
    
    public var displayName: String { "Heart Rate" }
    public var unit: String { "BPM" }
    public var color: UIColor { .systemPink }
    public var normalRange: (min: Double, max: Double) { (50, 190) }
    public var seriesId: String { "heartRate" }
}

public enum HealthTimePeriod {
    case month
    case week
    case day
    
    public var displayName: String {
        switch self {
        case .month: return "M"
        case .week: return "W"
        case .day: return "D"
        }
    }
    
    public var dataPoints: Int {
        switch self {
        case .month: return 30
        case .week: return 168
        case .day: return 24
        }
    }
    
    public var secondsPerPoint: Double {
        switch self {
        case .month: return 86400
        case .week: return 3600
        case .day: return 3600
        }
    }
}
