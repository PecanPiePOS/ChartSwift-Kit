//
//  AxisConfiguration.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import UIKit

/// A struct that configures the appearance of the chart's axes.
///
/// 차트 축의 외형을 설정하는 구조체입니다.
public struct AxisConfiguration {
    /// A boolean indicating whether to show axis labels.
    ///
    /// 축 레이블을 표시할지 여부입니다.
    public var showLabels: Bool = true
    /// The font for axis labels.
    ///
    /// 축 레이블의 폰트입니다
    public var labelFont: UIFont = .systemFont(ofSize: 10, weight: .medium)
    /// The color of axis labels.
    ///
    /// 축 레이블의 색상입니다.
    public var labelColor: UIColor = .lightGray
    
    /// Creates a new axis configuration.
    ///
    /// 새로운 축 설정을 생성합니다.
    /// - Parameters:
    ///   - showLabels: A boolean indicating whether to show axis labels. (축 레이블 표시 여부)
    ///   - labelFont: The font for axis labels. (축 레이블 폰트)
    ///   - labelColor: The color of axis labels. (축 레이블 색상)
    public init(showLabels: Bool, labelFont: UIFont, labelColor: UIColor) {
        self.showLabels = showLabels
        self.labelFont = labelFont
        self.labelColor = labelColor
    }
}
