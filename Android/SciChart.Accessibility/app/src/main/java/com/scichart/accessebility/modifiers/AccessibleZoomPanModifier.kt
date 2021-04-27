package com.scichart.accessebility.modifiers

import android.view.MotionEvent
import com.scichart.charting.modifiers.ZoomPanModifier

class AccessibleZoomPanModifier : ZoomPanModifier() {
    override fun onScroll(e1: MotionEvent, e2: MotionEvent, xDelta: Float, yDelta: Float): Boolean {
        parentSurface.view.announceForAccessibility("Scrolling chart")
        return super.onScroll(e1, e2, xDelta, yDelta)
    }

    override fun onFling(
        e1: MotionEvent,
        e2: MotionEvent,
        velocityX: Float,
        velocityY: Float
    ): Boolean {
        parentSurface.view.announceForAccessibility("Scrolling chart")
        return super.onFling(e1, e2, velocityX, velocityY)
    }
}

