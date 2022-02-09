//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2022. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ContentView.swift is part of the SCICHART® SciChart.SwiftUIShowcase App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciChart.SwiftUIShowcase App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SwiftUI
import SciChart

struct ContentView: View {
    @ObservedObject var viewModel = ChartViewModel()
    
    var body: some View {
        SCIChartSurfaceView(updateSurface: { surface in
            // update surface properties on viewModel change if needed
        })
            .xAxis(xAxis)
            .yAxis(yAxis)
            .renderableSeries(rSeries1)
            .renderableSeries(rSeries2)
            .renderableSeries(rSeries3)
            .modifier(legendModifier)
            .modifier(SCISeriesValueModifier())
            .ignoresSafeArea()
    }
}

extension ContentView {
    private var xAxis: ISCIAxis {
        let xAxis = SCINumericAxis()
        xAxis.autoRange = .always
        xAxis.axisTitle = "Time (Seconds)"
        xAxis.textFormatting = "0.0"
        
        return xAxis
    }
    
    private var yAxis: ISCIAxis {
        let yAxis = SCINumericAxis()
        yAxis.autoRange = .always
        yAxis.axisTitle = "Amplitude (Volts)"
        yAxis.growBy = SCIDoubleRange(min: 0.1, max: 0.1)
        yAxis.textFormatting = "0.00"
        yAxis.cursorTextFormatting = "0.00"
        
        return yAxis
    }
}

extension ContentView {
    private var rSeries1: ISCIRenderableSeries {
        let rSeries = SCIFastLineRenderableSeries()
        rSeries.dataSeries = viewModel.chartModel.ds1
        rSeries.strokeStyle = SCISolidPenStyle(color: 0xFFFF8C00, thickness: 2)
        
        return rSeries
    }
    
    private var rSeries2: ISCIRenderableSeries {
        let rSeries = SCIFastLineRenderableSeries()
        rSeries.dataSeries = viewModel.chartModel.ds2
        rSeries.strokeStyle = SCISolidPenStyle(color: 0xFF4682B4, thickness: 2)
        
        return rSeries
    }

    private var rSeries3: ISCIRenderableSeries {
        let rSeries = SCIFastLineRenderableSeries()
        rSeries.dataSeries = viewModel.chartModel.ds3
        rSeries.strokeStyle = SCISolidPenStyle(color: 0xFF556B2F, thickness: 2)
        
        return rSeries
    }
}

extension ContentView {
    private var legendModifier: ISCIChartModifier {
        let legendModifier = SCILegendModifier()
#if os(iOS)
        legendModifier.margins = SCIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
#elseif os(macOS)
        legendModifier.margins = NSEdgeInsets(top: 46, left: 16, bottom: 0, right: 16)
#endif
        return legendModifier
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
