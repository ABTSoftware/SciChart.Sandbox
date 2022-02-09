//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2022. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// NSViewRepresentableWrapper.swift is part of the SCICHART® SciChart.SwiftUIShowcase App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciChart.SwiftUIShowcase App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SwiftUI

struct NSViewRepresentableWrapper<Wrapped: NSView>: NSViewRepresentable {
    typealias Updater = (Wrapped, Context) -> Void
    
    var makeView: () -> Wrapped
    var updateView: (Wrapped, Context) -> Void
    
    init(makeView: @escaping () -> Wrapped, updateView: @escaping Updater) {
        self.makeView = makeView
        self.updateView = updateView
    }
    
    func makeNSView(context: Context) -> Wrapped {
        makeView()
    }

    func updateNSView(_ view: Wrapped, context: Context) {
        updateView(view, context)
    }
}

extension NSViewRepresentableWrapper {
    init(
        makeView: @escaping @autoclosure () -> Wrapped,
        updateView: @escaping (Wrapped) -> Void
    ) {
        self.makeView = makeView
        self.updateView = { view, _ in updateView(view) }
    }
    
    init(makeView: @escaping @autoclosure () -> Wrapped) {
        self.makeView = makeView
        self.updateView = { _, _ in }
    }
}
