import SwiftUI
import SciChart

struct LineChartExample: View {
    var body: some View {
        LineChartView()
    }
}

struct LineChartView: UIViewRepresentable {
    
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @Environment (\.sizeCategory) var sizeCategory: ContentSizeCategory

    func makeUIView(context: Context) -> SCIChartSurface {
        let surface = SCIChartSurface()
        
        let xAxis = SCINumericAxis()
        xAxis.growBy = SCIDoubleRange(min: 0.1, max: 0.1)
        let yAxis = SCINumericAxis()
        yAxis.growBy = SCIDoubleRange(min: 0.1, max: 0.1)

        let dataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        for i in -5...5 {
            dataSeries.append(x: i, y: i * i)
        }

        let rSeries = SCIFastLineRenderableSeries()
        rSeries.strokeStyle = SCISolidPenStyle(color: .systemGreen, thickness: 1)
        rSeries.dataSeries = dataSeries
     
        SCIUpdateSuspender.usingWith(surface) {
            surface.xAxes.add(xAxis)
            surface.yAxes.add(yAxis)
            surface.renderableSeries.add(rSeries)
            surface.chartModifiers.add(items: SCIZoomExtentsModifier(), SCIPinchZoomModifier(), SCIZoomPanModifier())
            
            SCIAnimations.sweep(rSeries, duration: 3.0, easingFunction: SCICubicEase())
        }
        
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
        
        return surface
    }
    
    func updateUIView(_ uiView: SCIChartSurface, context: Context) {
        if self.colorScheme == .light {
            SCIThemeManager.applyTheme(to: uiView, withThemeKey: SCIChart_Bright_SparkStyleKey)
        } else {
            SCIThemeManager.applyTheme(to: uiView, withThemeKey: SCIChart_SciChartv4DarkStyleKey)
        }
        
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
}
