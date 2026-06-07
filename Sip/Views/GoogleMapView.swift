import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    @Binding var camera: GMSCameraPosition
    @Binding var markers: [GMSMarker]
    var showsUserLocation: Bool = true
    var onMarkerTap: ((GMSMarker) -> Bool)?

    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = camera
        let mapView = GMSMapView(options: options)
        mapView.isMyLocationEnabled = showsUserLocation
        mapView.settings.myLocationButton = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.animate(to: camera)
        mapView.clear()
        for marker in markers {
            marker.map = mapView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onMarkerTap: onMarkerTap)
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var onMarkerTap: ((GMSMarker) -> Bool)?

        init(onMarkerTap: ((GMSMarker) -> Bool)?) {
            self.onMarkerTap = onMarkerTap
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            onMarkerTap?(marker) ?? false
        }
    }
}
