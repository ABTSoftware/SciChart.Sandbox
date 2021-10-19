//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2019. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ChartViewModel.swift is part of the SCICHART® Examples. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® examples are distributed in the hope that they will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import Foundation
import Combine

class ChartViewModel: ObservableObject {
    private let timeInterval = 0.05
    private var time = 0.0
    private lazy var intervalPublisher = Timer.TimerPublisher(interval: timeInterval, runLoop: .main, mode: .default)
    
    private var cancellables = Set<AnyCancellable>()

    @Published var chartModel = ChartModel()
    
    init() {
        intervalPublisher
            .connect()
            .store(in: &cancellables)
        
        intervalPublisher.sink { [weak self] _ in
            self?.updateData()
        }
        .store(in: &cancellables)
    }
    
    private func updateData() {
        let y1: Double = 3.0 * sin(((2 * .pi) * 1.4) * time * 0.02)
        let y2: Double = 2.0 * cos(((2 * .pi) * 0.8) * time * 0.02)
        let y3: Double = 1.0 * sin(((2 * .pi) * 2.2) * time * 0.02)
        
        chartModel.ds1.append(x: time, y: y1)
        chartModel.ds2.append(x: time, y: y2)
        chartModel.ds3.append(x: time, y: y3)
        
        time += timeInterval
    }
}
