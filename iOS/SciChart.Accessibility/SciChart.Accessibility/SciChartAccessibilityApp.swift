import SwiftUI
import SciChart

@main
struct SciChartAccessibilityApp: App {
    
    init() {
        SciChartLicenseHelper.activate()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
