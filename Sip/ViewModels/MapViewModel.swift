import Foundation
import GoogleMaps
import CoreLocation

@Observable
final class MapViewModel {
    var camera = GMSCameraPosition(latitude: 37.7749, longitude: -122.4194, zoom: 14)
    var markers: [GMSMarker] = []
    var selectedPlaceId: String?
    var searchText = ""
    var searchResults: [AutocompleteResult] = []
    var isLoading = false

    private let locationService = LocationService()
    private let placesService = PlacesService()
    private var hasInitiallyFocused = false

    func startLocationUpdates() async {
        locationService.requestPermission()

        // Poll until we get a location
        while locationService.currentLocation == nil {
            try? await Task.sleep(for: .milliseconds(200))
        }

        if let loc = locationService.currentLocation, !hasInitiallyFocused {
            hasInitiallyFocused = true
            camera = GMSCameraPosition(latitude: loc.latitude, longitude: loc.longitude, zoom: 15)
            await searchNearby(location: loc)
        }
    }

    func searchNearby(location: CLLocationCoordinate2D) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let shops = try await placesService.searchNearbyCoffeeShops(location: location)
            markers = shops.map { shop in
                let marker = GMSMarker(position: shop.coordinate)
                marker.title = shop.name
                marker.userData = shop.id
                marker.icon = GMSMarker.markerImage(with: .brown)
                return marker
            }
        } catch {
            print("Nearby search failed: \(error)")
        }
    }

    func search() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        Task {
            do {
                searchResults = try await placesService.autocomplete(query: searchText)
            } catch {
                print("Autocomplete failed: \(error)")
            }
        }
    }

    func selectSearchResult(_ result: AutocompleteResult) {
        searchText = ""
        searchResults = []
        selectedPlaceId = result.id

        // Fetch detail to move camera to the location
        Task {
            do {
                let detail = try await placesService.fetchDetail(placeId: result.id)
                camera = GMSCameraPosition(latitude: detail.coordinate.latitude, longitude: detail.coordinate.longitude, zoom: 16)
            } catch {
                print("Detail fetch failed: \(error)")
            }
        }
    }
}
