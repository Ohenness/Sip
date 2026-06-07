import SwiftUI
import GoogleMaps

struct MapTab: View {
    @State private var viewModel = MapViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            GoogleMapView(
                camera: $viewModel.camera,
                markers: $viewModel.markers,
                onMarkerTap: { marker in
                    if let placeId = marker.userData as? String {
                        viewModel.selectedPlaceId = placeId
                    }
                    return false
                }
            )
            .ignoresSafeArea()

            SearchBar(text: $viewModel.searchText, onCommit: viewModel.search)
                .padding(.top, 8)
                .padding(.horizontal)

            if !viewModel.searchResults.isEmpty {
                SearchResultsList(
                    results: viewModel.searchResults,
                    onSelect: { result in
                        viewModel.selectSearchResult(result)
                    }
                )
                .padding(.top, 56)
                .padding(.horizontal)
            }
        }
        .sheet(item: $viewModel.selectedPlaceId) { placeId in
            ShopDetailView(placeId: placeId)
        }
        .task {
            await viewModel.startLocationUpdates()
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}
