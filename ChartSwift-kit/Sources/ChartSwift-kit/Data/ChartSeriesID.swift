//
//  ChartSeriesID.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import Foundation

/// A type-safe wrapper for a chart series identifier.
///
/// 차트 시리즈 식별자를 위한 타입-세이프 래퍼입니다.
public struct SeriesID: RawRepresentable, Hashable, Sendable {
    /// The raw string value of the identifier.
    ///
    /// 식별자의 원시 문자열 값입니다.
    public let rawValue: String
    
    /// Creates a new series ID with a raw string value.
    ///
    /// 원시 문자열 값으로 새로운 시리즈 ID를 생성합니다.
    /// - Parameter rawValue: The string value of the ID. (ID의 문자열 값)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension SeriesID {
    static let heartRate = SeriesID(rawValue: "heartRate")
    static let stockPrice = SeriesID(rawValue: "stockPrice")
    static let volume = SeriesID(rawValue: "volume")
}
