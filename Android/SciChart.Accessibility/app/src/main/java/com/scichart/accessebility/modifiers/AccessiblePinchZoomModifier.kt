package com.scichart.accessebility.modifiers

import android.view.ScaleGestureDetector
import com.scichart.charting.modifiers.PinchZoomModifier

class AccessiblePinchZoomModifier : PinchZoomModifier() {
    override fun onScaleBegin(detector: ScaleGestureDetector): Boolean {
        parentSurface.view.announceForAccessibility("Begin pinch zoom scaling")
        return super.onScaleBegin(detector)
    }

    override fun onScaleEnd(detector: ScaleGestureDetector) {
        parentSurface.view.announceForAccessibility("End pinch zoom scaling")
        super.onScaleEnd(detector)
    }
}