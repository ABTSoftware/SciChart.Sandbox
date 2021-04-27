package com.scichart.accessebility

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.accessibility.AccessibilityEvent
import androidx.fragment.app.Fragment
import com.scichart.accessebility.databinding.AccessibilityExampleFragmentBinding
import com.scichart.accessebility.helpers.AxisNode
import com.scichart.accessebility.helpers.ColumnPointNode
import com.scichart.accessebility.helpers.INode
import com.scichart.accessebility.modifiers.AccessiblePinchZoomModifier
import com.scichart.accessebility.modifiers.AccessibleZoomExtentsModifier
import com.scichart.accessebility.modifiers.AccessibleZoomPanModifier
import com.scichart.charting.model.dataSeries.IXyDataSeries
import com.scichart.charting.model.dataSeries.XyDataSeries
import com.scichart.charting.modifiers.ModifierGroup
import com.scichart.charting.visuals.axes.NumericAxis
import com.scichart.charting.visuals.renderableSeries.FastColumnRenderableSeries
import com.scichart.core.framework.UpdateSuspender
import com.scichart.data.model.DoubleRange
import com.scichart.drawing.common.LinearGradientBrushStyle
import com.scichart.drawing.common.SolidPenStyle
import com.scichart.drawing.utility.ColorUtil
import java.util.*

/**
 * A simple [Fragment] subclass as the default destination in the navigation.
 */
class AccessibilityExampleFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val binding = AccessibilityExampleFragmentBinding.inflate(inflater, container, false)

        initExample(binding)

        return binding.root
    }

    private fun initExample(binding: AccessibilityExampleFragmentBinding) {
        val xAxis: NumericAxis = NumericAxis(context).apply {
            growBy = DoubleRange(0.1, 0.1)
        }
        val yAxis: NumericAxis = NumericAxis(context).apply {
            growBy = DoubleRange(0.0, 0.1)
        }

        val surface: AccessibleSciChartSurface = binding.surface
        val nodes: ArrayList<INode> = surface.helper.nodes

        val ds: IXyDataSeries<Int, Int> = XyDataSeries<Int, Int>(
            Int::class.javaObjectType,
            Int::class.javaObjectType
        ).apply {
            seriesName = "Column chart"
        }

        val yValues = intArrayOf(50, 35, 61, 58, 50, 50, 40, 53, 55, 23, 45, 12, 59, 60)

        for (i in yValues.indices) {
            val yValue = yValues[i]
            ds.append(i, yValue)

            nodes.add(ColumnPointNode(i, i.toDouble(), yValue.toDouble(), surface))
        }

        val rSeries: FastColumnRenderableSeries = FastColumnRenderableSeries().apply {
            strokeStyle = SolidPenStyle(ColorUtil.White, true, 1f, null)
            dataPointWidth = 0.7
            fillBrushStyle = LinearGradientBrushStyle(
                0f,
                0f,
                1f,
                1f,
                ColorUtil.LightSteelBlue,
                ColorUtil.SteelBlue
            )
            dataSeries = ds
        }

        UpdateSuspender.using(surface) {
            surface.xAxes.add(xAxis)
            surface.yAxes.add(yAxis)
            surface.renderableSeries.add(rSeries)
            val pinchZoomModifier = AccessiblePinchZoomModifier()
            val zoomPanModifier = AccessibleZoomPanModifier().apply {
                receiveHandledEvents = true
            }
            val zoomExtentsModifier = AccessibleZoomExtentsModifier()
            surface.chartModifiers.add(
                ModifierGroup(pinchZoomModifier, zoomPanModifier, zoomExtentsModifier)
            )
        }

        val xAxisNode = AxisNode(xAxis, nodes.size)
        nodes.add(xAxisNode)

        val yAxisNode = AxisNode(yAxis, nodes.size)
        nodes.add(yAxisNode)

        xAxis.setVisibleRangeChangeListener { axis, oldRange, newRange, isAnimating -> // need to send this even to update position of rects on screen during scrolling
            surface.sendAccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED)
        }

        yAxis.setVisibleRangeChangeListener { axis, oldRange, newRange, isAnimating -> // need to send this even to update position of rects on screen during scrolling
            surface.sendAccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED)
        }
    }
}