//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2022. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ChartModel.swift is part of the SCICHART® SciChart.SwiftUIShowcase App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciChart.SwiftUIShowcase App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import Foundation
import SciChart

struct ChartModel {
    let ds1 = SCIXyDataSeries(xType: .double, yType: .double)
    let ds2 = SCIXyDataSeries(xType: .double, yType: .double)
    let ds3 = SCIXyDataSeries(xType: .double, yType: .double)
    
    private let fifoCapacity: Int = 100
    
    init() {
        ds1.fifoCapacity = fifoCapacity
        ds1.seriesName = "Orange Series"
        
        ds2.fifoCapacity = fifoCapacity
        ds2.seriesName = "Blue Series"

        ds3.fifoCapacity = fifoCapacity
        ds3.seriesName = "Green Series"
    }
}
