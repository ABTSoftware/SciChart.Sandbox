# Accessibility and SciChart
This is a short description on the samples we have made as a part of feasibility of the iOS accessibility features (voice over in particular). Here we describe the approach we took and what have we achieved. 
Please find interested sections below:
- [VoiceOver](#voiceover)
- [Text Size](#text-size) 
- [Color and Contrast](#color-and-contrast)
## VoiceOver
In our examples we've experimented with the voice over the chart as the whole as well as its parts:
- The voice over the chart element using a line chart as an example (surface, axes, data series points). 
- The voice over the column chart, where it reads volumes of selected columns. 
- The voice over the actions, like scrolling the chart, zoom to extents etc 
- It voices over the visible range changing (when we zoom in, for example the axis is changes). 
- It voices over the custom actions as well. 

Please see short descriptions of how we have achieved different parts on iOS side.

### SCIChartSurface
In order to make `SCIChartSurface` accessible we need either to set isAccessibilityElement = true or provide accessibilityElements collection. In case of reading from the surface, it's fairly reasonable to make it as accessibility elements collection which would contain axes and renderSurface (it may contain anything else you need). Here how we set it: 

```swift
extension SCIChartSurface {
    open override var accessibilityElements: [Any]? {
        get {
            var elements = [Any]()
            elements.append(self.renderSurface)
            elements.append(contentsOf: self.xAxes.toArray())
            elements.append(contentsOf: self.yAxes.toArray())
            
            return elements
        }
        set { super.accessibilityElements = newValue }
    }
    open override func accessibilityElementCount() -> Int {
        return self.accessibilityElements!.count
    }
    open override func accessibilityElement(at index: Int) -> Any? {
        return self.accessibilityElements![index]
    }
}
```

### SCIAxisBase
The following code is responsible for making all axes (because of the above extensions) accessible elements and hence **VoiceOver** can read labels and other properties provided by `UIAccessibleElement` informal protocol

```swift
extension SCIAxisBase {
    open override var accessibilityLabel: String? {
        get { return "\(self.isXAxis ? "X" : "Y") Axis with visible range \(self.visibleRange.format())" }
        set { super.accessibilityLabel = newValue }
    }
    open override var accessibilityFrame: CGRect {
        get { return UIAccessibility.convertToScreenCoordinates(self.layoutRect, in: self.parentSurface.view) }
        set { super.accessibilityFrame = newValue }
    }
    open override var isAccessibilityElement: Bool {
        get { return true }
        set { super.isAccessibilityElement = newValue }
    }
}
```

> Please note that the following extensions are used as helpers for the other extensions
> ```swift
>   extension Double {
>       func format(f: String) -> String {
>           return String(format: "%\(f)f", self)
>       }
>   }
>   extension ISCIRange {
>       func format() -> String {
>           let format = ".1"
>           let min = self.min.toDouble()
>           let max = self.max.toDouble()
>    
>           return "from \(min.format(f: format)) to \(max.format(f: format))"
>       }
>   }
> ```
 
### RenderableSeries and DataSeries
In order to make renderableSeries (dataSeries) points accessible, we need to make sure that renderSurface is an accessibility elements container and it provides collection of `UIAccessibilityElement`'s of desired points.
 
To do that accurately we set rendered listener to our `SCIChartSurface`. 
That's needed to receive callback after surface is rendered with latest up to date point coordinates.
 
In this closure we just go point by point and for each of those points we create `UIAccessibilityElement` object which is later added into `accessibilityElements` collection which is later used by system to act on it.

```swift
surface.setRenderedListener { (surface, _) in
    guard let surface = surface else { return }
    guard let dataSeries = surface.renderableSeries[0].dataSeries as? SCIXyDataSeries else { return }
    
    var accessibilityElements = [UIAccessibilityElement]()
    
    let xAxis = surface.xAxes[0]
    let xCoordCalc = xAxis.currentCoordinateCalculator
    
    for i in 0 ..< dataSeries.count {
        let xValue = dataSeries.xValues.value(at: i)!.toDouble()
        let yValue = dataSeries.yValues.value(at: i)!.toDouble()
        let xCoord = xCoordCalc.getCoordinate(xValue)
        
        let accessibilityElement = UIAccessibilityElement(accessibilityContainer:surface.renderSurface)
        accessibilityElement.accessibilityLabel = "\(Int(yValue)) value"
        let frame = CGRect(x: Double(xCoord - 15), y: Double(0), width: 30.0, height: Double(surface.renderableSeriesArea.view.frame.size.height))
        accessibilityElement.accessibilityFrame = UIAccessibility.convertToScreenCoordinates(frame, in: surface.view)
        
        accessibilityElements.append(accessibilityElement)
    }
    
    surface.renderSurface.view.accessibilityElements = accessibilityElements
}
```

### VisibleRange changes
To achieve reading changes of visible range by VoiceOver system, we used listener on axes and subscribe to visibleRange changed events. In the callback, we post notification to the system and provide it with announcement String which VoiceOver will read aloud:

```swift
xAxis.visibleRangeChangeListener = { (_, _, range, _) in
    guard let newRange = range else { return }
    
    let announsment = "X Axis range changed, now it's \(newRange.format())"
    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announsment)
}

yAxis.visibleRangeChangeListener = { (_, _, range, _) in
    guard let newRange = range else { return }
    
    let announsment = "Y Axis range changed, now it's \(newRange.format())"
    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announsment)
}
```

### Scroll Gestures
To support scroll gestures (up, down, left, and right) [provided by iOS](https://support.apple.com/en-lamr/guide/iphone/iph3e2e2281/ios) and triggered by three fingers swipe in corresponding direction, we override the following method:

```objc
- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction NS_AVAILABLE_IOS(4_2);
```
 
in which, depending on direction, as an example scroll X or Y axis visible range by half of screen size.
The following code is just an example and can be customized to different extends:

```swift 
open override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
    let size = self.frame.size
    switch direction {
    case .left:
        let axis = self.xAxes.defaultAxis
        axis.scroll(byPixels: -size.width / 2, clipMode: .none)
        return true
    case .right:
        let axis = self.xAxes.defaultAxis
        axis.scroll(byPixels: size.width / 2, clipMode: .none)
        return true
    case .up:
        let axis = self.yAxes.defaultAxis
        axis.scroll(byPixels: -size.height / 2, clipMode: .none)
        return true
    case .down:
        let axis = self.yAxes.defaultAxis
        axis.scroll(byPixels: size.height / 2, clipMode: .none)
        return true
    default:
        break
    }
    
    return false
}
```

### Custom Actions
There is a possibility to provide custom actions to you [rotor](https://support.apple.com/en-lamr/guide/iphone/iph3e2e3a6d/12.0/ios/12.0) - you'll need to fill you accessibility element with `accessibilityCustomActions` collection. 
The following code is an extension on `SCIChartSurface` which do just that:

```swift
extension SCIChartSurface {
    open override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            return [
                UIAccessibilityCustomAction(
                    name: "Zoom to Extents",
                    target: self,
                    selector: #selector(zoomExtentsCustomAction)
                ),
                UIAccessibilityCustomAction(
                    name: "Animate Zoom to Extents",
                    target: self,
                    selector: #selector(animatedZoomExtentsCustomAction)
                )
            ]
        }
        set { super.accessibilityCustomActions = newValue }
    }
    
    @objc
    func zoomExtentsCustomAction() {
        self.zoomExtents()
        
        let announsment = "Surface has just been zoomed to it's extents"
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announsment)
    }
    
    @objc
    func animatedZoomExtentsCustomAction() {
        self.animateZoomExtents(withDuration: 1.0)
        
        let announsment = "Surface has just been animated to it's extents"
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announsment)
    }
}
```

## Text Size
By default, chart accepts sizes in points, and hence SciChart is Scale/Device independent.
But if you'd like to respond to Accessibility Text Size changes, you would need either to override `traitCollectionDidChange:` or (as in our example) use `SwiftUI`s `@Environment (\.sizeCategory)` and update axes labels style according to size category using `UIFontMetric`:

```swift
@Environment (\.sizeCategory) var sizeCategory: ContentSizeCategory

func updateUIView(_ uiView: SCIChartSurface, context: Context) {
    if let primaryXAxis = uiView.xAxes.primaryAxis {
        primaryXAxis.tickLabelStyle = scaledFontStyle(for: primaryXAxis.tickLabelStyle)
    }
    if let primaryYAxis = uiView.yAxes.primaryAxis {
        primaryYAxis.tickLabelStyle = scaledFontStyle(for: primaryYAxis.tickLabelStyle)
    }
}

func scaledFontStyle(for fontStyle: SCIFontStyle) -> SCIFontStyle {
    let fontDescriptor = fontStyle.fontDescriptor
    let fontMetrics = UIFontMetrics(forTextStyle: UIFont.TextStyle.body)
    let font = fontMetrics.scaledFont(for: UIFont(descriptor: fontDescriptor, size: fontDescriptor.pointSize))
    
    return SCIFontStyle(fontDescriptor: font.fontDescriptor, andTextColor: fontStyle.color)
}

```

### Color and Contrast
Since colors and theming are most likely to be custom for each customer, 
we don't provide out of the box light and dark theme handling (nor special theme for High Contrast). 
But that's easy achievable through previously mentioned  `traitCollectionDidChange:` override or (as in our example) use `SwiftUI`s `@EnvironmentObject` e.g. `Environment (\.colorScheme)` and update theme manually using one of the [provided themes](https://www.scichart.com/documentation/ios/current/Styling%20and%20Theming.html), or creating [custom one](https://www.scichart.com/documentation/ios/current/create-a-custom-theme.html):

```swift
@Environment (\.sizeCategory) var sizeCategory: ContentSizeCategory

func updateUIView(_ uiView: SCIChartSurface, context: Context) {
    if self.colorScheme == .light {
        SCIThemeManager.applyTheme(to: uiView, withThemeKey: SCIChart_Bright_SparkStyleKey)
    } else {
        SCIThemeManager.applyTheme(to: uiView, withThemeKey: SCIChart_SciChartv4DarkStyleKey)
    }
}
```