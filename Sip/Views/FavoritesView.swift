import SwiftUI
import SwiftData

enum FavoriteSortOption: String, CaseIterable {
    case dateAdded = "Date Added"
    case alphabetical = "A–Z"
    case city = "City"
}

struct FavoritesView: View {
    @Query(sort: \FavoriteShop.dateAdded, order: .reverse) private var favorites: [FavoriteShop]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPlaceId: String?
    @State private var sortOption: FavoriteSortOption = .dateAdded

    private var sortedFavorites: [FavoriteShop] {
        switch sortOption {
        case .dateAdded:
            return favorites
        case .alphabetical:
            return favorites.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .city:
            return favorites.sorted { ($0.city ?? "zzz") < ($1.city ?? "zzz") }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView("No Favorites Yet", systemImage: "heart", description: Text("Tap the heart icon on a shop to save it here."))
                } else {
                    List {
                        ForEach(sortedFavorites) { shop in
                            Button(action: { selectedPlaceId = shop.placeId }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(shop.name)
                                        .font(.headline)
                                    if let city = shop.city {
                                        Text(city)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text("Added \(shop.dateAdded, format: .dateTime.month().day())")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(FavoriteSortOption.allCases, id: \.self) { option in
                            Button(action: { sortOption = option }) {
                                Label(option.rawValue, systemImage: sortOption == option ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .sheet(item: $selectedPlaceId) { placeId in
                ShopDetailView(placeId: placeId)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        let sorted = sortedFavorites
        for i in offsets {
            modelContext.delete(sorted[i])
        }
    }
}
