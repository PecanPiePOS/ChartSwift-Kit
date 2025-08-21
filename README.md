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
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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
-   **📜 무한 스크롤**: 사용자가 차트 끝까지 스크롤하면 과거 또는 미래 데이터를 비동기적으로 로드.
-   **🧬 유연한 설계**: `Date`, `Double`, `Int` 등 `ChartableX`를 준수하는 모든 데이터 타입을 X축에서 사용 가능.
-   **📚 완벽한 문서화**: 모든 Public API에 상세한 영문/한글 주석이 달려있어 사용이 편리.
-   **🔧 손쉬운 커스터마이징**: `ChartConfiguration` 객체를 통해 차트의 외형을 손쉽게 설정.

### ⚙️ 동작 방식 (Performance)

ChartSwift-Kit은 처음부터 성능을 염두에 두고 설계되었습니다. 아래 두 가지 핵심 기술을 통해 수만 개의 데이터 포인트도 부드럽게 처리합니다.

1.  **청크 기반 렌더링 (Chunk-based Rendering)**: 전체 데이터셋을 한 번에 그리는 대신, 데이터를 작은 "청크" 단위로 지능적으로 분할합니다. 화면에 보이는 청크만 렌더링하여 작업량을 극적으로 줄입니다.

2.  **LTTB 다운샘플링 (LTTB Downsampling)**: 포인트 밀도가 높은 청크에 대해서는 **LTTB (Largest-Triangle-Three-Buckets)** 알고리즘을 사용합니다. 이는 단순히 데이터를 무작위로 샘플링하는 것이 아니라, 차트의 전체적인 형태를 유지하는 시각적으로 가장 중요한 포인트를 지능적으로 선택하여 속도와 시각적 정확성을 모두 보장합니다.

### 🎬 데모 (Demo)

| Pan & Zoom | Real-time Update | Paging (Infinite Scroll) |
| :---: | :---: | :---: |
| ![Pan and Zoom Demo](URL_TO_YOUR_PAN_ZOOM_DEMO.gif) | ![Real-time Demo](URL_TO_YOUR_REALTIME_DEMO.gif) | ![Paging Demo](URL_TO_YOUR_PAGING_DEMO.gif) |

> **참고**: 위 GIF들은 예시입니다. 실제 프로젝트의 동작을 녹화하여 교체해주세요.

### 📋 요구사항 (Requirements)

-   iOS 14.0+
-   Xcode 14.0+
-   Swift 5.7+

### 📦 설치 (Installation)

ChartSwift-Kit은 Swift Package Manager를 통해 간편하게 설치할 수 있습니다.

1.  Xcode 프로젝트에서 **File** > **Add Packages...** 를 선택합니다.
2.  검색창에 아래의 Repository URL을 입력합니다.
    ```
    [https://github.com/](https://github.com/)[YOUR_GITHUB_USERNAME]/ChartSwift-Kit.git
    ```
3.  **Dependency Rule**에서 `Up to Next Major Version`을 선택하고 **Add Package**를 클릭합니다.

### 🚀 빠른 시작 (Quick Start)

단 몇 줄의 코드로 멋진 라인 차트를 만들 수 있습니다.

```swift
import ChartSwift_Kit // SPM 이름으로 임포트
import UIKit

class ViewController: UIViewController {

    // 메인 클래스인 CoreChartView 사용
    let chartView = CoreChartView<Double>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 샘플 데이터 생성
        let points = (0..<100).map {
            ChartDataPoint(x: Double($0), y: Double.random(in: 0...100))
        }
        let series = ChartDataSeries(id: "sample", name: "Sample Data", points: points, color: .systemCyan)
        
        // 2. 차트에 데이터 설정
        chartView.setData(series: [series], type: .line)
        
        // 3. 뷰에 추가 및 레이아웃 설정
        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chartView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            chartView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            chartView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}
```

---
<br>
<br>

<a name="english"></a>

## 🇺🇸 English

**ChartSwift-Kit** is a high-performance iOS chart library designed to visualize large datasets smoothly and efficiently. The main component of this library is **`CoreChartView`**, which provides an intuitive API and powerful customization options for easy integration into any iOS application.

### ✨ Features

-   **🚀 Outstanding Performance**: Handles tens of thousands of data points seamlessly with chunk-based rendering and LTTB downsampling.
-   **🎨 Multiple Chart Types**: Supports essential chart types, including Line, Bar, Area, and HealthData.
-   **👆 Intuitive Gestures**: Freely explore data by pinching to zoom and panning to scroll.
-   **🕒 Real-time Ready**: Dynamically add and update data on the chart as it comes in real-time.
-   **📜 Infinite Scroll**: Asynchronously load past or future data when the user scrolls to the end of the chart.
-   **🧬 Generic by Design**: Use any data type that conforms to `ChartableX` for the X-axis, such as `Date`, `Double`, or `Int`.
-   **📚 Thoroughly Documented**: All public APIs are fully documented in both English and Korean for ease of use.
-   **🔧 Easily Customizable**: Effortlessly configure the chart's appearance using the `ChartConfiguration` object.

### ⚙️ How It Works (Performance)

ChartSwift-Kit was engineered for performance from the ground up. It handles massive datasets smoothly by using two key techniques:

1.  **Chunk-based Rendering**: Instead of drawing the entire dataset at once, the data is intelligently divided into smaller "chunks." Only the chunks currently visible on the screen are rendered, dramatically reducing the workload.

2.  **LTTB Downsampling**: For chunks with a high density of points, the library uses the **Largest-Triangle-Three-Buckets (LTTB)** algorithm. This isn't just random sampling; it intelligently selects the most visually significant points to preserve the chart's overall shape, ensuring both speed and visual fidelity.

### 🎬 Demo

| Pan & Zoom | Real-time Update | Paging (Infinite Scroll) |
| :---: | :---: | :---: |
| ![Pan and Zoom Demo](URL_TO_YOUR_PAN_ZOOM_DEMO.gif) | ![Real-time Demo](URL_TO_YOUR_REALTIME_DEMO.gif) | ![Paging Demo](URL_TO_YOUR_PAGING_DEMO.gif) |

> **Note**: The GIFs above are placeholders. Please replace them with recordings of your actual project.

### 📋 Requirements

-   iOS 14.0+
-   Xcode 14.0+
-   Swift 5.7+

### 📦 Installation

ChartSwift-Kit is easily installed via the Swift Package Manager.

1.  In Xcode, select **File** > **Add Packages...**.
2.  Enter the repository URL in the search bar:
    ```
    [https://github.com/](https://github.com/)[YOUR_GITHUB_USERNAME]/ChartSwift-Kit.git
    ```
3.  Set the **Dependency Rule** to `Up to Next Major Version` and click **Add Package**.

### 🚀 Quick Start

You can create a beautiful line chart with just a few lines of code.

```swift
import ChartSwift_Kit // Import the package
import UIKit

class ViewController: UIViewController {

    // Use the main class, CoreChartView
    let chartView = CoreChartView<Double>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Create sample data
        let points = (0..<100).map {
            ChartDataPoint(x: Double($0), y: Double.random(in: 0...100))
        }
        let series = ChartDataSeries(id: "sample", name: "Sample Data", points: points, color: .systemCyan)
        
        // 2. Set data on the chart
        chartView.setData(series: [series], type: .line)
        
        // 3. Add to the view and set layout constraints
        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chartView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            chartView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            chartView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}
```

---

### 🤝 Contributing

Contributions of all kinds are welcome, including feature suggestions, bug reports, and pull requests. Please feel free to open an issue or submit a PR.

### 📄 License

**ChartSwift-Kit** is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
