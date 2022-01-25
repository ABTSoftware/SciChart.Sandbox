//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2019. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// SCIChartSurfaceView.swift is part of the SCICHART® Examples. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® examples are distributed in the hope that they will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SwiftUI
import SciChart

struct SCIChartSurfaceView: View {
    private var xAxes = SCIAxisCollection()
    private var yAxes = SCIAxisCollection()
    private var renderableSeries = SCIRenderableSeriesCollection()
    private var chartModifiers = SCIChartModifierCollection()
    
    private var makeSurface: (() -> SCIChartSurface)!
    private var updateSurface: ((SCIChartSurface) -> Void)!
    
    var body: some View {
        UIViewRepresentableWrapper(
            makeView: makeSurface(),
            updateView: { updateSurface($0) }
        )
    }
}

extension SCIChartSurfaceView {
    init(
        makeSurface: @escaping () -> SCIChartSurface,
        updateSurface: @escaping (SCIChartSurface) -> Void
    ) {
        self.makeSurface = makeSurface
        self.updateSurface = { surface in updateSurface(surface)}
    }
    
    init(updateSurface: @escaping (SCIChartSurface) -> Void) {
        self.makeSurface = makeDefaultSurface
        self.updateSurface = { surface in updateSurface(surface) }
    }

    init(makeSurface: @escaping @autoclosure () -> SCIChartSurface) {
        self.init(
            makeSurface: makeSurface,
            updateSurface: { _ in }
        )
    }
}

extension SCIChartSurfaceView {
    func makeDefaultSurface() -> SCIChartSurface {
        let surface = SCIChartSurface(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        SCIUpdateSuspender.usingWith(surface) {
            surface.xAxes = xAxes
            surface.yAxes = yAxes
            surface.renderableSeries = renderableSeries
            surface.chartModifiers = chartModifiers
        }

        return surface
    }
}

extension SCIChartSurfaceView {
    func xAxis(_ axis: ISCIAxis) -> SCIChartSurfaceView {
        xAxes.add(axis)
        return self
    }
    
    func yAxis(_ axis: ISCIAxis) -> SCIChartSurfaceView {
        yAxes.add(axis)
        return self
    }
    
    func renderableSeries(_ rs: ISCIRenderableSeries) -> SCIChartSurfaceView {
        renderableSeries.add(rs)
        return self
    }
    
    func modifier(_ modifier: ISCIChartModifier) -> SCIChartSurfaceView {
        chartModifiers.add(modifier)
        return self
    }
}

struct SCIChartSurfaceView_Previews: PreviewProvider {
    static var previews: some View {
        SCIChartSurfaceView()
    }
}
