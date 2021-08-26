import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                navigationLink(
                    title: "Line Chart",
                    destination: LineChartExample()
                )
                navigationLink(
                    title: "Column Chart",
                    destination: ColumnChartExample()
                )
                navigationLink(
                    title: "Stacked Column Chart",
                    destination: StackedColumnChartExample()
                )
            }
            .navigationBarTitle("Accessibility examples")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    func navigationLink<V: View>(title: String, destination: V) -> some View {
        NavigationLink(
            title,
            destination: destination
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        )
    }
}
