//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2019. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ChartView.swift is part of the SCICHART® Examples. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® examples are distributed in the hope that they will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SwiftUI
import SciChart

struct ChartView: UIViewRepresentable {
    @ObservedObject var viewModel = ChartViewModel()
    
    init() {
        SCIChartSurface.setRuntimeLicenseKey("")
    }
    
    func makeUIView(context: Context) -> SCIChartSurface {
        let surface = SCIChartSurface()
        
        let xAxis = SCINumericAxis()
        xAxis.autoRange = .always
        xAxis.axisTitle = "Time (Seconds)"
        xAxis.textFormatting = "0.0"
        
        let yAxis = SCINumericAxis()
        yAxis.autoRange = .always
        yAxis.axisTitle = "Amplitude (Volts)"
        yAxis.growBy = SCIDoubleRange(min: 0.1, max: 0.1)
        yAxis.textFormatting = "0.00"
        yAxis.cursorTextFormatting = "0.00"
        
        let rSeries1 = SCIFastLineRenderableSeries()
        rSeries1.dataSeries = viewModel.chartModel.ds1
        rSeries1.strokeStyle = SCISolidPenStyle(color: 0xFFFF8C00, thickness: 2)
        
        let rSeries2 = SCIFastLineRenderableSeries()
        rSeries2.dataSeries = viewModel.chartModel.ds2
        rSeries2.strokeStyle = SCISolidPenStyle(color: 0xFF4682B4, thickness: 2)
        
        let rSeries3 = SCIFastLineRenderableSeries()
        rSeries3.dataSeries = viewModel.chartModel.ds3
        rSeries3.strokeStyle = SCISolidPenStyle(color: 0xFF556B2F, thickness: 2)
        
        let legendModifier = SCILegendModifier()
        legendModifier.margins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        SCIUpdateSuspender.usingWith(surface) {
            surface.xAxes.add(xAxis)
            surface.yAxes.add(yAxis)
            surface.renderableSeries.add(rSeries1)
            surface.renderableSeries.add(rSeries2)
            surface.renderableSeries.add(rSeries3)
            surface.chartModifiers.add(items: SCISeriesValueModifier(), legendModifier)
        }
        
        return surface
    }
    
    func updateUIView(_ uiView: SCIChartSurface, context: Context) {}
}
