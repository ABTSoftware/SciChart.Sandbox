import SwiftUI
import SciChart

struct ColumnChartExample: View {
    var body: some View {
        ColumnChartView()
    }
}

struct ColumnChartView: UIViewRepresentable {

    func makeUIView(context: Context) -> SCIChartSurface {
        let surface = SCIChartSurface()
        
        let xAxis = SCINumericAxis()
        xAxis.growBy = SCIDoubleRange(min: 0.1, max: 0.1)
        let yAxis = SCINumericAxis()
        yAxis.growBy = SCIDoubleRange(min: 0, max: 0.1)
        
        let yValues = [50, 35, 61, 58, 50, 50, 40, 53, 55, 23, 45, 12, 59, 60];
        let dataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        for i in 0 ..< yValues.count {
            dataSeries.append(x: i, y: yValues[i])
        }
        
        let rSeries = SCIFastColumnRenderableSeries()
        rSeries.fillBrushStyle = SCISolidBrushStyle(color: .systemGreen)
        rSeries.dataSeries = dataSeries
     
        SCIUpdateSuspender.usingWith(surface) {
            surface.xAxes.add(xAxis)
            surface.yAxes.add(yAxis)
            surface.renderableSeries.add(rSeries)
            surface.chartModifiers.add(items: SCIZoomExtentsModifier(), SCIPinchZoomModifier(), SCIZoomPanModifier())
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
            
            let columnWidth = (rSeries.currentRenderPassData as! SCIColumnRenderPassData).columnPixelWidth
            
            let xAxis = surface.xAxes[0]
            let yAxis = surface.yAxes[0]
            let xCoordCalc = xAxis.currentCoordinateCalculator
            let yCoordCalc = yAxis.currentCoordinateCalculator
            
            for i in 0 ..< dataSeries.count {
                let xValue = dataSeries.xValues.value(at: i)!.toDouble()
                let yValue = dataSeries.yValues.value(at: i)!.toDouble()
                let xCoord = xCoordCalc.getCoordinate(xValue)
                let yCoord = yCoordCalc.getCoordinate(yValue)
                let zeroLine = yCoordCalc.getCoordinate(0.0)

                let accessibilityElement = UIAccessibilityElement(accessibilityContainer:surface.renderSurface)
                accessibilityElement.accessibilityLabel = "\(yValue) value"
                let frame = CGRect(x: Double(xCoord - columnWidth / 2.0), y: Double(yCoord), width: Double(columnWidth), height: Double(zeroLine - yCoord))
                accessibilityElement.accessibilityFrame = UIAccessibility.convertToScreenCoordinates(frame, in: surface.view)
                
                accessibilityElements.append(accessibilityElement)
            }
            
            surface.renderSurface.view.accessibilityElements = accessibilityElements
        }
        
        return surface
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
