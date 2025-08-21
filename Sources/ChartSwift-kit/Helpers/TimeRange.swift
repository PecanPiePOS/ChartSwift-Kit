//
//  TimeRange.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import Foundation

public enum TimeRange: CaseIterable {
    case hour
    case sixHours
    case twelveHours
    case day
    case week
    case month
    
    public var displayName: String {
        switch self {
        case .hour: return "1H"
        case .sixHours: return "6H"
        case .twelveHours: return "12H"
        case .day: return "1D"
        case .week: return "1W"
        case .month: return "1M"
        }
    }
}
