import SwiftUI
import SciChart

struct StackedColumnChartExample: View {
    var body: some View {
        StackedColumnChartView()
    }
}

struct StackedColumnChartView: UIViewRepresentable {

    func makeUIView(context: Context) -> SCIChartSurface {
        let surface = SCIChartSurface()
        
        let xAxis = SCINumericAxis()
        let yAxis = SCINumericAxis()
        
        let porkData = [10, 13, 7, 16]
        let vealData = [12, 17, 21, 15]
        let tomatoesData = [7, 30, 27, 24]

        let ds1 = SCIXyDataSeries(xType: .double, yType: .double)
        ds1.seriesName = "Blue"
        let ds2 = SCIXyDataSeries(xType: .double, yType: .double)
        ds2.seriesName = "Orange"
        let ds3 = SCIXyDataSeries(xType: .double, yType: .double)
        ds3.seriesName = "Red"
        
        let data = 1992
        for i in 0 ..< porkData.count {
            let xValue = data + i;
            ds1.append(x: xValue, y: porkData[i])
            ds2.append(x: xValue, y: vealData[i])
            ds3.append(x: xValue, y: tomatoesData[i])
        }
        
        let verticalCollection1 = SCIVerticallyStackedColumnsCollection()
        verticalCollection1.add(getRenderableSeriesWith(dataSeries: ds1, fillColor: 0xff226fb7))
        verticalCollection1.add(getRenderableSeriesWith(dataSeries: ds2, fillColor: 0xffff9a2e))
        
        let verticalCollection2 = SCIVerticallyStackedColumnsCollection()
        verticalCollection2.add(getRenderableSeriesWith(dataSeries: ds3, fillColor: 0xffdc443f))
        
        let columnCollection = SCIHorizontallyStackedColumnsCollection()
        columnCollection.add(verticalCollection1)
        columnCollection.add(verticalCollection2)
     
        SCIUpdateSuspender.usingWith(surface) {
            surface.xAxes.add(xAxis)
            surface.yAxes.add(yAxis)
            surface.renderableSeries.add(columnCollection)
            surface.chartModifiers.add(items: SCIZoomExtentsModifier(), SCIPinchZoomModifier(), SCIZoomPanModifier())
        }
        
        xAxis.visibleRangeChangeListener = { (_, _, range, _) in
            let announsment = "X Axis range changed, now it's \(range.format())"
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announsment)
        }
        
        yAxis.visibleRangeChangeListener = { (_, _, range, _) in
            let announsment = "Y Axis range changed, now it's \(range.format())"
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announsment)
        }
        
        surface.setRenderedListener { (surface, _) in
            guard let surface = surface else { return }
        
            let series = surface.provideSeriesForAccessibility()
            guard series.count > 0 else { return }
            
            let pointsCount = series[0].currentRenderPassData.pointsCount
            
            var accessibilityElements = [UIAccessibilityElement]()
            for i in 0 ..< pointsCount {
                for rSeries in series {
                    let dataSeries = rSeries.dataSeries as! SCIXyDataSeries
                    let rpd = rSeries.currentRenderPassData as! SCIStackedColumnRenderPassData
                    let columnWidth = rpd.columnPixelWidth
                    
                    let yValue = rpd.yValues.getValueAt(i)

                    // Coordinates is taken from renderPassData
                    // because x and y are shifted - Horizontally and Vertically respectivelly
                    let xCoord = rpd.xCoords.getValueAt(i)
                    let yCoord = rpd.yCoords.getValueAt(i)
                    let zeroLine = rpd.prevSeriesYCoords.getValueAt(i)
                    
                    let accessibilityElement = UIAccessibilityElement(accessibilityContainer:surface.renderSurface)
                    accessibilityElement.accessibilityLabel = "\(yValue) value in \(dataSeries.seriesName!.description) series"
                    let frame = CGRect(x: Double(xCoord - columnWidth / 2.0), y: Double(yCoord), width: Double(columnWidth), height: Double(zeroLine - yCoord))
                    accessibilityElement.accessibilityFrame = UIAccessibility.convertToScreenCoordinates(frame, in: surface.view)
                    
                    accessibilityElements.append(accessibilityElement)
                }
            }
            
            surface.renderSurface.view.accessibilityElements = accessibilityElements
        }
        
        return surface
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    private func getRenderableSeriesWith(dataSeries: SCIXyDataSeries, fillColor: UInt32) -> SCIStackedColumnRenderableSeries {
        let rSeries = SCIStackedColumnRenderableSeries()
        rSeries.dataSeries = dataSeries
        rSeries.fillBrushStyle = SCISolidBrushStyle(color: fillColor)
        rSeries.strokeStyle = SCISolidPenStyle(color: fillColor, thickness: 1.0)
        
        SCIAnimations.wave(rSeries, duration: 3.0, andEasingFunction: SCICubicEase())
        
        return rSeries
    }
}

// Using series from legend data source, to get all nested series in one collection
// instead of Horizontally or Vertically stacks
fileprivate extension ISCIChartSurface {
    func provideSeriesForAccessibility() -> [ISCIRenderableSeries] {
        let result = NSMutableArray()
        let renderableSeries = self.renderableSeries
        for i in 0 ..< renderableSeries.count {
            let rSeries = renderableSeries[i]
            rSeries.seriesInfoProvider.tryAddSeries(toLegendDataSource: result)
        }
    
        return result as! [ISCIRenderableSeries]
    }
}
