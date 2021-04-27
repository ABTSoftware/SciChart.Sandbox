package com.scichart.accessebility.helpers

import android.os.Bundle
import android.view.View
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat
import androidx.customview.widget.ExploreByTouchHelper
import com.scichart.charting.visuals.SciChartSurface
import java.util.*

class AccessibilityHelper(surface: SciChartSurface) : ExploreByTouchHelper(surface) {
    val nodes = ArrayList<INode>()
    override fun getVirtualViewAt(x: Float, y: Float): Int {
        var i = 0
        val size = nodes.size
        while (i < size) {
            val node = nodes[i]
            if (node.contains(x, y)) {
                return node.getId()
            }
            i++
        }
        return View.NO_ID
    }

    override fun getVisibleVirtualViews(virtualViewIds: MutableList<Int>) {
        var i = 0
        val size = nodes.size
        while (i < size) {
            val node = nodes[i]
            virtualViewIds.add(node.getId())
            i++
        }
    }

    override fun onPopulateNodeForVirtualView(
        virtualViewId: Int,
        accessibilityNodeInfoCompat: AccessibilityNodeInfoCompat
    ) {
        var i = 0
        val size = nodes.size
        while (i < size) {
            val node = nodes[i]
            if (node.getId() == virtualViewId) {
                node.initAccessibilityNodeInfo(accessibilityNodeInfoCompat.unwrap())
            }
            i++
        }
    }

    override fun onPerformActionForVirtualView(
        virtualViewId: Int,
        action: Int,
        arguments: Bundle?
    ): Boolean {
        // no need to override this without using some custom actions
        return false
    }
}
