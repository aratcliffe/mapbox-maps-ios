import CoreLocation
@_spi(Experimental) import MapboxMaps
import SwiftUI
import Turf

struct FilterExample: View {

    @State private var showFeatures: Bool = true

    private let sourceID = "sf-timestamp-data"
    private let layerID = "sf-points-layer"

    private let sfData: FeaturesRef = FilterExample.makeSanFranciscoFeatures()

    private let nov20Timestamp: Double =
        {
            let dateComponents = DateComponents(
                year: 2025,
                month: 11,
                day: 20,
                hour: 0,
                minute: 0,
                second: 0
            )
            return Calendar.current.date(from: dateComponents)?
                .timeIntervalSince1970 ?? 0 * 1000
        }() * 1000

    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .top) {
                Map(
                    initialViewport: .camera(
                        center: CLLocationCoordinate2D(
                            latitude: 37.77,
                            longitude: -122.43
                        ),
                        zoom: 10
                    )
                ) {
                    LazyGeoJSON(id: sourceID, features: sfData)

                    CircleLayer(id: layerID, source: sourceID)
                        .circleRadius(10.0)
                        .circleStrokeColor(.black)
                        .circleStrokeWidth(1.5)
                        .circleColor(UIColor.blue)
                        .filter(
                            Exp(.lt) {
                                Exp(.get) { "timestamp" }
                                nov20Timestamp
                            }
                        )

                }
                .onChange(of: showFeatures) {
                    try? proxy.map?.setLayerProperty(
                        for: layerID,
                        property: "visibility",
                        value: showFeatures ? "visible" : "none"
                    )
                }
                .ignoresSafeArea()
                HStack(spacing: 12) {
                    Text("Show/Hide Features")
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .medium))

                    Toggle("", isOn: $showFeatures)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(
                    EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
                )
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(.top, 20)
            }
        }
    }

    private static func makeSanFranciscoFeatures() -> FeaturesRef {
        let baseDate = Date()
        let dayInMs: Double = 24 * 60 * 60 * 1000.0

        let timestamps: [Double] = [
            baseDate.addingTimeInterval(-7 * dayInMs / 1000)
                .timeIntervalSince1970 * 1000,
            baseDate.addingTimeInterval(-5 * dayInMs / 1000)
                .timeIntervalSince1970 * 1000,
            baseDate.addingTimeInterval(-3 * dayInMs / 1000)
                .timeIntervalSince1970 * 1000,
            baseDate.addingTimeInterval(-1 * dayInMs / 1000)
                .timeIntervalSince1970 * 1000,
            baseDate.timeIntervalSince1970 * 1000,
        ]

        let sfCoordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 37.788, longitude: -122.407),
            CLLocationCoordinate2D(latitude: 37.785, longitude: -122.404),
            CLLocationCoordinate2D(latitude: 37.791, longitude: -122.394),
            CLLocationCoordinate2D(latitude: 37.779, longitude: -122.418),
            CLLocationCoordinate2D(latitude: 37.795, longitude: -122.394),
        ]

        let features: [Feature] = zip(sfCoordinates, timestamps).enumerated()
            .map { (index, element) in
                let (coordinate, timestamp) = element
                let category = index % 2 == 0 ? "restaurant" : "bar"
                var feature = Feature(geometry: Point(coordinate))
                feature.properties = [
                    "name": .string("SF Location \(index + 1)"),
                    "timestamp": .number(timestamp),
                    "category": .string(category),
                ]
                return feature
            }

        return FeaturesRef(features)
    }
}

#Preview {
    FilterExample()
}
