//
//  ChartableX.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import Foundation

/// A protocol for types that can be represented as a `Double` on the chart's X-axis.
///
/// 차트의 X축에서 `Double` 값으로 표현될 수 있는 모든 타입을 위한 프로토콜입니다.
public protocol ChartableX: Comparable, Sendable {
    /// The `Double` representation of the value.
    ///
    /// 값의 `Double` 표현입니다.
    var doubleValue: Double { get }
    
    /// Initializes a new value from a `Double`.
    ///
    /// `Double` 값으로부터 새로운 인스턴스를 생성합니다.
    init(doubleValue: Double)
}

extension Double: ChartableX {
    public var doubleValue: Double { self }
    public init(doubleValue: Double) { self = doubleValue }
}

extension Date: ChartableX {
    public var doubleValue: Double { self.timeIntervalSince1970 }
    public init(doubleValue: Double) { self.init(timeIntervalSince1970: doubleValue) }
}

extension Int: ChartableX {
    public var doubleValue: Double { Double(self) }
    public init(doubleValue: Double) { self.init(Double(doubleValue)) }
}
