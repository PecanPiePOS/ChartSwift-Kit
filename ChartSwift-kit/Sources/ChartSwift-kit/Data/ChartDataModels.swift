//
//  ChartDataModels.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import UIKit

/// An enum that defines the type of the chart to be drawn.
///
/// 그려질 차트의 종류를 정의하는 열거형입니다.
public enum ChartType {
    case line
    case bar
    case area
    case healthData
}

/// A struct representing a single data point in a chart series.
///
/// 차트 시리즈의 단일 데이터 포인트를 나타내는 구조체입니다.
public struct ChartDataPoint<XValue: ChartableX>: Sendable {
    /// The value on the X-axis.
    ///
    /// X축 값입니다.
    public let x: XValue
    /// The primary value on the Y-axis.
    ///
    /// Y축의 주요 값입니다.
    public let y: Double
    /// The minimum value for ranged data types like health data.
    ///
    /// 헬스 데이터와 같은 범위 데이터 유형의 최소값입니다.
    public let minValue: Double?
    /// The maximum value for ranged data types like health data.
    ///
    /// 헬스 데이터와 같은 범위 데이터 유형의 최대값입니다.
    public let maxValue: Double?
    
    /// Creates a new data point.
    ///
    /// 새로운 데이터 포인트를 생성합니다.
    /// - Parameters:
    ///   - x: The value on the X-axis. (X축 값)
    ///   - y: The primary value on the Y-axis. (Y축의 주요 값)
    ///   - minValue: The minimum value for ranged data types. (범위 데이터의 최소값)
    ///   - maxValue: The maximum value for ranged data types. (범위 데이터의 최대값)
    public init(x: XValue, y: Double, minValue: Double? = nil, maxValue: Double? = nil) {
        self.x = x
        self.y = y
        self.minValue = minValue
        self.maxValue = maxValue
    }
}

/// A class that represents a series of data points, forming a single line, bar set, or area on the chart.
///
/// 차트에서 하나의 선, 막대 그룹, 또는 영역을 형성하는 데이터 포인트의 집합을 나타내는 클래스입니다.
public class ChartDataSeries<XValue: ChartableX>: @unchecked Sendable {
    /// The unique identifier for the series.
    ///
    /// 시리즈의 고유 식별자입니다.
    public let id: String
    /// The name of the series, which can be used for legends.
    ///
    /// 범례 등에 사용될 수 있는 시리즈의 이름입니다.
    public let name: String
    /// An array of `ChartDataPoint` objects that make up the series.
    ///
    /// 시리즈를 구성하는 `ChartDataPoint` 객체의 배열입니다.
    public var points: [ChartDataPoint<XValue>]
    /// The color used to draw the series.
    ///
    /// 시리즈를 그리는 데 사용되는 색상입니다.
    public let color: UIColor
    /// The width of the line or bars in the series.
    ///
    /// 시리즈의 선 또는 막대의 너비입니다.
    public let lineWidth: CGFloat
    
    /// Creates a new data series.
    ///
    /// 새로운 데이터 시리즈를 생성합니다.
    /// - Parameters:
    ///   - id: The unique identifier for the series. (시리즈의 고유 식별자)
    ///   - name: The name of the series. (시리즈의 이름)
    ///   - points: An array of `ChartDataPoint` objects. (시리즈를 구성하는 `ChartDataPoint` 객체의 배열)
    ///   - color: The color used to draw the series. (시리즈를 그리는 데 사용되는 색상)
    ///   - lineWidth: The width of the line or bars in the series. (시리즈의 선 또는 막대의 너비)
    
    public init(id: String, name: String, points: [ChartDataPoint<XValue>], color: UIColor, lineWidth: CGFloat = 2.0) {
        self.id = id
        self.name = name
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }
}
