const {
    RubberBandXyZoomModifier,
    SeriesSelectionModifier,
    ZoomExtentsModifier,
    XyDataSeries,
    ECoordinateMode,
    AxisBase2D,
    NumericAxis,
    FastLineRenderableSeries,
    ENearestPointLogic,
    SciChartSurface,
    EllipsePointMarker,
    RolloverModifier,
    ZoomPanModifier,
    MouseWheelZoomModifier,
    NumberRange,
    Point,
    EAxisAlignment,
    ESeriesType,
    EColor,
    SciChartJSDarkTheme,
    SciChartJSLightTheme,
    EClipMode, 
    EXyDirection
} = SciChart;


// Configure where to load wasm files
SciChart.SciChartSurface.configure({
    wasmUrl: "https://cdn.jsdelivr.net/npm/scichart@1.4.1609/_wasm/scichart2d.wasm",
    dataUrl: "https://cdn.jsdelivr.net/npm/scichart@1.4.1609/_wasm/scichart2d.data"
});

const divElementId = "scichart-root";

async function initSciChart() {
    const { wasmContext, sciChartSurface } = await SciChart.SciChartSurface.create(divElementId);

    const xAxis = new NumericAxis(wasmContext, { growBy: new NumberRange(0.05, 0.05) });
    xAxis.axisTitle = "Horizontal Axis";
    xAxis.labelProvider.precision = 0;
    sciChartSurface.xAxes.add(xAxis);

    const yAxis = new NumericAxis(wasmContext, { growBy: new NumberRange(0.1, 0.1) });
    yAxis.axisTitle = "Vertical Axis";
    sciChartSurface.yAxes.add(yAxis);

    const colorsArr = [EColor.Blue, EColor.LightGrey, EColor.Green, EColor.DarkRed, EColor.Orange, EColor.Red];

    const createDataSeries = (wasmContext, index, options) => {
        const sigma = Math.pow(0.6, index);
        const dataSeries = new XyDataSeries(wasmContext, options);
        for (let i = 0; i < 100; i++) {
            const grow = 1 + i / 99;
            dataSeries.append(i, Math.sin((Math.PI * i) / 15) * grow * sigma);
        }
        return dataSeries;
    };

    const seriesData = createDataSeries(wasmContext, 0, { dataSeriesName: "Sinewave A" });

    const renderableSeries = new FastLineRenderableSeries(wasmContext, {
        stroke: colorsArr[0],
        strokeThickness: 3,
        dataSeries: seriesData,
        pointMarker: new EllipsePointMarker(wasmContext, {
            width: 5,
            height: 5,
            strokeThickness: 2,
            fill: "white",
            stroke: colorsArr[0]
        }),
        isVisible: true
    });
    renderableSeries.rolloverModifierProps.tooltipColor = colorsArr[0];
    renderableSeries.rolloverModifierProps.markerColor = colorsArr[0];
    sciChartSurface.renderableSeries.add(renderableSeries);

    sciChartSurface.chartModifiers.add(
        new RolloverModifier(),
        new ZoomPanModifier(),
        new ZoomExtentsModifier(),
        new MouseWheelZoomModifier(),
        new KeyboardZoomPanModifier(),
    );

    sciChartSurface.zoomExtents();


    const announceYRangeChange = debounce(announceWithSpeechSynthesis);
    const announceXRangeChange = debounce(announceWithSpeechSynthesis);

    // add announcement of axis range changes
    yAxis.visibleRangeChanged.subscribe((args) => {
        const { min, max } = args.visibleRange;
        const from = yAxis.labelProvider.formatLabel(min);
        const to = yAxis.labelProvider.formatLabel(max);
        const announcement = `${yAxis.axisTitle} axis range changed, now it's from ${from} to ${to}.`;
        announceYRangeChange(announcement);
    });

    xAxis.visibleRangeChanged.subscribe((args) => {
        const { min, max } = args.visibleRange;
        const from = xAxis.labelProvider.formatLabel(min);
        const to = xAxis.labelProvider.formatLabel(max);
        const announcement = `${xAxis.axisTitle} axis range changed, now it's from ${from} to ${to}.`;
        announceXRangeChange(announcement);
    });

    return { wasmContext, sciChartSurface };
};

