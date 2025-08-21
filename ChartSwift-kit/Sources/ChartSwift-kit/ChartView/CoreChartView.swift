//
//  CoreChartView.swift
//  ChartSwift-kit
//
//  Created by KYUBO A. SHIM on 8/20/25.
//

import UIKit

/// Defines the data loading method.
///
/// 데이터 로딩 방식을 정의합니다.
public enum DataLoadingMethod {
    /// The delegate is called automatically when the chart reaches the end of the scroll.
    ///
    /// 차트가 스크롤 끝에 도달하면 자동으로 Delegate를 호출합니다.
    case automatic(thresholdPercentage: Double)
}

/// A delegate protocol for receiving data request events from CoreChartView.
///
/// CoreChartView의 데이터 요청 이벤트를 수신하는 Delegate 프로토콜입니다.
@MainActor
public protocol CoreChartViewDelegate<XValue>: AnyObject {
    associatedtype XValue: ChartableX
    /// Called when the chart requests past data.
    ///
    /// 차트가 과거 데이터를 요청할 때 호출됩니다.
    func chartViewDidRequestPastData(_ chartView: CoreChartView<XValue>)
    /// Called when the chart requests future data.
    ///
    /// 차트가 미래 데이터를 요청할 때 호출됩니다.
    func chartViewDidRequestFutureData(_ chartView: CoreChartView<XValue>)
}

public extension CoreChartViewDelegate {
    func chartViewDidRequestPastData<XValue: ChartableX>(_ chartView: CoreChartView<XValue>) {}
    func chartViewDidRequestFutureData<XValue: ChartableX>(_ chartView: CoreChartView<XValue>) {}
}

@MainActor
private class DisplayLinkProxy<XValue: ChartableX> {
    weak var target: CoreChartView<XValue>?
    
    init(target: CoreChartView<XValue>) {
        self.target = target
    }
    
    @objc func displayLinkTick() {
        target?.displayLinkTick()
    }
}

/// A high-performance, interactive chart view designed to handle large datasets smoothly.
///
/// 대용량 데이터도 부드럽게 처리할 수 있는 고성능의 인터랙티브 차트 뷰입니다.
@MainActor
public class CoreChartView<XValue: ChartableX>: UIView {
    
    // MARK: - Public Properties
    
    /// The configuration that determines the appearance and behavior of the chart.
    ///
    /// 차트의 모양과 동작을 결정하는 설정값입니다.
    public private(set) var configuration: ChartConfiguration = ChartConfiguration()
    /// An array of data series displayed on the chart.
    ///
    /// 차트에 표시되는 데이터 계열(Series)의 배열입니다.
    public private(set) var dataSeries: [ChartDataSeries<XValue>] = []
    /// Indicates whether the chart is in real-time mode.
    ///
    /// 차트가 실시간 모드인지 여부를 나타냅니다.
    public private(set) var isRealTimeMode: Bool = false
    /// The delegate that receives data loading events from the chart.
    ///
    /// 차트의 데이터 로딩 관련 이벤트를 수신하는 Delegate입니다.
    public weak var delegate: (any CoreChartViewDelegate)?
    /// Determines if past data can be loaded from the left edge of the chart.
    ///
    /// 차트 좌측 끝에서 과거 데이터를 로드할 수 있는지 여부를 설정합니다.
    public var canLoadPastData: Bool = false
    /// Determines if future data can be loaded from the right edge of the chart.
    ///
    /// 차트 우측 끝에서 미래 데이터를 로드할 수 있는지 여부를 설정합니다.
    public var canLoadFutureData: Bool = false
    
    // MARK: - Private State
    private let chartLayer = CALayer()
    private let gridLayer = CALayer()
    private let axisLayer = CALayer()
    private var barLayers: [CALayer] = []
    private var isInitialZoomSet = false
    private var contentOffset: CGPoint = .zero
    private var zoomScale: CGFloat = 1.0
    private var displayLink: CADisplayLink?
    private var displayLinkProxy: DisplayLinkProxy<XValue>?
    private var isUpdateScheduled = false
    private var chartBounds: CGRect = .zero
    private var dataRange: (xMin: XValue, xMax: XValue, yMin: Double, yMax: Double)?
    private var dataLoadingMethod: DataLoadingMethod = .automatic(thresholdPercentage: 0.4)
    private var isLayoutInitialized = false
    private var isAutoScrolling: Bool = true
    private var scrollVelocity: CGFloat = 0.0
    private var isDecelerating: Bool = false
    private let decelerationRate: CGFloat = 0.92
    private var savedContentOffset: CGPoint = .zero
    private var savedZoomScale: CGFloat = 1.0
    private var savedDataRange: (xMin: XValue, xMax: XValue, yMin: Double, yMax: Double)?
    private var minZoomScale: CGFloat = 1.0
    private var maxZoomScale: CGFloat = 15.0
    
