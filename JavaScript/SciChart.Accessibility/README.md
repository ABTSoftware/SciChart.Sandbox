# Accessibility and SciChart

This is a short description on the samples we have made as a part of feasibility of the Android accessibility features (voice over in particular). Here we describe the approach we took and what have we achieved. Please find interested sections below:

- VoiceOver
- Color and Contrast
- Zoom and Pan with Keyboard

## Voice over

The example here demonstrates how to achieve voice over the chart elements, data, and some actions, using the Hit Test API and event subscription.

Covered cases:
- User selects axes with the voice over reading the range of the axis that is visible on the screen. 
- User clicks on a series data point with the voice over reading the coordinates of the selected point. 
- User zooms or pans chart with the voice over describing the new visible ranges of the axes.


#### Example

This example shows FastLineRenderableSeries and uses several zoom/pan Chart Modifiers. 
Voice over functionality is provided by SpeechSynthesisUtterance API.

In order to detect clicking upon the chart we added a simple event listener:

```javascript
    sciChartSurface.domCanvas2D.addEventListener("mousedown", (mouseEvent) => {
        const point = new Point(mouseEvent.offsetX, mouseEvent.offsetY);
        hitTestAxes(point);
        hitTestDataPoints(points);
    });
```

 The main logic to achieve voice over the data series consists of getting the Hit Test info of the clicked point on the renderable series and using the retrieved information to announce the point description: 

```javascript
    const hitTestDataPoints = (point) => {
        const HIT_TEST_RADIUS = 10;

        sciChartSurface.renderableSeries.asArray().forEach(rs => {
            if (rs.hitTestProvider) {
                const hitTestInfo = rs.hitTestProvider.hitTest(
                    point,
                    ENearestPointLogic.NearestHorizontalPoint,
                    HIT_TEST_RADIUS,
                    rs.type === ESeriesType.SplineLineSeries
                );

                if (hitTestInfo.isHit) {
                    const xCoordValue = rs.xAxis.labelProvider.formatLabel(hitTestInfo.hitTestPointValues.x);
                    const yCoordValue = rs.yAxis.labelProvider.formatLabel(hitTestInfo.hitTestPointValues.y);
                    const pointDescription = `Point at coordinates ${xCoordValue} and ${yCoordValue}`;
                    announceWithSpeechSynthesis(pointDescription);
                }
            }
        });
    };
```


Hit test upon axes could also be easily implemented with the following code:

```javascript
    const hitTestAxes = (point) => {
        sciChartSurface.xAxes.asArray().forEach(axis => {
            if (isPointWithinAxis(point, axis)) {
                announceAxis(axis);
            }
        });

        sciChartSurface.yAxes.asArray().forEach(axis => {
            if (isPointWithinAxis(point, axis)) {
                announceAxis(axis);
            }
        });
    }
    
    const isPointWithinAxis = (point, axis) => {
        return point.x > axis.viewRect.left && point.x < axis.viewRect.right
            && point.y > axis.viewRect.top && point.y < axis.viewRect.bottom;
    };
```

The visible range changes detection on an axis is demonstrated by the snippet below:

```javascript
    xAxis.visibleRangeChanged.subscribe((args) => {
        const { min, max } = args.visibleRange;
        const from = xAxis.labelProvider.formatLabel(min);
        const to = xAxis.labelProvider.formatLabel(max);
        const announcement = `${xAxis.axisTitle} axis range changed, now it's from ${from} to ${to}.`;
        announceWithSpeechSynthesis(announcement);
    });
```


## Color and Contrast

Since colors and theming are most likely to be custom for each customer, we don't provide out of the box light and dark theme handling (nor special theme for High Contrast). But that's easy achievable by checking current color scheme and update theme manually using one of the provided themes, or creating custom one:

```javascript
    const isDarkThemeSelected = window.matchMedia
        && window.matchMedia("(prefers-color-scheme: dark)").matches;

    const newColorScheme = isDarkThemeSelected             
        ? new SciChartJSDarkTheme() 
        : new SciChartJSLightTheme();

    sciChartSurface.applyTheme(newColorScheme)
```

It's easy to subscribe to the theme change as well:

```javascript
    const handleSystemThemeChange = (event) => {
        const newColorScheme = event.matches 
            ? new SciChartJSDarkTheme() 
            : new SciChartJSLightTheme();
        sciChartSurface.applyTheme(newColorScheme)
    };

    window.matchMedia("(prefers-color-scheme: dark)")
        .addEventListener("change", handleSystemThemeChange);
```


## Zoom and Pan with keyboard

The chart behavior is easily extendable with the use of Chart Modifiers. For this example we created a simple custom modifier (KeyboardZoomPanModifier) which adds an ability to scroll the chart with arrow buttons and to zoom with "+"/"-" buttons. The same approach can be used to add more custom keyboard bindings.