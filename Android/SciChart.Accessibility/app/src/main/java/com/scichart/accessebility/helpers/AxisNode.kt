package com.scichart.accessebility.helpers

import android.view.accessibility.AccessibilityNodeInfo
import com.scichart.charting.visuals.SciChartSurface
import com.scichart.charting.visuals.axes.NumericAxis
import java.text.DecimalFormat

class AxisNode(private val axis: NumericAxis, id: Int) : NodeBase(id) {
    override fun contains(x: Float, y: Float): Boolean {
        return axis.layoutRect.contains(x.toInt(), y.toInt())
    }

    override fun initAccessibilityNodeInfo(nodeInfo: AccessibilityNodeInfo) {
        val parentSurface = axis.parentSurface as SciChartSurface
        nodeInfo.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SELECT)
        nodeInfo.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_CLEAR_SELECTION)
        nodeInfo.packageName = axis.context.packageName
        nodeInfo.className = axis.javaClass.name
        nodeInfo.setBoundsInParent(axis.layoutRect)
        nodeInfo.setParent(parentSurface)
        val axisName = if (axis.isXAxis) "X Axis" else "Y Axis"
        val format = DecimalFormat("0.#")
        val visibleRange = axis.visibleRange
        val min = format.format(visibleRange.min)
        val max = format.format(visibleRange.max)
        val text = String.format("%s with visible range from %s to %s", axisName, min, max)
        nodeInfo.text = text
        nodeInfo.contentDescription = text
    }
}
