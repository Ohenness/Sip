import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    var cameraUpdate: GMSCameraPosition?
    @Binding var markers: [GMSMarker]
    var showsUserLocation: Bool = true
    var onMarkerTap: ((GMSMarker) -> Bool)?
    var onCameraIdle: ((CLLocationCoordinate2D) -> Void)?

    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        if let cameraUpdate {
            options.camera = cameraUpdate
        }
        let mapView = GMSMapView(options: options)
        mapView.isMyLocationEnabled = showsUserLocation
        mapView.settings.myLocationButton = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // Only move camera when a new programmatic update arrives
        if let cameraUpdate, cameraUpdate !== context.coordinator.lastAppliedCamera {
            mapView.animate(to: cameraUpdate)
            context.coordinator.lastAppliedCamera = cameraUpdate
        }

        // Update markers
        mapView.clear()
        for marker in markers {
            marker.map = mapView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onMarkerTap: onMarkerTap, onCameraIdle: onCameraIdle)
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var onMarkerTap: ((GMSMarker) -> Bool)?
        var onCameraIdle: ((CLLocationCoordinate2D) -> Void)?
        var lastAppliedCamera: GMSCameraPosition?

        init(onMarkerTap: ((GMSMarker) -> Bool)?, onCameraIdle: ((CLLocationCoordinate2D) -> Void)?) {
            self.onMarkerTap = onMarkerTap
            self.onCameraIdle = onCameraIdle
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            onMarkerTap?(marker) ?? false
        }

        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            onCameraIdle?(position.target)
        }
    }
}
