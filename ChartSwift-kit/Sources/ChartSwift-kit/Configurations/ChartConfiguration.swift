//
//  ChartConfiguration.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import UIKit

/// A struct that configures the visual appearance and behavior of the chart.
///
/// 차트의 시각적 외형과 동작을 설정하는 구조체입니다.
public struct ChartConfiguration {
    /// The type of the chart.
    ///
    /// 차트의 종류입니다.
    public var type: ChartType
    /// The background color of the chart view.
    ///
    /// 차트 뷰의 배경색입니다.
    public var backgroundColor: UIColor
    /// The color of the grid lines.
    ///
    /// 그리드 라인의 색상입니다.
    public var gridColor: UIColor
    /// A boolean indicating whether animations are enabled.
    ///
    /// 애니메이션 활성화 여부입니다.
    public var animationEnabled: Bool
    /// The duration of animations.
    ///
    /// 애니메이션 지속 시간입니다.
    public var animationDuration: TimeInterval
    
    /// Creates a new chart configuration.
    ///
    /// 새로운 차트 설정을 생성합니다.
    /// - Parameters:
    ///   - type: The type of the chart. (차트의 종류)
    ///   - backgroundColor: The background color of the chart view. (차트 뷰의 배경색)
    ///   - gridColor: The color of the grid lines. (그리드 라인의 색상)
    ///   - animationEnabled: A boolean indicating whether animations are enabled. (애니메이션 활성화 여부)
    ///   - animationDuration: The duration of animations. (애니메이션 지속 시간)
    public init(
        type: ChartType = .healthData,
        backgroundColor: UIColor = .black,
        gridColor: UIColor = .darkGray,
        animationEnabled: Bool = true,
        animationDuration: TimeInterval = 0.1
    ) {
        self.type = type
        self.backgroundColor = backgroundColor
        self.gridColor = gridColor
        self.animationEnabled = animationEnabled
        self.animationDuration = animationDuration
    }
}


