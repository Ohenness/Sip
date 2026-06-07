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
    var showOpenOnly = false {
        didSet { applyFilter() }
    }

    private let locationService = LocationService()
    private let placesService = PlacesService()
    private var hasInitiallyFocused = false
    private var lastSearchLocation: CLLocationCoordinate2D?
    private var searchTask: Task<Void, Never>?
    private var allShops: [CoffeeShop] = []

    func startLocationUpdates() async {
        locationService.requestPermission()

        while locationService.currentLocation == nil {
            try? await Task.sleep(for: .milliseconds(200))
        }

        if let loc = locationService.currentLocation, !hasInitiallyFocused {
            hasInitiallyFocused = true
            camera = GMSCameraPosition(latitude: loc.latitude, longitude: loc.longitude, zoom: 15)
            await searchNearby(location: loc)
        }
    }

    func onCameraIdle(center: CLLocationCoordinate2D) {
        // Only re-search if moved >500m from last search
        if let last = lastSearchLocation {
            let lastLoc = CLLocation(latitude: last.latitude, longitude: last.longitude)
            let newLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
            guard newLoc.distance(from: lastLoc) > 500 else { return }
        }

        // Debounce: cancel previous and wait 1s
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            await searchNearby(location: center)
        }
    }

    func searchNearby(location: CLLocationCoordinate2D) async {
        isLoading = true
        defer { isLoading = false }
        lastSearchLocation = location
        do {
            allShops = try await placesService.searchNearbyCoffeeShops(location: location)
            applyFilter()
        } catch {
            print("Nearby search failed: \(error)")
        }
    }

    private func applyFilter() {
        let filtered = showOpenOnly ? allShops.filter { $0.isOpen == true } : allShops
        markers = filtered.map { shop in
            let marker = GMSMarker(position: shop.coordinate)
            marker.title = shop.name
            marker.userData = shop.id
            marker.icon = GMSMarker.markerImage(with: .brown)
            return marker
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
