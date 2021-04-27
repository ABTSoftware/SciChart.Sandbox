package com.scichart.accessebility.modifiers

import com.scichart.charting.modifiers.ZoomExtentsModifier

class AccessibleZoomExtentsModifier : ZoomExtentsModifier() {
    override fun performZoom() {
        val view = parentSurface.view
        view.announceForAccessibility("Performing zoom extents")
        super.performZoom()
    }
}