package com.scichart.accessebility.helpers

import android.view.accessibility.AccessibilityNodeInfo

interface INode {
    /**
     * Gets unique id of the node
     */
    fun getId(): Int

    /**
     * Checks whether specified point lies withing this node
     */
    fun contains(x: Float, y: Float): Boolean

    /**
     * Inits [AccessibilityNodeInfo] with information about this node
     */
    fun initAccessibilityNodeInfo(nodeInfo: AccessibilityNodeInfo)
}