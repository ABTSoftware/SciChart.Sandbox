package com.scichart.accessebility.helpers

import android.graphics.Rect
import android.view.accessibility.AccessibilityNodeInfo
import com.scichart.charting.visuals.SciChartSurface
import java.text.DecimalFormat

class ColumnPointNode(
    id: Int,
    private val x: Double,
    private val y: Double,
    private val surface: SciChartSurface
) :
    NodeBase(id) {
    private val bounds = Rect()
    override fun contains(x: Float, y: Float): Boolean {
        return bounds.contains(x.toInt(), y.toInt())
    }

    override fun initAccessibilityNodeInfo(nodeInfo: AccessibilityNodeInfo) {
        val xAxis = surface.xAxes[0]
        val yAxis = surface.yAxes[0]
        val xStart = xAxis.getCoordinate(x - 0.5).toInt()
        val xEnd = xAxis.getCoordinate(x + 0.5).toInt()
        val yCoord = yAxis.getCoordinate(y).toInt()
        val zeroCoord = yAxis.getCoordinate(0.0).toInt()
        bounds[xStart, yCoord, xEnd] = zeroCoord
        nodeInfo.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SELECT)
        nodeInfo.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_CLEAR_SELECTION)
        nodeInfo.packageName = javaClass.getPackage().name
        nodeInfo.className = javaClass.name
        nodeInfo.setBoundsInParent(bounds)
        nodeInfo.setParent(surface)
        val format = DecimalFormat("0.##")
        val text = String.format("Column with %s value", format.format(y))
        nodeInfo.text = text
        nodeInfo.contentDescription = text
    }
}
