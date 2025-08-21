<div align="center">
  <br />
  <h1>ChartSwift-Kit</h1>
  <br />
  <p>
    <strong>A powerful and lightweight charting library for iOS featuring <code>CoreChartView</code>.<br />
    Designed for performance, flexibility, and ease of use.</strong>
  </p>
  <br>

[🇰🇷 **한국어**](#korean) | [🇺🇸 **English**](#english)

  <br>
  <img src="https://raw.githubusercontent.com/user-attachments/assets/195b0fe1-c967-46c2-8438-e4b9d5c411ba" width="600" />
  <br />
  
  [![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
  [![Platform](https://img.shields.io/badge/platform-iOS%2014.0%2B-blue.svg)](https://developer.apple.com/ios/)
  [![Swift Version](https://img.shields.io/badge/Swift-5.7%2B-orange.svg)](https://swift.org)
  [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

</div>

<br>
<br>

<a name="korean"></a>

## 🇰🇷 한국어

**ChartSwift-Kit**은 대용량 데이터를 빠르고 부드럽게 시각화하기 위해 설계된 고성능 iOS 차트 라이브러리입니다. 이 라이브러리의 메인 컴포넌트는 **`CoreChartView`**이며, 직관적인 API와 강력한 커스터마이징 옵션을 제공하여 어떤 iOS 앱에도 쉽게 통합할 수 있습니다.

### ✨ 주요 기능 (Features)

-   **🚀 압도적인 성능**: 수만 개의 데이터 포인트도 끊김 없이 처리하는 청크 기반 렌더링 및 LTTB 다운샘플링.
-   **🎨 다양한 차트 타입**: 라인(Line), 바(Bar), 영역(Area), 헬스 데이터(HealthData) 등 필수 차트 타입을 모두 지원.
-   **👆 직관적인 제스처**: 핀치(Pinch)로 확대/축소하고, 팬(Pan)으로 스크롤하며 데이터를 자유롭게 탐색.
-   **🕒 실시간 데이터 지원**: 실시간으로 들어오는 데이터를 차트에 동적으로 추가하고 업데이트.
-   **📜 무한 스크롤**: 사용자가 차트 끝까지 스크롤하면 Delegate를 통해 과거 또는 미래 데이터를 비동기적으로 로드.
-   **🧬 유연한 설계**: `Date`, `Double` 뿐만 아니라 `ChartableX`를 준수하는 모든 커스텀 타입을 X축에서 사용 가능.
-   **📚 완벽한 문서화**: 모든 Public API에 상세한 영문/한글 주석이 달려있어 사용이 편리.
-   **🔧 손쉬운 커스터마이징**: `ChartConfiguration` 객체를 통해 차트의 외형을 손쉽게 설정.

### 📦 설치 (Installation)

ChartSwift-Kit은 Swift Package Manager를 통해 간편하게 설치할 수 있습니다.

1.  Xcode 프로젝트에서 **File** > **Add Packages...** 를 선택합니다.
2.  검색창에 아래의 Repository URL을 입력합니다.
    ```
    [https://github.com/PecanPiePOS/ChartSwift-Kit.git](https://github.com/PecanPiePOS/ChartSwift-Kit.git)
    ```
3.  **Dependency Rule**에서 `Up to Next Major Version`을 선택하고 **Add Package**를 클릭합니다.

### 🚀 빠른 시작 (Quick Start)

단 몇 줄의 코드로 멋진 라인 차트를 만들 수 있습니다.

```swift
import ChartSwift_Kit
import UIKit

class ViewController: UIViewController {

    let chartView = CoreChartView<Double>() // X축 타입을 Double로 지정

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let points = (0..<100).map {
            ChartDataPoint(x: Double($0), y: Double.random(in: 0...100))
        }
        let series = ChartDataSeries(id: "sample", points: points, color: .systemCyan)
        chartView.setData(series: [series], type: .line)
        
        view.addSubview(chartView)
        // ... Auto Layout 설정 ...
    }
}
```

### 🧬 `ChartableX` 프로토콜 활용하기

`CoreChartView`의 가장 큰 장점은 제네릭 `XValue`가 `ChartableX` 프로토콜을 준수하기만 하면 어떤 타입이든 X축에 사용할 수 있다는 것입니다. `ChartableX`는 `Double` 값과 상호 변환이 가능하고, 비교가 가능하면 됩니다.

```swift
public protocol ChartableX: Comparable, Sendable {
    var doubleValue: Double { get }
    init(doubleValue: Double)
}
```

#### 기본 타입 (`Date`, `Double`, `Int`)
`Date`, `Double`, `Int`는 라이브러리에 이미 `ChartableX`가 구현되어 있어 바로 사용할 수 있습니다.
```swift
let dateChartView = CoreChartView<Date>()
let doubleChartView = CoreChartView<Double>()
```

#### 커스텀 타입 예시: `TradingDay`
거래일을 나타내는 커스텀 타입을 직접 만들어 X축에 사용할 수 있습니다.

```swift
// 1. ChartableX를 준수하는 커스텀 타입 정의
struct TradingDay: ChartableX, Comparable, Sendable {
    let day: Int
    
    // ChartableX 준수
    var doubleValue: Double { Double(day) }
    init(doubleValue: Double) { self.day = Int(doubleValue) }
    
    // Comparable 준수
    static func < (lhs: TradingDay, rhs: TradingDay) -> Bool {
        return lhs.day < rhs.day
    }
}

// 2. 차트 뷰와 데이터 생성 시 커스텀 타입 사용
let chartView = CoreChartView<TradingDay>()
let points: [ChartDataPoint<TradingDay>] = [
    .init(x: TradingDay(day: 1), y: 150.0),
    .init(x: TradingDay(day: 2), y: 155.5),
    .init(x: TradingDay(day: 5), y: 153.2) // X축 값이 연속적일 필요 없음
]
chartView.setData(series: [.init(id: "stock", points: points, color: .green)], type: .line)
```

### 🛠️ 상세 사용법 (In-Depth Usage)

#### Delegate를 이용한 데이터 페이징 (무한 스크롤)

**중요:** Delegate 메서드는 제네릭 `<XValue>`를 포함하므로, 내가 원하는 차트의 타입(`CoreChartView<Date>` 등)으로 **타입 캐스팅(`as?`)**하여 안전하게 사용해야 합니다.

```swift
import ChartSwift_Kit
import UIKit

class MyViewController: UIViewController, CoreChartViewDelegate {

    let chartView = CoreChartView<Date>() // 내 차트의 X축은 Date 타입

    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.delegate = self
        chartView.canLoadPastData = true // 과거 데이터 로딩 기능 활성화
    }

    // MARK: - CoreChartViewDelegate
    
    func chartViewDidRequestPastData<XValue: ChartableX>(_ chartView: CoreChartView<XValue>) {
        guard let dateChartView = chartView as? CoreChartView<Date> else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let pastPoints: [ChartDataPoint<Date>] = self.generatePastData()
            dateChartView.prependData(points: pastPoints, forSeriesId: "someId")
        }
    }
}
```

---
<br>
<br>

<a name="english"></a>

## 🇺🇸 English

**ChartSwift-Kit** is a high-performance iOS chart library designed to visualize large datasets smoothly and efficiently. The main component is **`CoreChartView`**, which provides an intuitive API for easy integration.

### ✨ Features

-   **🚀 Outstanding Performance**: Handles tens of thousands of data points seamlessly with chunk-based rendering and LTTB downsampling.
-   **🎨 Multiple Chart Types**: Supports essential chart types, including Line, Bar, Area, and HealthData.
-   **👆 Intuitive Gestures**: Freely explore data by pinching to zoom and panning to scroll.
-   **🕒 Real-time Ready**: Dynamically add and update data on the chart as it comes in real-time.
-   **📜 Infinite Scroll**: Asynchronously load past or future data via the delegate pattern when the user scrolls to the end.
-   **🧬 Generic by Design**: Use any custom type that conforms to `ChartableX` for the X-axis, not just `Date` or `Double`.
-   **📚 Thoroughly Documented**: All public APIs are fully documented in both English and Korean.
-   **🔧 Easily Customizable**: Effortlessly configure the chart's appearance using the `ChartConfiguration` object.

### 📦 Installation

ChartSwift-Kit is available via the Swift Package Manager.

1.  In Xcode, select **File** > **Add Packages...**.
2.  Enter the repository URL:
    ```
    [https://github.com/PecanPiePOS/ChartSwift-Kit.git](https://github.com/PecanPiePOS/ChartSwift-Kit.git)
    ```
3.  Set the **Dependency Rule** to `Up to Next Major Version` and click **Add Package**.

### 🚀 Quick Start

You can create a beautiful line chart with just a few lines of code.

```swift
import ChartSwift_Kit
import UIKit

class ViewController: UIViewController {

    let chartView = CoreChartView<Double>() // Specify the X-axis type as Double

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let points = (0..<100).map {
            ChartDataPoint(x: Double($0), y: Double.random(in: 0...100))
        }
        let series = ChartDataSeries(id: "sample", points: points, color: .systemCyan)
        chartView.setData(series: [series], type: .line)
        
        view.addSubview(chartView)
        // ... Set Auto Layout constraints ...
    }
}
```

### 🧬 Working with the `ChartableX` Protocol

The key advantage of `CoreChartView` is its generic `XValue`, which can be any type that conforms to the `ChartableX` protocol. A type is `ChartableX`-compliant if it can be compared and converted to and from a `Double` value.

```swift
public protocol ChartableX: Comparable, Sendable {
    var doubleValue: Double { get }
    init(doubleValue: Double)
}
```

#### Built-in Types (`Date`, `Double`, `Int`)
The library provides `ChartableX` conformance for `Date`, `Double`, and `Int` out of the box.
```swift
let dateChartView = CoreChartView<Date>()
let doubleChartView = CoreChartView<Double>()
```

#### Custom Type Example: `TradingDay`
You can create your own custom type, such as `TradingDay`, to use on the X-axis.

```swift
// 1. Define a custom type that conforms to ChartableX
struct TradingDay: ChartableX, Comparable, Sendable {
    let day: Int
    
    // Conformance to ChartableX
    var doubleValue: Double { Double(day) }
    init(doubleValue: Double) { self.day = Int(doubleValue) }
    
    // Conformance to Comparable
    static func < (lhs: TradingDay, rhs: TradingDay) -> Bool {
        return lhs.day < rhs.day
    }
}

// 2. Use the custom type when creating the chart view and its data
let chartView = CoreChartView<TradingDay>()
let points: [ChartDataPoint<TradingDay>] = [
    .init(x: TradingDay(day: 1), y: 150.0),
    .init(x: TradingDay(day: 2), y: 155.5),
    .init(x: TradingDay(day: 5), y: 153.2) // X-axis values do not need to be sequential
]
chartView.setData(series: [.init(id: "stock", points: points, color: .green)], type: .line)
```

### 🛠️ In-Depth Usage

#### Data Paging (Infinite Scroll) with the Delegate

**Important:** Because the delegate methods are generic (`<XValue>`), you must safely **cast (`as?`)** the chart view parameter to your specific type (e.g., `CoreChartView<Date>`) before using it.

```swift
import ChartSwift_Kit
import UIKit

class MyViewController: UIViewController, CoreChartViewDelegate {

    let chartView = CoreChartView<Date>() // My chart's X-axis is of type Date

    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.delegate = self
        chartView.canLoadPastData = true // Enable past data loading
    }

    // MARK: - CoreChartViewDelegate
    
    func chartViewDidRequestPastData<XValue: ChartableX>(_ chartView: CoreChartView<XValue>) {
        guard let dateChartView = chartView as? CoreChartView<Date> else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let pastPoints: [ChartDataPoint<Date>] = self.generatePastData()
            dateChartView.prependData(points: pastPoints, forSeriesId: "someId")
        }
    }
}
```

---

### 🤝 Contributing

Contributions of all kinds are welcome. Please feel free to open an issue or submit a PR.

### 📄 License

**ChartSwift-Kit** is available under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for more info.
