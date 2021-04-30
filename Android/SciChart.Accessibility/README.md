# Accessibility and SciChart

This is a short description on the samples we have made as a part of feasibility of the Android accessibility features (voice over in particular). Here we describe the approach we took and what have we achieved. Please find interested sections below:

- VoiceOver
- Text Size
- Color and Contrast

## Voice over(TalkBack)

We have experimented with the voice over the chart as the whole and as its parts on Android as well. For simplicity we decided to create a simple example voice over for that has columns and two numeric axes. We will also show where to add custom audio feedback for our chart modifier. We created list of messages which should be anounces through accessibility API for voice over: 

- User selects separate columns with voices over reading the values. 
- User selects axes with the voice over reading the range of the axis that is visible on the screen. 
- User zooms in chart with the voice over and perform zoom to extents. 

This example can be extended and added more messages for actions based on your requirements ( e.g. adding annotations, adding series etc ).

#### Example

First, we have created a separate a fragment which contains chart with 2 axes and column series. We have also created custom pan, pinch zoom modifier and custom zoom to extents modifier for this example. To implement the talk back functionality we have created a custom SciChart Surface, that is called AccessibleSciChartSurface. For this surface we have also created a special helper class which we attach to chart by setting it as accessibility delegate and dispatching to it hover events.

In this particular example we used one of helper classes provided by Android support library which is called ExploreByTouchHelper. This class simplifies writing [AccessibilityNodeProvider]( https://developer.android.com/reference/android/support/v4/widget/ExploreByTouchHelper) for chart. We use this class as it allows us to support virtual view hierarchy rooted. That is very helpful as we use OpenGL to render some parts of chart such as series, axis labels and this part is not represented by Android view.

See the snippet for Custom SciChart Surface below: 

```kotlin
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
```

In AccessibilityHelper we override a few methods: 

- one that allows to check if we have any accessibilities nodes below getVirtualViewAt(float x, float y); 

- another provides a list of nodes that are visible on chart; 

- and the third one allows to update accessibility node info with information about a specific node. 

Also in this helper we have list of INodes, which represents a separate logical node on a chart. 

```kotlin
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
```

Next important part are nodes themselves. In our prototype we defined INode interface, which represents separate accessibility nodes (e.g. axis, series, point, annotation etc.). It contains several methods, for example for the axis those are: get id (returns a unique node ID), contains (checks if specified point lies within -axis bounds which are defined by layoutrect) and IntAccessibilityNodeInfo(fills nodeinfo with information about the axis). Lastly the nodeInfo.setContentDescription(text); - sets text which should be used by talk back when selecting axis. 

```kotlin
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
```

The same logic applies to the node for each column. The difference in nodes for axis and columns is that for columns we needed to calculate the rect which represents column bounds. The approach is the same. Then in Fragment we create the nodes when we add new data point in dataseries, axis node for each axis and we added to the nodes collection to the Helper. 

```kotlin
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
```

In the example we have also added the voice over for modifiers like zoom pan, pinch zoom and zoom to extends. Created modifiers override methods where interaction happens and adds announces via accessibility API with the corresponding message. 

```kotlin
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
```

```kotlin
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
```

```kotlin
class AccessibleZoomExtentsModifier : ZoomExtentsModifier() {
    override fun performZoom() {
        val view = parentSurface.view
        view.announceForAccessibility("Performing zoom extents")
        super.performZoom()
    }
}
```

Finally we join everything in simple example where all classes are used:

```kotlin
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
```

## Text Size

By default, chart accepts sizes in real device pixels, but we provide SciChart Builder API that wraps this API and provides helper methods for creating styles with device independent sizes based on [DisplayMetrics](https://developer.android.com/reference/android/util/DisplayMetrics) provided by Android [Context](https://developer.android.com/reference/android/content/Context). So when you change text scaling - application's Context gets updated DisplayMetrics, and as result text size responds correctly on system font size changes. 

```java
// device independent sizes
final FastLineRenderableSeries rSeries = sciChartBuilder.newLineSeries().withDataSeries(dataSeries).withStrokeStyle(0xFF279B 27, 1f, true).build();

// device independent sizes
rSeries.setStrokeStyle(sciChartBuilder.newPen().withColor(0xFF279B27).withThickness (1).build());

// size in device pixels
rSeries.setStrokeStyle(new SolidPenStyle(0xFF279B27, true, 1, null));
```

or you can transform device independent size to pixel size on your own:

```kotlin
strokeStyle = SolidPenStyle(ColorUtil.White, true, 1f.toDip(), null)

fun Float.toDip(): Float {
    return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, this, Resources.getSystem().displayMetrics)
}
```

## Color and Contrast

Since colors and theming are most likely to be custom for each customer, we don't provide out of the box light and dark theme handling (nor special theme for High Contrast). But that's easy achievable through Android API by checking current color scheme and update theme manually using one of the provided themes, or creating custom one:

```kotlin
surface.theme = if(requireContext().isDarkThemeOn()) R.style.SciChart_SciChartv4DarkStyle else R.style.SciChart_Bright_Spark

fun Context.isDarkThemeOn(): Boolean {
    return resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == UI_MODE_NIGHT_YES
}
```
