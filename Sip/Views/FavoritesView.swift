import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteShop.dateAdded, order: .reverse) private var favorites: [FavoriteShop]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPlaceId: String?

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView("No Favorites Yet", systemImage: "heart", description: Text("Tap the heart icon on a shop to save it here."))
                } else {
                    List {
                        ForEach(favorites) { shop in
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
            .sheet(item: $selectedPlaceId) { placeId in
                ShopDetailView(placeId: placeId)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            modelContext.delete(favorites[i])
        }
    }
}
