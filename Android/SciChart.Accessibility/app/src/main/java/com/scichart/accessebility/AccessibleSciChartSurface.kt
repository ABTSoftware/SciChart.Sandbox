package com.scichart.accessebility

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import androidx.core.view.ViewCompat
import com.scichart.accessebility.helpers.AccessibilityHelper
import com.scichart.charting.visuals.SciChartSurface

class AccessibleSciChartSurface : SciChartSurface {
    val helper: AccessibilityHelper = AccessibilityHelper(this)

    constructor(context: Context?) : super(context) {
        init()
    }

    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs) {
        init()
    }

    constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        init()
    }

    private fun init() {
        ViewCompat.setAccessibilityDelegate(this, helper)
    }

    public override fun dispatchHoverEvent(event: MotionEvent): Boolean {
        // Always attempt to dispatch hover events to accessibility first.
        return if (helper.dispatchHoverEvent(event)) {
            true
        } else super.dispatchHoverEvent(event)
    }
}