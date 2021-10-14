package com.scichart.kotlinShowcase

import android.animation.FloatEvaluator
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.view.Gravity
import android.view.animation.DecelerateInterpolator
import com.scichart.charting.model.dataSeries.XyDataSeries
import com.scichart.charting.modifiers.LegendModifier
import com.scichart.charting.modifiers.SourceMode
import com.scichart.charting.visuals.SciChartSurface
import com.scichart.charting.visuals.animations.AnimationsHelper
import com.scichart.charting.visuals.animations.SweepXyTransformation
import com.scichart.charting.visuals.axes.NumericAxis
import com.scichart.charting.visuals.renderableSeries.FastLineRenderableSeries
import com.scichart.charting.visuals.renderableSeries.data.XyRenderPassData
import com.scichart.core.annotations.Orientation
import com.scichart.core.framework.UpdateSuspender
import com.scichart.core.model.DoubleValues
import com.scichart.data.model.DoubleRange
import com.scichart.drawing.common.SolidPenStyle
import com.scichart.drawing.utility.ColorUtil

class MainActivity : AppCompatActivity() {

    init {
        setUpSciChartLicense()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val context = baseContext

        val surface = findViewById<SciChartSurface>(R.id.surface)

        val xAxis = NumericAxis(context).apply {
            visibleRange = DoubleRange(0.0, 150.0)
        }

        val yAxis = NumericAxis(context).apply {
            visibleRange = DoubleRange(-1.5, 1.5)
        }

        val dataSeries1 = XyDataSeries(Double::class.javaObjectType, Double::class.javaObjectType).apply {
            seriesName = "Line A"
        }

        val dataSeries2 = XyDataSeries(Double::class.javaObjectType, Double::class.javaObjectType).apply {
            seriesName = "Line B"
        }

        val ds1Points = getStraightLine(4000.0, 1.0, 10)
        val ds2Points = getStraightLine(3000.0, 1.0, 10)

        dataSeries1.append(ds1Points!!.xValues, ds1Points.yValues)
        dataSeries2.append(ds2Points!!.xValues, ds2Points.yValues)

        val line1Color = ColorUtil.argb(0xFF, 0xFF, 0xFF, 0x00)
        val line2Color = ColorUtil.argb(0xFF, 0x27, 0x9B, 0x27)

        val line1 = FastLineRenderableSeries().apply {
            strokeStyle = SolidPenStyle(line1Color, true, 1F, null)
            dataSeries = dataSeries1
        }

        val line2 = FastLineRenderableSeries().apply {
            strokeStyle = SolidPenStyle(line2Color, true, 1F, null)
            dataSeries = dataSeries2
        }

        val legendModifier = LegendModifier(context).apply {
            setLegendPosition(Gravity.TOP or Gravity.START, 16)
            setOrientation(Orientation.VERTICAL)
            setSourceMode(SourceMode.AllSeries)
        }

        UpdateSuspender.using(surface) {
            surface.xAxes.add(xAxis)
            surface.yAxes.add(yAxis)
            surface.renderableSeries.addAll(arrayListOf(line1, line2))
            surface.chartModifiers.add(legendModifier)

            AnimationsHelper.createAnimator(line1, SweepXyTransformation(XyRenderPassData::class.java), 3000, 350, DecelerateInterpolator(), FloatEvaluator(), 0f, 1f).start()
            AnimationsHelper.createAnimator(line2, SweepXyTransformation(XyRenderPassData::class.java), 3000, 350, DecelerateInterpolator(), FloatEvaluator(), 0f, 1f).start()
        }

        surface.zoomExtents()
    }

    private fun setUpSciChartLicense() {
        try {
            SciChartSurface.setRuntimeLicenseKey("")
        } catch (e: Exception) {
            println("Error when setting the license")
        }
    }

    fun getStraightLine(gradient: Double, yIntercept: Double, pointCount: Int): DoubleSeries? {
        val doubleSeries = DoubleSeries(pointCount)
        setStraightLines(
            doubleSeries.xValues,
            doubleSeries.yValues,
            gradient,
            yIntercept,
            pointCount
        )
        return doubleSeries
    }

    fun setStraightLines(
        xValues: DoubleValues,
        yValues: DoubleValues,
        gradient: Double,
        yIntercept: Double,
        pointCount: Int
    ) {
        val xValuesArray: DoubleArray =
            getValuesArray(xValues, pointCount)
        val yValuesArray: DoubleArray =
            getValuesArray(yValues, pointCount)
        for (i in 0 until pointCount) {
            val x = (i + 1).toDouble()
            xValuesArray[i] = x
            yValuesArray[i] = gradient * x + yIntercept
        }
    }

    private fun getValuesArray(values: DoubleValues, count: Int): DoubleArray {
        values.clear()
        values.setSize(count)
        return values.itemsArray
    }
}

class DoubleSeries(capacity: Int) {
    val xValues: DoubleValues
    val yValues: DoubleValues
    fun add(x: Double, y: Double) {
        xValues.add(x)
        yValues.add(y)
    }

    init {
        xValues = DoubleValues(capacity)
        yValues = DoubleValues(capacity)
    }
}