    // MARK: 청크 렌더링 시스템을 위한 프로퍼티
    private let chunkSize: Int = 1024
    private var simplifiedChunkCache: [Int: [ChartDataPoint<XValue>]] = [:]
    private var visiblePathLayers: [Int: CAShapeLayer] = [:]
    private var isLoadingPastData: Bool = false
    private var isLoadingFutureData: Bool = false
    
    // MARK: - Initialization
    public init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = configuration.backgroundColor
        chartLayer.masksToBounds = true
        layer.addSublayer(chartLayer)
        chartLayer.addSublayer(gridLayer)
        layer.addSublayer(axisLayer)
        setupGestures()
    }
    
    // MARK: - Public Methods
    
    /// Sets the chart's data and type at once and completely refreshes the view.
    ///
    /// 차트의 데이터와 타입을 한 번에 설정하고 뷰를 완벽하게 새로고침합니다.
    /// - Parameters:
    ///   - series: An array of new `ChartDataSeries` objects to display. (표시할 새로운 `ChartDataSeries` 객체의 배열)
    ///   - type: The new `ChartType` to apply. (적용할 `ChartType`)
    public func setData(series: [ChartDataSeries<XValue>], type: ChartType) {
        self.configuration.type = type
        self.dataSeries = series
        forceFullReload()
    }
    
    /// Appends a new data point to a specified data series. Used for real-time charts.
    ///
    /// 지정된 ID의 데이터 계열(Series)에 새로운 데이터 포인트를 추가합니다. 실시간 차트에 사용됩니다.
    /// - Parameters:
    ///   - point: The `ChartDataPoint` object to append. (추가할 `ChartDataPoint` 객체)
    ///   - seriesId: The unique ID of the target `ChartDataSeries`. (데이터 포인트를 추가할 대상 `ChartDataSeries`의 고유 ID)
    public func appendDataPoint(_ point: ChartDataPoint<XValue>, seriesId: String) {
        guard let series = dataSeries.first(where: { $0.id == seriesId }) else { return }
        series.points.append(point)
        DispatchQueue.main.async { [weak self] in
            self?.incrementalUpdate()
            if let self = self, self.shouldAutoFollowNewData() {
                self.scrollToShowLatestData()
            }
        }
    }
    
    /// Updates the last data point of a specified data series.
    ///
    /// 지정된 ID를 가진 데이터 계열의 마지막 데이터 포인트를 업데이트합니다.
    /// - Parameters:
    ///   - point: The `ChartDataPoint` object to update with. (업데이트할 `ChartDataPoint` 객체)
    ///   - seriesId: The unique ID of the target `ChartDataSeries`. (대상 `ChartDataSeries`의 고유 ID)
    public func updateLastDataPoint(_ point: ChartDataPoint<XValue>, seriesId: String) {
        guard let series = dataSeries.first(where: { $0.id == seriesId }), !series.points.isEmpty else { return }
        series.points[series.points.count - 1] = point
        DispatchQueue.main.async { [weak self] in
            self?.incrementalUpdate()
        }
    }
    
    /// Prepends past data to the beginning of the chart.
    ///
    /// 과거 데이터를 차트의 시작 부분에 추가합니다.
    /// - Parameters:
    ///   - newPoints: An array of `ChartDataPoint` objects to prepend. (추가할 `ChartDataPoint` 객체의 배열)
    ///   - seriesId: The unique ID of the target `ChartDataSeries`. (데이터 포인트를 추가할 대상 `ChartDataSeries`의 고유 ID)
    public func prependData(points newPoints: [ChartDataPoint<XValue>], forSeriesId seriesId: String) {
        guard !newPoints.isEmpty, let series = dataSeries.first(where: { $0.id == seriesId }) else {
            endDataLoading()
            return
        }
        
        let oldFirstVisibleX = screenToX(0)
        let oldXRange: Double
        if let currentRange = dataRange {
            oldXRange = currentRange.xMax.doubleValue - currentRange.xMin.doubleValue
        } else {
            oldXRange = 0
        }
        
        series.points.insert(contentsOf: newPoints, at: 0)
        simplifiedChunkCache.removeAll()
        expandDataRange(for: newPoints)
        
        if let currentRange = dataRange, oldXRange > 0 {
            let newXRange = currentRange.xMax.doubleValue - currentRange.xMin.doubleValue
            if newXRange > oldXRange {
                let scaleFactor = newXRange / oldXRange
                self.zoomScale *= scaleFactor
            }
        }
        
        let newScreenXForOldPoint = xToScreen(oldFirstVisibleX)
        self.contentOffset.x -= newScreenXForOldPoint
        
        endDataLoading()
        scheduleUpdate()
    }
    
    /// Switches the chart to real-time mode, saving the current zoom and scroll state.
    ///
    /// 차트를 실시간 모드로 전환합니다. 현재의 줌, 스크롤 상태를 저장합니다.
    public func enterRealTimeMode() {
        guard !isRealTimeMode else { return }
        savedContentOffset = contentOffset
        savedZoomScale = zoomScale
        savedDataRange = dataRange
        isRealTimeMode = true
    }
    
    /// Exits real-time mode and restores the previously saved zoom and scroll state.
    ///
    /// 실시간 모드를 종료하고 이전에 저장된 줌, 스크롤 상태로 복원합니다.
    public func exitRealTimeMode() {
        guard isRealTimeMode else { return }
        isRealTimeMode = false
        self.contentOffset = savedContentOffset
        self.zoomScale = savedZoomScale
        self.dataRange = savedDataRange
        scheduleUpdate()
    }
    
    // MARK: - Layout & Drawing
    public override func layoutSubviews() {
        super.layoutSubviews()
        let yAxisLabelWidth: CGFloat = 40
        let xAxisLabelHeight: CGFloat = 25
        let topPadding: CGFloat = 10
        let rightPadding: CGFloat = 10
        chartBounds = CGRect(x: yAxisLabelWidth, y: topPadding, width: bounds.width - yAxisLabelWidth - rightPadding, height: bounds.height - topPadding - xAxisLabelHeight)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        chartLayer.frame = chartBounds
        axisLayer.frame = bounds
        CATransaction.commit()
        
        if !isLayoutInitialized && bounds != .zero {
            isLayoutInitialized = true
            if !dataSeries.isEmpty {
                forceFullReload()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func forceFullReload() {
        guard isLayoutInitialized else { return }
        simplifiedChunkCache.removeAll()
        isAutoScrolling = true
        isInitialZoomSet = false
        calculateDataRange()
        setupInitialView()
        scheduleUpdate()
    }
    
    private func startDisplayLink() {
        guard displayLink == nil else { return }
        
        let proxy = DisplayLinkProxy<XValue>(target: self)
        self.displayLinkProxy = proxy
        displayLink = CADisplayLink(target: proxy, selector: #selector(DisplayLinkProxy<XValue>.displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        displayLinkProxy = nil
    }
    
    private func setupInitialView() {
        guard let series = dataSeries.first, series.points.count > 1 else {
            zoomScale = 1.0
            contentOffset = .zero
            return
        }
        isInitialZoomSet = true
        
        let allPoints = series.points
        let latestPoints = allPoints.suffix(30)
        
        guard let firstOfLatest = latestPoints.first?.x,
              let lastOfLatest = latestPoints.last?.x,
              let firstOfAll = allPoints.first?.x,
              let lastOfAll = allPoints.last?.x else { return }
        
        let latestRange = lastOfLatest.doubleValue - firstOfLatest.doubleValue
        let totalRange = lastOfAll.doubleValue - firstOfAll.doubleValue
        
        if latestRange > 0 && totalRange > 0 {
            let targetZoomScale = totalRange / latestRange
            self.zoomScale = max(self.minZoomScale, targetZoomScale)
        } else {
            self.zoomScale = self.minZoomScale
        }
        scrollToEnd()
    }
    
    private func scheduleUpdate() {
        guard window != nil, bounds != .zero else { return }
        isUpdateScheduled = true
        startDisplayLink()
    }
    
    @objc internal func displayLinkTick() {
        var needsMoreUpdates = false
        
        if isDecelerating {
            updateDeceleration()
            needsMoreUpdates = true
        }
        
        if isUpdateScheduled {
            isUpdateScheduled = false
            updateAllLayers()
            if gestureRecognizers?.contains(
                where: { $0.state == .changed
                }) == true {
                needsMoreUpdates = true
            }
        }
        
        if !needsMoreUpdates {
            stopDisplayLink()
        }
    }
    
    private func updateAllLayers() {
        if isAutoScrolling {
            calculateDataRange()
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateGridAndAxisLayers()
        updateChartContent()
        if isAutoScrolling && !isRealTimeMode {
            scrollToEnd()
        }
        CATransaction.commit()
    }
    
    private func incrementalUpdate() {
        if isAutoScrolling {
            updateDataRangeForRealTime()
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateGridAndAxisLayers()
        updateChartContentIncremental()
        CATransaction.commit()
    }
    
    private func updateDataRangeForRealTime() {
        guard let series = dataSeries.first,
              !series.points.isEmpty,
              var currentRange = dataRange
        else { return }
        
        let allPoints = series.points
        let yMin = allPoints.map { $0.minValue ?? $0.y }.min() ?? 0
        let yMax = allPoints.map { $0.maxValue ?? $0.y }.max() ?? 1
        let yRange = max(1, yMax - yMin)
        let finalYMax = yMax + yRange * 0.2
        let finalYMin = max(0, yMin - yRange * 0.1)
        
        guard let newXMin = allPoints.first?.x,
              let newXMax = allPoints.last?.x
        else { return }
        
        currentRange.xMin = min(currentRange.xMin, newXMin)
        currentRange.xMax = max(currentRange.xMax, newXMax)
        currentRange.yMin = finalYMin
        currentRange.yMax = finalYMax
        
        self.dataRange = currentRange
    }
    
    private func updateChartContent() {
        switch configuration.type {
        case .healthData: updateBarLayers(isHealthData: true)
        case .bar: updateBarLayers(isHealthData: false)
        case .line: updatePathLayer(isArea: false)
        case .area: updatePathLayer(isArea: true)
        }
    }
    
    private func updateChartContentIncremental() {
        updateChartContent()
    }
    
    private func formatNumber(_ n: Double) -> String {
        if n >= 1000000 {
            return String(format: "%.1fM", n / 1000000).replacingOccurrences(of: ".0", with: "")
        }
        if n >= 1000 {
            return String(format: "%.1fk", n / 1000).replacingOccurrences(of: ".0", with: "")
        }
        return String(format: "%.0f", n)
    }
    
    private func checkForDataLoading() {
        guard case .automatic(let thresholdPercentage) = dataLoadingMethod, !isContentFullyVisible() else { return }
        
        let loadThreshold = chartBounds.width * thresholdPercentage

        if canLoadPastData && !isLoadingPastData && contentOffset.x > -loadThreshold {
            isLoadingPastData = true
            delegate?.chartViewDidRequestPastData(self)
        }
        
        let minOffset = chartBounds.width * (1 - zoomScale)
        if canLoadFutureData && !isLoadingFutureData && contentOffset.x < minOffset + loadThreshold {
            isLoadingFutureData = true
            delegate?.chartViewDidRequestFutureData(self)
        }
    }
        
    private func effectiveLineWidth(for series: ChartDataSeries<XValue>) -> CGFloat {
        guard !series.points.isEmpty, let firstSeries = dataSeries.first else { return 2.0 }

        let totalContentWidth = chartBounds.width * zoomScale
        let spacePerPoint = totalContentWidth / CGFloat(firstSeries.points.count)
        let widthFromSpacing = max(0.5, spacePerPoint * 0.8)
        
        let baseWidth = series.lineWidth
        let minWidth: CGFloat = 1.0
        let startZoom: CGFloat = 1.0
        let endZoom: CGFloat = 5.0
        
        let widthFromZoom: CGFloat
        if zoomScale >= endZoom {
            widthFromZoom = baseWidth
        } else if zoomScale <= startZoom {
            widthFromZoom = minWidth
        } else {
            let progress = (zoomScale - startZoom) / (endZoom - startZoom)
            widthFromZoom = minWidth + progress * (baseWidth - minWidth)
        }

        return min(widthFromZoom, widthFromSpacing)
    }
    
    private func updateBarLayers(isHealthData: Bool) {
        cleanupAllPathLayers()
        guard let series = dataSeries.first,
              let dataRange = dataRange
        else {
            cleanupBarLayers()
            return
        }
        
        let newPointCount = series.points.count
        
        if newPointCount > barLayers.count {
            for _ in 0..<(newPointCount - barLayers.count) {
                let barLayer = CALayer()
                barLayers.append(barLayer)
                chartLayer.addSublayer(barLayer)
            }
        } else if newPointCount < barLayers.count {
            let diff = barLayers.count - newPointCount
            barLayers.suffix(diff).forEach { $0.removeFromSuperlayer() }
            barLayers.removeLast(diff)
        }
        
        let barWidth = effectiveLineWidth(for: series)
        
        for i in 0..<newPointCount {
            let point = series.points[i]
            let layer = barLayers[i]
            
            let screenX = xToScreen(point.x)
            let topY: CGFloat
            let height: CGFloat
            
            if isHealthData {
                guard let minValue = point.minValue, let maxValue = point.maxValue else {
                    layer.isHidden = true; continue
                }
                topY = yToScreen(maxValue)
                height = max(2.0, yToScreen(minValue) - topY)
            } else {
                topY = yToScreen(point.y)
                height = max(2.0, yToScreen(dataRange.yMin) - topY)
            }
            
            layer.frame = CGRect(x: screenX - barWidth / 2, y: topY, width: barWidth, height: height)
            layer.backgroundColor = series.color.cgColor
            layer.cornerRadius = barWidth / 2
            layer.isHidden = false
        }
    }
    
    private func updatePathLayer(isArea: Bool) {
        cleanupBarLayers()
        guard let series = dataSeries.first,
              !series.points.isEmpty,
              let dataRange = dataRange
        else {
            cleanupAllPathLayers()
            return
        }
        
        let visibleXMin = screenToX(0)
        let visibleXMax = screenToX(chartBounds.width)
        
        guard let firstVisibleIndex = series.points.firstIndex(where: { $0.x >= visibleXMin }),
              let lastVisibleIndex = series.points.lastIndex(where: { $0.x <= visibleXMax }) else {
            cleanupAllPathLayers()
            return
        }
        
        let startChunkIndex = firstVisibleIndex / chunkSize
        let endChunkIndex = lastVisibleIndex / chunkSize
        let visibleChunkIndices = Set(startChunkIndex...endChunkIndex)
        let existingLayerIndices = Set(visiblePathLayers.keys)
        
        for chunkIndex in existingLayerIndices.subtracting(visibleChunkIndices) {
            visiblePathLayers[chunkIndex]?.removeFromSuperlayer()
            visiblePathLayers.removeValue(forKey: chunkIndex)
        }
        
        for chunkIndex in visibleChunkIndices {
            if let simplifiedPoints = simplifiedChunkCache[chunkIndex] {
                let layer = visiblePathLayers[chunkIndex] ?? CAShapeLayer()
                
                let path = UIBezierPath()
                if let firstPoint = simplifiedPoints.first {
                    if isArea {
                        path.move(to: CGPoint(x: xToScreen(firstPoint.x), y: yToScreen(dataRange.yMin)))
                        path.addLine(to: CGPoint(x: xToScreen(firstPoint.x), y: yToScreen(firstPoint.y)))
                    } else {
                        path.move(to: CGPoint(x: xToScreen(firstPoint.x), y: yToScreen(firstPoint.y)))
                    }
                    
                    simplifiedPoints.dropFirst().forEach { path.addLine(to: CGPoint(x: xToScreen($0.x), y: yToScreen($0.y))) }
                    
                    if isArea, let lastPoint = simplifiedPoints.last {
                        path.addLine(to: CGPoint(x: xToScreen(lastPoint.x), y: yToScreen(dataRange.yMin)))
                        path.close()
                    }
                }
                
                layer.path = path.cgPath
                layer.strokeColor = series.color.cgColor
                layer.fillColor = isArea ? series.color.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
                layer.lineWidth = isArea ? 0 : effectiveLineWidth(for: series)
                
                if visiblePathLayers[chunkIndex] == nil {
                    chartLayer.addSublayer(layer)
                    visiblePathLayers[chunkIndex] = layer
                }
            }
        }
        
        prefetchChunks(around: startChunkIndex...endChunkIndex)
    }
    
    private func prefetchChunks(around visibleIndices: ClosedRange<Int>) {
        guard let series = dataSeries.first, !series.points.isEmpty else { return }
        
        let prefetchWindow = (visibleIndices.lowerBound - 2)...(visibleIndices.upperBound + 2)
        
        for chunkIndex in prefetchWindow {
            guard chunkIndex >= 0, chunkIndex < (series.points.count + chunkSize - 1) / chunkSize else { continue }
            
            if simplifiedChunkCache[chunkIndex] != nil { continue }
            
            simplifiedChunkCache[chunkIndex] = []
            
            let startIndex = chunkIndex * self.chunkSize
            let endIndex = min(startIndex + self.chunkSize, series.points.count)
            let chunkPoints = Array(series.points[startIndex..<endIndex])
            let threshold = Int(self.chartBounds.width / 2)
            
            DispatchQueue.global(qos: .userInitiated).async {
                let simplifiedPoints = ChartDataProcessor.simplifyLTTB(points: chunkPoints, threshold: threshold)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.simplifiedChunkCache[chunkIndex] = simplifiedPoints
                    self.scheduleUpdate()
                }
            }
        }
    }
    
    private func endDataLoading() {
        self.isLoadingPastData = false
        self.isLoadingFutureData = false
    }
    
    private func cleanupAllPathLayers() {
        visiblePathLayers.values.forEach { $0.removeFromSuperlayer() }
        visiblePathLayers.removeAll()
    }
    
    private func cleanupBarLayers() {
        barLayers.forEach { $0.removeFromSuperlayer() }
        barLayers.removeAll()
    }

    private func setupGestures() {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:))))
    }
    
    private func updateConfiguration() {
        self.backgroundColor = configuration.backgroundColor
        scheduleUpdate()
    }
    
    private func updateGridAndAxisLayers() {
        axisLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        gridLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        guard let dataRange = dataRange else { return }
        
        let yLabels = calculateNiceAxisValues(min: dataRange.yMin, max: dataRange.yMax, desiredTicks: 5)
        
        for value in yLabels {
            let y = yToScreen(value)
            
            let gridLine = CAShapeLayer()
            let gridPath = UIBezierPath()
            gridPath.move(to: CGPoint(x: 0, y: y))
            gridPath.addLine(to: CGPoint(x: chartBounds.width, y: y))
            gridLine.path = gridPath.cgPath
            gridLine.strokeColor = configuration.gridColor.cgColor
            gridLine.lineWidth = 0.5
            gridLine.lineDashPattern = [2, 3]
            gridLayer.addSublayer(gridLine)
            
            let label = CATextLayer()
            label.string = String(format: "%.0f", value)
            label.font = UIFont.systemFont(ofSize: 10)
            label.fontSize = 10
            label.foregroundColor = UIColor.lightGray.cgColor
            label.contentsScale = UIScreen.main.scale
            label.alignmentMode = .right
            label.frame = CGRect(x: 0, y: y + chartBounds.minY - 8, width: chartBounds.minX - 5, height: 16)
            axisLayer.addSublayer(label)
        }
    }
    
    private func calculateDataRange() {
        guard let series = dataSeries.first,
              !series.points.isEmpty
        else {
            dataRange = nil
            return
        }
        
        let allPoints = series.points
        let yMin = allPoints.map { $0.minValue ?? $0.y }.min() ?? 0
        let yMax = allPoints.map { $0.maxValue ?? $0.y }.max() ?? 1
        
        let yRange = max(1, yMax - yMin)
        let finalYMax = yMax + yRange * 0.2
        let finalYMin = max(0, yMin - yRange * 0.1)
        
        guard var xMin = allPoints.first?.x, var xMax = allPoints.last?.x else {
            dataRange = nil
            return
        }
        
        if allPoints.count == 1 {
            xMin = XValue(doubleValue: xMin.doubleValue - 0.5)
            xMax = XValue(doubleValue: xMax.doubleValue + 0.5)
        }
        
        dataRange = (xMin: xMin, xMax: xMax, yMin: finalYMin, yMax: finalYMax)
    }
    
    private func xToScreen(_ x: XValue) -> CGFloat {
        guard let dataRange = dataRange else { return 0 }
        
        let scaledWidth = chartBounds.width * zoomScale
        let padding = (configuration.type == .bar || configuration.type == .healthData) ? (effectiveLineWidth(for: dataSeries.first!) / 2) : 0
        let effectiveWidth = scaledWidth - (padding * 2)
        
        guard effectiveWidth > 0 else { return scaledWidth / 2 + contentOffset.x }
        
        let dataValueRange = (dataRange.xMax.doubleValue - dataRange.xMin.doubleValue)
        guard dataValueRange > 0 else { return padding + effectiveWidth / 2 + contentOffset.x }
        
        let positionRatio = CGFloat((x.doubleValue - dataRange.xMin.doubleValue) / dataValueRange)
        return padding + (positionRatio * effectiveWidth) + contentOffset.x
    }
    
    private func yToScreen(_ y: Double) -> CGFloat {
        guard let dataRange = dataRange else { return chartBounds.height / 2 }
        
        let range = (dataRange.yMax.doubleValue - dataRange.yMin.doubleValue)
        guard range > 0 else { return chartBounds.height / 2 }
        return chartBounds.height - (CGFloat((y - dataRange.yMin) / range) * chartBounds.height)
    }
    
    private func screenToX(_ s: CGFloat) -> XValue {
        guard let dataRange = dataRange else {
            return XValue(doubleValue: 0)
        }
        
        let scaledWidth = chartBounds.width * zoomScale
        let padding = (configuration.type == .bar || configuration.type == .healthData) ? (effectiveLineWidth(for: dataSeries.first!) / 2) : 0
        let effectiveWidth = scaledWidth - (padding * 2)
        
        guard effectiveWidth > 0 else {
            return dataRange.xMin
        }
        
        let positionInView = s - contentOffset.x - padding
        let positionRatio = positionInView / effectiveWidth
        let dataValueRange = (dataRange.xMax.doubleValue - dataRange.xMin.doubleValue)
        
        let newXDouble = Double(positionRatio) * dataValueRange + dataRange.xMin.doubleValue
        return XValue(doubleValue: newXDouble)
    }
    
    private func calculateNiceAxisValues(min: Double, max: Double, desiredTicks: Int) -> [Double] {
        guard min.isFinite, max.isFinite, max > min else { return [] }
        
        let range = max - min
        if range == 0 { return [min] }
        
        let minTickCount = 5
        let maxTickCount = 15
        
        var interval = range / Double(maxTickCount - 1)
        let exponent = pow(10, floor(log10(interval)))
        let niceMultipliers = [1.0, 2.0, 2.5, 5.0, 10.0]
        
        let fraction = interval / exponent
        let niceFraction = niceMultipliers.first { $0 >= fraction } ?? 10.0
        interval = niceFraction * exponent
        
        let startValue = floor(min / interval) * interval
        let endValue = ceil(max / interval) * interval
        
        var values: [Double] = []
        var current = startValue
        while current <= endValue {
            values.append(current)
            current += interval
        }

        while values.filter({ $0 >= min && $0 <= max }).count < minTickCount {
            interval /= 2
            
            let newStart = floor(min / interval) * interval
            let newEnd = ceil(max / interval) * interval
            
            values.removeAll()
            current = newStart
            while current <= newEnd {
                values.append(current)
                current += interval
            }
            if interval < 1e-9 { break }
        }
        
        return values.filter { $0 >= min && $0 <= max }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            isDecelerating = false
            scrollVelocity = 0.0
        }
        
        if gesture.state == .began || gesture.state == .changed {
            isAutoScrolling = false
        }
        
        let translation = gesture.translation(in: self)
        let proposedX = contentOffset.x + translation.x
        gesture.setTranslation(.zero, in: self)
        
        let maxOffset: CGFloat = 0
        let minOffset: CGFloat = min(0, chartBounds.width * (1 - zoomScale))
        
        contentOffset.x = min(maxOffset, max(minOffset, proposedX))
        
        checkForDataLoading()
        scheduleUpdate()
        
        if gesture.state == .ended || gesture.state == .cancelled {
            let velocity = gesture.velocity(in: self)
            if abs(velocity.x) > 10 {
                isDecelerating = true
                scrollVelocity = velocity.x
            } else if contentOffset.x <= minOffset {
                isAutoScrolling = true
            }
        }
    }
    
    private func isContentFullyVisible() -> Bool {
        guard let dataRange = dataRange else { return true }
        
        let totalXRange = dataRange.xMax.doubleValue - dataRange.xMin.doubleValue
        if totalXRange <= 0 { return true }
        
        let visibleXMin = screenToX(0)
        let visibleXMax = screenToX(chartBounds.width)
        let visibleXRange = visibleXMax.doubleValue - visibleXMin.doubleValue
        
        return visibleXRange >= totalXRange - 1e-9
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            isDecelerating = false
            scrollVelocity = 0.0
            
            simplifiedChunkCache.removeAll()
        }
        
        if gesture.state == .began || gesture.state == .changed {
            isAutoScrolling = false
        }
        
        let locationInChart = gesture.location(in: self)
        guard chartLayer.frame.contains(locationInChart) else { return }
        
        let dataAnchor = screenToX(locationInChart.x - chartLayer.frame.minX)
        let newZoomScale = min(self.maxZoomScale, max(self.minZoomScale, zoomScale * gesture.scale))
        gesture.scale = 1.0
        
        let oldScreenX = xToScreen(dataAnchor)
        zoomScale = newZoomScale
        let newScreenX = xToScreen(dataAnchor)
        contentOffset.x -= newScreenX - oldScreenX
        
        let maxOffset: CGFloat = 0
        let minOffset: CGFloat = min(0, chartBounds.width * (1 - zoomScale))
        contentOffset.x = min(maxOffset, max(minOffset, contentOffset.x))
        
        scheduleUpdate()
        
        if gesture.state == .ended || gesture.state == .cancelled {
            if contentOffset.x <= minOffset {
                isAutoScrolling = true
            }
        }
    }
    
    private func expandDataRange(for prependedPoints: [ChartDataPoint<XValue>]) {
        guard var currentRange = self.dataRange, let firstNewPoint = prependedPoints.first else {
            calculateDataRange()
            return
        }
        
        currentRange.xMin = firstNewPoint.x
        
        let newYMin = prependedPoints.map { $0.minValue ?? $0.y }.min() ?? currentRange.yMin
        let newYMax = prependedPoints.map { $0.maxValue ?? $0.y }.max() ?? currentRange.yMax
        
        var needsYUpdate = false
        if newYMin < currentRange.yMin {
            currentRange.yMin = newYMin
            needsYUpdate = true
        }
        if newYMax > currentRange.yMax {
            currentRange.yMax = newYMax
            needsYUpdate = true
        }
        
        if needsYUpdate {
            let yRange = max(1, currentRange.yMax - currentRange.yMin)
            currentRange.yMax += yRange * 0.2
            currentRange.yMin = max(0, currentRange.yMin - yRange * 0.1)
        }
        
        self.dataRange = currentRange
    }
    
    private func updateDeceleration() {
        contentOffset.x += scrollVelocity * (1.0 / 60.0)
        scrollVelocity *= decelerationRate
        
        checkForDataLoading()
        
        let maxOffset: CGFloat = 0
        let minOffset: CGFloat = min(0, chartBounds.width * (1 - zoomScale))
        
        if contentOffset.x >= maxOffset || contentOffset.x <= minOffset {
            contentOffset.x = min(maxOffset, max(minOffset, contentOffset.x))
            scrollVelocity = 0.0
            isDecelerating = false
            if contentOffset.x <= minOffset {
                isAutoScrolling = true
            }
        }
        
        if abs(scrollVelocity) < 1.0 {
            isDecelerating = false
            scrollVelocity = 0.0
        }
        scheduleUpdate()
    }
    
    private func scrollToEnd() {
        let minOffset = chartBounds.width * (1 - zoomScale)
        contentOffset.x = min(0, minOffset)
    }
    
    private func shouldAutoFollowNewData() -> Bool {
        guard isAutoScrolling else { return false }
        guard let series = dataSeries.first, let lastPoint = series.points.last else { return false }
        
        let visibleXMax = screenToX(chartBounds.width)
        return lastPoint.x > visibleXMax
    }
    
    private func scrollToShowLatestData() {
        guard let lastPointX = dataSeries.first?.points.last?.x else { return }
        
        let targetScreenX = chartBounds.width * 0.8
        let currentScreenX = xToScreen(lastPointX)
        let adjustment = targetScreenX - currentScreenX
        
        let maxOffset: CGFloat = 0
        let minOffset: CGFloat = min(0, chartBounds.width * (1 - zoomScale))
        
        contentOffset.x = min(maxOffset, max(minOffset, contentOffset.x + adjustment))
        scheduleUpdate()
    }
}

