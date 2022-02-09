import SciChart

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension ISCIRange {
    func format() -> String {
        let format = ".1"
        let min = self.min.toDouble()
        let max = self.max.toDouble()
        
        return "from \(min.format(f: format)) to \(max.format(f: format))"
    }
}

extension SCIChartSurface {
    open override var accessibilityElements: [Any]? {
        get {
            var elements = [Any]()
            elements.append(self.renderSurface)
            elements.append(contentsOf: self.xAxes.toArray())
            elements.append(contentsOf: self.yAxes.toArray())
            
            return elements
        }
        set { super.accessibilityElements = newValue }
    }
    open override func accessibilityElementCount() -> Int {
        return self.accessibilityElements!.count
    }
    open override func accessibilityElement(at index: Int) -> Any? {
        return self.accessibilityElements![index]
    }
    
    open override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            return [
                UIAccessibilityCustomAction(
                    name: "Zoom to Extents",
                    target: self,
                    selector: #selector(zoomExtentsCustomAction)
                ),
                UIAccessibilityCustomAction(
                    name: "Animate Zoom to Extents",
                    target: self,
                    selector: #selector(animatedZoomExtentsCustomAction)
                )
            ]
        }
        set { super.accessibilityCustomActions = newValue }
    }
    
    @objc
    func zoomExtentsCustomAction() {
        self.zoomExtents()
        
        let announsment = "Surface has just been zoomed to it's extents"
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announsment)
    }
    
    @objc
    func animatedZoomExtentsCustomAction() {
        self.animateZoomExtents(withDuration: 1.0)
        
        let announsment = "Surface has just been animated to it's extents"
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announsment)
    }
    
    open override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        let size = self.frame.size
        switch direction {
        case .left:
            let axis = self.xAxes.defaultAxis
            axis.scroll(byPixels: -size.width / 2, clipMode: .none)
            return true
        case .right:
            let axis = self.xAxes.defaultAxis
            axis.scroll(byPixels: size.width / 2, clipMode: .none)
            return true
        case .up:
            let axis = self.yAxes.defaultAxis
            axis.scroll(byPixels: -size.height / 2, clipMode: .none)
            return true
        case .down:
            let axis = self.yAxes.defaultAxis
            axis.scroll(byPixels: size.height / 2, clipMode: .none)
            return true
        default:
            break
        }
        
        return false
    }
}

extension SCIAxisBase {
    open override var accessibilityLabel: String? {
        get { return "\(self.isXAxis ? "X" : "Y") Axis with visible range \(self.visibleRange.format())" }
        set { super.accessibilityLabel = newValue }
    }
    open override var accessibilityFrame: CGRect {
        get { return UIAccessibility.convertToScreenCoordinates(self.layoutRect, in: self.parentSurface!.view) }
        set { super.accessibilityFrame = newValue }
    }
    open override var isAccessibilityElement: Bool {
        get { return true }
        set { super.isAccessibilityElement = newValue }
    }
}
