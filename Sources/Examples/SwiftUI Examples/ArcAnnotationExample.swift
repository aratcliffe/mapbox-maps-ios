import MapboxMaps
import SwiftUI

/// Demonstrates how to draw a dashed curved arc between two points using `ArcAnnotation`.
///
/// The arc indicates a walking path between locations, such as from a parking area to a
/// building entrance. Pink and blue circle annotations mark the origin and destination.
struct ArcAnnotationExample: View {
    private let origin      = CLLocationCoordinate2D(latitude: 37.7654159350627,  longitude: -122.413590602335)
    private let destination = CLLocationCoordinate2D(latitude: 37.76562945703791, longitude: -122.41399208364109)

    var body: some View {
        Map(initialViewport: .camera(
            center: CLLocationCoordinate2D(
                latitude:  (origin.latitude  + destination.latitude)  / 2,
                longitude: (origin.longitude + destination.longitude) / 2
            ),
            zoom: 19,
            bearing: 85,
            pitch: 0
        )) {
            ArcAnnotation(start: origin, end: destination)

            CircleAnnotation(centerCoordinate: origin)
                .circleRadius(8)
                .circleColor(StyleColor("#FF69B4"))
                .circleStrokeWidth(2)
                .circleStrokeColor(StyleColor("#FFFFFF"))

            CircleAnnotation(centerCoordinate: destination)
                .circleRadius(8)
                .circleColor(StyleColor("#007AFF"))
                .circleStrokeWidth(2)
                .circleStrokeColor(StyleColor("#FFFFFF"))
        }
        .mapStyle(.standard)
        .ignoresSafeArea()
    }
}

#Preview {
    ArcAnnotationExample()
}
