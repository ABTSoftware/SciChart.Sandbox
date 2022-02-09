//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2022. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// UIViewRepresentableWrapper.swift is part of the SCICHART® SciChart.SwiftUIShowcase App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciChart.SwiftUIShowcase App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SwiftUI

struct UIViewRepresentableWrapper<Wrapped: UIView>: UIViewRepresentable {
    typealias Updater = (Wrapped, Context) -> Void

    var makeView: () -> Wrapped
    var updateView: (Wrapped, Context) -> Void

    init(makeView: @escaping () -> Wrapped, updateView: @escaping Updater) {
        self.makeView = makeView
        self.updateView = updateView
    }

    func makeUIView(context: Context) -> Wrapped {
        makeView()
    }

    func updateUIView(_ view: Wrapped, context: Context) {
        updateView(view, context)
    }
}

extension UIViewRepresentableWrapper {
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
