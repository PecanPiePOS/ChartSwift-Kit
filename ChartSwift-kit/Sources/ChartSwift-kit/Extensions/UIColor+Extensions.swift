//
//  UIColor+Extensions.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import UIKit

extension UIColor {
    
    /// Chart color palette
    static let chartColors: [UIColor] = [
        .systemBlue,
        .systemGreen,
        .systemOrange,
        .systemRed,
        .systemPurple,
        .systemTeal,
        .systemIndigo,
        .systemPink,
        .systemYellow,
        .systemBrown
    ]
    
    /// Get color from chart palette by index
    static func chartColor(at index: Int) -> UIColor {
        return chartColors[index % chartColors.count]
    }
}
