import SwiftUI
import GoogleMaps

struct MapTab: View {
    @State private var viewModel = MapViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            GoogleMapView(
                cameraUpdate: viewModel.camera,
                markers: $viewModel.markers,
                onMarkerTap: { marker in
                    if let placeId = marker.userData as? String {
                        viewModel.selectedPlaceId = placeId
                    }
                    return false
                },
                onCameraIdle: { center in
                    viewModel.onCameraIdle(center: center)
                }
            )
            .ignoresSafeArea()

            VStack(spacing: 8) {
                SearchBar(text: $viewModel.searchText, onCommit: viewModel.search)

                HStack {
                    Button(action: { viewModel.showOpenOnly.toggle() }) {
                        Label("Open Now", systemImage: viewModel.showOpenOnly ? "checkmark.circle.fill" : "clock")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.regularMaterial)
                            .overlay(viewModel.showOpenOnly ? Color.green.opacity(0.2) : Color.clear)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(6)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                    }
                }

                if !viewModel.searchResults.isEmpty {
                    SearchResultsList(
                        results: viewModel.searchResults,
                        onSelect: { result in
                            viewModel.selectSearchResult(result)
                        }
                    )
                }
            }
            .padding(.top, 8)
            .padding(.horizontal)
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
