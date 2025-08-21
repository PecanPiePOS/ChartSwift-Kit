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

</div>

<br>

| Line Chart | Area Chart | Bar Chart |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/0cef3cf3-efc3-4065-95d0-1eac53b7b17f" width="260" alt="Line Chart Example"> | <img src="https://github.com/user-attachments/assets/1f07e083-8d34-4bc1-9d11-62a2df4c384d" width="260" alt="Area Chart Example"> | <img src="https://github.com/user-attachments/assets/f8bc2c5d-9e27-4f21-9888-0134797337de" width="260" alt="Bar Chart Example"> |

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

### 🎬 주요 기능 데모 (GIF)

* **부드러운 인터랙션 (Pan & Zoom)**: 사용자가 대용량 데이터를 부드럽게 스크롤하고 확대/축소하는 모습입니다.
  <img src="https://github.com/user-attachments/assets/6bafabd7-39b6-4b1c-92b0-e3b658f43b63" width="600" alt="Pan and Zoom Demo GIF">

* **실시간 데이터 업데이트 (Real-time Update)**: 데이터가 실시간으로 추가될 때 차트가 동적으로 갱신됩니다.
  <img src="https://github.com/user-attachments/assets/8b567572-2106-44c5-8c4c-2a9cc33f822d" width="600" alt="Real-time Demo GIF">

* **압도적인 성능 (High Performance)**: 5만 개 이상의 데이터 포인트를 즉시 로드하고도 완벽하게 반응성을 유지합니다.
  <img src="https://github.com/user-attachments/assets/ba51cab1-65a7-4e39-a181-e07056b4dec5" width="600" alt="Performance Test Demo GIF">

### 📦 설치 (Installation)

ChartSwift-Kit은 Swift Package Manager를 통해 간편하게 설치할 수 있습니다.

1.  Xcode 프로젝트에서 **File** > **Add Packages...** 를 선택합니다.
2.  오른쪽 상단의 검색창에 아래 **Repository URL을 복사하여 붙여넣으세요.**
    ```
    [https://github.com/PecanPiePOS/ChartSwift-Kit.git](https://github.com/PecanPiePOS/ChartSwift-Kit.git)
    ```
3.  **Dependency Rule**에서 `Up to Next Major Version`을 선택하고 **Add Package**를 클릭합니다.

### 🚀 빠른 시작 (Quick Start)

```swift
import ChartSwift_Kit
import UIKit

class ViewController: UIViewController {
    let chartView = CoreChartView<Double>()

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
-   **🧬 Generic by Design**: Use any custom type that conforms to `ChartableX` for the X-axis.
-   **📚 Thoroughly Documented**: All public APIs are fully documented in both English and Korean.
-   **🔧 Easily Customizable**: Effortlessly configure the chart's appearance using `ChartConfiguration`.

### 🎬 Key Feature Demos (GIFs)

* **Smooth Interaction (Pan & Zoom)**: Shows a user smoothly scrolling and zooming through a large dataset.
  <img src="https://github.com/user-attachments/assets/6bafabd7-39b6-4b1c-92b0-e3b658f43b63" width="600" alt="Pan and Zoom Demo GIF">

* **Real-time Updates**: Demonstrates the chart dynamically updating as new data is appended live.
  <img src="https://github.com/user-attachments/assets/8b567572-2106-44c5-8c4c-2a9cc33f822d" width="600" alt="Real-time Demo GIF">

* **High Performance**: Shows the chart instantly loading 50,000+ data points and remaining perfectly responsive.
  <img src="https://github.com/user-attachments/assets/ba51cab1-65a7-4e39-a181-e07056b4dec5" width="600" alt="Performance Test Demo GIF">

### 📦 Installation

ChartSwift-Kit is available via the Swift Package Manager.

1.  In Xcode, select **File** > **Add Packages...**.
2.  **Copy and paste the repository URL** below into the search bar:
    ```
    [https://github.com/PecanPiePOS/ChartSwift-Kit.git](https://github.com/PecanPiePOS/ChartSwift-Kit.git)
    ```
3.  Set the **Dependency Rule** to `Up to Next Major Version` and click **Add Package**.

### 🚀 Quick Start
```swift
import ChartSwift_Kit
import UIKit

class ViewController: UIViewController {
    let chartView = CoreChartView<Double>()

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

---

### 🤝 Contributing

Contributions of all kinds are welcome. Please feel free to open an issue or submit a PR.

### 📄 License

**ChartSwift-Kit** is available under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for more info.
