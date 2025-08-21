//
//  ChartDataProcessor.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import UIKit
import QuartzCore

// A container for internal data processing algorithms.
// This struct is not exposed to the user of the framework.
//
// 내부 데이터 처리 알고리즘을 담는 컨테이너입니다.
// 이 구조체는 프레임워크 사용자에게 노출되지 않습니다.
internal struct ChartDataProcessor {
    
    /// Downsamples a series of data points using the Largest-Triangle-Three-Buckets (LTTB) algorithm.
    /// This is crucial for maintaining performance with large datasets by selecting visually important points.
    ///
    /// LTTB(Largest-Triangle-Three-Buckets) 알고리즘을 사용하여 데이터 포인트 시리즈를 다운샘플링합니다.
    /// 대용량 데이터셋에서 시각적으로 중요한 포인트를 선택하여 성능을 유지하는 데 중요합니다.
    /// - Parameters:
    ///   - points: The original array of `ChartDataPoint` to be simplified. (단순화할 원본 `ChartDataPoint` 배열)
    ///   - threshold: The desired number of data points to return. (반환하고자 하는 데이터 포인트의 수)
    /// - Returns: A new array of `ChartDataPoint` with a count approximately equal to the threshold. (threshold와 거의 동일한 개수를 가진 새로운 `ChartDataPoint` 배열)
    static func simplifyLTTB<XValue: ChartableX>(
        points: [ChartDataPoint<XValue>],
        threshold: Int
    ) -> [ChartDataPoint<XValue>] {
        // 전체 조건확인: 원본 데이터가 threshold 보다 작거나, 2 이하이면 최적화 필요 없음
        guard points.count > threshold,
              threshold > 2
        else { return points }
        
        // 최종적으로 반환할 단순화된 데이터
        var simplified: [ChartDataPoint<XValue>] = []
        // 최적화를 위해 미리 메모리 할당
        simplified.reserveCapacity(threshold)
        
        // 버킷 크기 계산
        // 첫 번째와 마지막 포인트는 항상 포함되므로, 나머지 (n-2)개의 포인트를 (k-2) 개의 버킷으로 나눔
        let bucketSize = Double(points.count - 2) / Double(threshold - 2)
        
        // 최적화 시작
        // 'a' 는 최적화 배열에 마지막으로 추가된 포인트의 인덱스임
        var a = 0
        simplified.append(points[a])
        
        for i in 0..<(threshold - 2) {
            // 현재 버킷의 데이터 범위 계산
            let startIndex = Int(floor(Double(i + 1) * bucketSize)) + 1
            let endIndex = min(Int(floor(Double(i + 2) * bucketSize)) + 1, points.count)
            
            guard startIndex < endIndex else { continue }
            let range = startIndex..<endIndex
            
            // 다음 버킷의 평균 포인트 계산
            // 평균 포인트를 통해 가장 큰 삼각형을 찾는데 사용될 세번째 꼭지점이 됨
            var pointAvgX: Double = 0
            var pointAvgY: Double = 0
            for i in range {
                pointAvgX += points[i].x.doubleValue
                pointAvgY += points[i].y
            }
            pointAvgX /= Double(range.count)
            pointAvgY /= Double(range.count)
            
            // 현재 버킷 내에서 가장 큰 삼각형을 만드는 포인트 찾기
            // 삼각형의 첫번째 꼭지점(이전에 선택된 포인트입니다.)
            let pA = points[a]
            
            var maxArea: Double = -1.0
            // 가장 큰 면적을 가진 포인트의 인덱스를 저장할 변수
            var nextPointIndex = startIndex
            
            // 현재 버킷 내의 모든 포인트를 순회
            for j in range {
                // 다음 꼭지점
                let pB = points[j]
                // 삼각형 면적 검사
                // shoelace formula: Area = 0.5*|(x1-x3)(y2-y1) - (x1-x2)(y3-y1)|
                let area = abs((pA.x.doubleValue - pointAvgX) * (pB.y - pA.y) - (pA.x.doubleValue - pB.x.doubleValue) * (pointAvgY - pA.y)) * 0.5
                if area > maxArea {
                    maxArea = area
                    nextPointIndex = j
                }
            }
            // 가장 큰 삼각형을 만든 포인트를 최종 데이터에 추가
            simplified.append(points[nextPointIndex])
            // a 인덱스를 추가한 포인트의 인덱스로 새롭게 업데이트
            a = nextPointIndex
        }
        
        // 마지막 포인트는 항상 결과에 포함
        simplified.append(points.last!)
        return simplified
    }
}
