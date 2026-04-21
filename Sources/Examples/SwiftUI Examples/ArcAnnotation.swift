import CoreLocation
import MapboxMaps
import Turf

/// A reusable map style component that draws a dashed curved arc between two coordinates.
///
/// The arc uses a quadratic Bézier curve with a perpendicular control point scaled
/// to the distance between the points, producing a subtle curve that grows proportionally.
///
/// - Parameters:
///   - start: The origin coordinate.
///   - end: The destination coordinate.
///   - id: A stable identifier for the underlying source and layer. Defaults to a value
///     derived from the coordinates, which is stable across re-renders for fixed endpoints.
///   - lineColor: The stroke color of the arc. Defaults to `#007afc` blue.
///   - lineWidth: The stroke width in pixels. Defaults to `3.0`.
///   - lineOpacity: The opacity of the arc (0.0–1.0). Defaults to `0.8`.
///   - lineDashArray: Dash pattern as `[dashLength, gapLength]` in multiples of line width.
///     Defaults to `[4.0, 2.0]`.
///   - slot: The slot in which to place the arc layer. Use `Slot(rawValue:)` with Standard style
///     slot names (`"bottom"`, `"middle"`, `"top"`), or a custom `Slot` from a `SlotLayer`.
///     Defaults to `nil` (declaration order).
struct ArcAnnotation: MapStyleContent {
    var start: CLLocationCoordinate2D
    var end: CLLocationCoordinate2D
    var lineColor: StyleColor
    var lineWidth: Double
    var lineOpacity: Double
    var lineDashArray: [Double]
    var layerSlot: Slot?
    
    private let arcID: String
    
    init(
        start: CLLocationCoordinate2D,
        end: CLLocationCoordinate2D,
        id: String? = nil,
        lineColor: StyleColor = StyleColor("#007AFC"),
        lineWidth: Double = 3.0,
        lineOpacity: Double = 0.8,
        lineDashArray: [Double] = [4.0, 2.0],
        slot: Slot? = nil
    ) {
        self.start = start
        self.end = end
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.lineOpacity = lineOpacity
        self.lineDashArray = lineDashArray
        self.layerSlot = slot
        self.arcID = id ?? "\(start.latitude),\(start.longitude)-\(end.latitude),\(end.longitude)"
    }
    
    var body: some MapStyleContent {
        let coordinates = computeArcPoints(from: start, to: end)
        
        GeoJSONSource(id: "arc-source-\(arcID)")
            .data(.geometry(.lineString(LineString(coordinates))))
        
        makeLineLayer()
    }
    
    private func makeLineLayer() -> LineLayer {
        var layer = LineLayer(id: "arc-layer-\(arcID)", source: "arc-source-\(arcID)")
        layer.lineColor = .constant(lineColor)
        layer.lineWidth = .constant(lineWidth)
        layer.lineOpacity = .constant(lineOpacity)
        layer.lineDasharray = .constant(lineDashArray)
        layer.lineCap = .constant(.round)
        layer.lineJoin = .constant(.round)
        layer.lineEmissiveStrength = .constant(1.0)
        layer.slot = layerSlot
        return layer
    }
}

/// Computes 101 points along a quadratic Bézier arc between `start` and `end`.
///
/// Arc height scales with distance: 35% for <10 m, 25% for <100 m, capped at 5% (max 8 m) beyond that.
/// The control point is offset perpendicular to the line, with direction determined by the
/// relative orientation of the two coordinates.
private func computeArcPoints(
    from start: CLLocationCoordinate2D,
    to end: CLLocationCoordinate2D
) -> [CLLocationCoordinate2D] {
    let distanceMeters = start.distance(to: end)
    
    let arcHeight: Double
    switch distanceMeters {
    case ..<10:  arcHeight = distanceMeters * 0.35
    case ..<100: arcHeight = distanceMeters * 0.25
    default:     arcHeight = min(distanceMeters * 0.05, 8.0)
    }
    
    let mid = CLLocationCoordinate2D(
        latitude: (start.latitude + end.latitude) / 2,
        longitude: (start.longitude + end.longitude) / 2
    )
    let lineBearing = start.direction(to: end)
    
    // Normalize bearing to 0..<360 range
    var normalizedBearing = lineBearing
    if normalizedBearing < 0 {
        normalizedBearing += 360.0
    }
    
    // Apply the quadrant rules for convex/concave arcs
    let offsetAngle: Double
    switch normalizedBearing {
    case 0..<90:
        offsetAngle = 90.0
    case 90..<180:
        offsetAngle = -90.0
    case 180..<270:
        offsetAngle = 90.0
    default:
        offsetAngle = -90.0
    }
    
    let control = mid.coordinate(at: arcHeight, facing: lineBearing + offsetAngle)
    
    var points: [CLLocationCoordinate2D] = []
    for i in 0...100 {
        let t = Double(i) / 100.0
        let mt = 1.0 - t
        let lat = mt * mt * start.latitude  + 2 * mt * t * control.latitude  + t * t * end.latitude
        let lng = mt * mt * start.longitude + 2 * mt * t * control.longitude + t * t * end.longitude
        points.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
    }
    return points
}