initSciChart().then(({sciChartSurface}) => {
    // focus on scichart root to allow scichart detect keyboard events
    sciChartSurface.domChartRoot.focus();

    // adde voice over for data points and axes
    sciChartSurface.domCanvas2D.addEventListener("mousedown", (mouseEvent) => {
        const point = new Point(mouseEvent.offsetX, mouseEvent.offsetY);
        hitTestAxes(point);
        hitTestDataPoints(point);
    });

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

    const isPointWithinAxis = (point, axis) => {
        return point.x > axis.viewRect.left && point.x < axis.viewRect.right
            && point.y > axis.viewRect.top && point.y < axis.viewRect.bottom;
    };

    const announceAxis = (axis) => {
        const from = axis.labelProvider.formatLabel(axis.visibleRange.min);
        const to = axis.labelProvider.formatLabel(axis.visibleRange.max);
        const axisDescription = `${axis.axisTitle} with visible range from ${from} to ${to} `;
        announceWithSpeechSynthesis(axisDescription);
    }


    // Apply system defined theme
    const isDarkThemeSelected = window.matchMedia
        && window.matchMedia("(prefers-color-scheme: dark)").matches;

    const newColorScheme = isDarkThemeSelected             
        ? new SciChartJSDarkTheme() 
        : new SciChartJSLightTheme();

    sciChartSurface.applyTheme(newColorScheme)

    const handleSystemThemeChange = (event) => {
        const newColorScheme = event.matches 
            ? new SciChartJSDarkTheme() 
            : new SciChartJSLightTheme();
        sciChartSurface.applyTheme(newColorScheme)
    };

    window.matchMedia("(prefers-color-scheme: dark)")
        .addEventListener("change", handleSystemThemeChange);
});

const announceWithSpeechSynthesis = (announcement) => {
    console.log(announcement)
    const synthDescription = new SpeechSynthesisUtterance(announcement);
    window.speechSynthesis.speak(synthDescription);
};

const debounce = (func, timeout = 1000) => {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => func(...args), timeout);
    };
};



class KeyboardZoomPanModifier extends SciChart.PinchZoomModifier {
    constructor(options) {
        super(options);
        this.growFactor = options?.growFactor ?? 0.001;
        this.scrollFactor = options?.scrollFactor ?? 0.001;

        this.handleKeyDown = this.handleKeyDown.bind(this);
    }

    scroll(xDelta, yDelta) {
        if ([EXyDirection.XDirection, EXyDirection.XyDirection].includes(this.xyDirection)) {
            this.parentSurface.xAxes.asArray().forEach(x => {
                const delta = (x.isHorizontalAxis ? xDelta : -yDelta) * this.scrollFactor;
                x.scroll(x.flippedCoordinates ? -delta : delta, EClipMode.None);
            });
        }
        if ([EXyDirection.YDirection, EXyDirection.XyDirection].includes(this.xyDirection)) {
            this.parentSurface.yAxes.asArray().forEach(y => {
                const delta = (y.isHorizontalAxis ? -xDelta : yDelta) * this.scrollFactor;
                y.scroll(y.flippedCoordinates ? -delta : delta, EClipMode.None);
            });
        }
    }

    onAttach() {
        // set tabIndex attribute of the chart root element if it was not set externally
        this.parentSurface.domChartRoot.tabIndex = this.parentSurface.domChartRoot.tabIndex ?? 0;

        // subscribe to keyboard input event
        // this.parentSurface.domChartRoot.addEventListener("keydown", this.handleKeyDown);
        document.addEventListener("keydown", this.handleKeyDown);
    }

    onDetach() {
        // unsubscribe from keyboard input event
        // this.parentSurface.domChartRoot.removeEventListener("keydown", this.handleKeyDown);
        document.removeEventListener("keydown", this.handleKeyDown);
    }

    /**
     * Performs the zoom operation around the mouse point
     * @param mousePoint The X,Y location of the mouse at the time of the zoom
     * @param delta the delta factor of zoom
     */
    performZoom(mousePoint, delta) {
        const fraction = this.growFactor * delta;
        if ([EXyDirection.XDirection, EXyDirection.XyDirection].includes(this.xyDirection)) {
            this.parentSurface.xAxes.asArray().forEach(axis => {
                this.growBy(mousePoint, axis, fraction);
            });
        }
        if ([EXyDirection.YDirection, EXyDirection.XyDirection].includes(this.xyDirection)) {
            this.parentSurface.yAxes.asArray().forEach(axis => {
                this.growBy(mousePoint, axis, fraction);
            });
        }
    }

    handleKeyDown(event) {
        // ignore key combinations
        if (event.ctrlKey || event.altKey || event.metaKey) {
            return;
        }

        const DEFAULT_SCROLL_DELTA = 100;
        const DEFAULT_ZOOM_DELTA = 120;

        switch (event.key) {
            case "ArrowUp":
                this.scroll(0, DEFAULT_SCROLL_DELTA);
                break;
            case "ArrowDown":
                this.scroll(0, -DEFAULT_SCROLL_DELTA);
                break;
            case "ArrowRight":
                this.scroll(DEFAULT_SCROLL_DELTA, 0);
                break;
            case "ArrowLeft":
                this.scroll(-DEFAULT_SCROLL_DELTA, 0);
                break;
            case "+": {
                const zoomPoint = new Point(this.parentSurface.seriesViewRect.width / 2, this.parentSurface.seriesViewRect.height / 2);
                this.performZoom(zoomPoint, -DEFAULT_ZOOM_DELTA);
                break;
            }
            case "-": {
                const zoomPoint = new Point(this.parentSurface.seriesViewRect.width / 2, this.parentSurface.seriesViewRect.height / 2);
                this.performZoom(zoomPoint, DEFAULT_ZOOM_DELTA);
                break;
            }
            default:
                return;
        }

        // prevent default behavior if the key is used by the modifier
        event.preventDefault();
    }
}
