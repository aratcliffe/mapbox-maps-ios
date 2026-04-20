import UIKit
@_spi(Experimental) import MapboxMaps

final class CustomStyleExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 41.879, longitude: -87.635),
            zoom: 16,
            bearing: 12,
            pitch: 60)
        let options = MapInitOptions(cameraOptions: cameraOptions, styleURI: .streets)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible		
        
        
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.mapView.mapboxMap.setMapStyleContent {
                Terrain(sourceId: "mapbox-dem").exaggeration(0)
            }
            
          // Create a RasterDEMSource.
          var source = RasterDemSource(id: "hillshade-source")
          source.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
          source.tileSize = 512
          source.maxzoom = 14.0

          // Create a hillshade layer with a unique layer ID.
          var layer = HillshadeLayer(id: "hillshade-layer", source: source.id)
          
          layer.hillshadeAccentColor = .expression(Exp(.interpolate) {
              Exp(.linear)
              Exp(.zoom)
              15
              UIColor(red: 237/255.0, green: 227/255.0, blue: 227/255.0, alpha: 0.3)
              17
              UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 0.0)
          })
          layer.hillshadeAccentColorTransition = StyleTransition(duration: 0, delay: 0)
          layer.hillshadeExaggeration = .expression(Exp(.interpolate) {
              Exp(.linear)
              Exp(.zoom)
              6
              0.3
              7
              0.7
              10
              0.8
              12
              1.0
          })
          layer.hillshadeExaggerationTransition = StyleTransition(duration: 0, delay: 0)
          layer.hillshadeHighlightColor = .expression(Exp(.interpolate) {
              Exp(.linear)
              Exp(.zoom)
              15
              UIColor(red: 237/255.0, green: 227/255.0, blue: 227/255.0, alpha: 0.3)
              17
              UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 0.0)
          })
          layer.hillshadeHighlightColorTransition = StyleTransition(duration: 0, delay: 0)
          layer.hillshadeIlluminationAnchor = .constant(.viewport)
          layer.hillshadeShadowColor = .expression(Exp(.interpolate) {
              Exp(.linear)
              Exp(.zoom)
              7
              UIColor(red: 94/255.0,  green: 87/255.0,  blue: 63/255.0,  alpha: 0.8)
              12
              UIColor(red: 71/255.0,  green: 66/255.0,  blue: 46/255.0,  alpha: 0.8)
              15
              UIColor(red: 54/255.0,  green: 50/255.0,  blue: 32/255.0,  alpha: 0.8)
              16
              UIColor(red: 50/255.0,  green: 45/255.0,  blue: 36/255.0,  alpha: 0.8)
              17
              UIColor(red: 41/255.0,  green: 38/255.0,  blue: 33/255.0,  alpha: 0.8)
          })
          layer.hillshadeShadowColorTransition = StyleTransition(duration: 0, delay: 0)

          try! self.mapView.mapboxMap.addSource(source)
          try! self.mapView.mapboxMap.addLayer(layer)
        }.store(in: &cancelables)

        view.addSubview(mapView)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}

