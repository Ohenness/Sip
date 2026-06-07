import SwiftUI
import SwiftData
import GooglePlaces

struct ShopDetailView: View {
    let placeId: String
    @State private var detail: ShopDetail?
    @State private var photos: [UIImage] = []
    @State private var isLoading = true
    @State private var showAddVisit = false

    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteShop]

    private var isFavorite: Bool {
        favorites.contains { $0.placeId == placeId }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                } else if let detail {
                    detailContent(detail)
                } else {
                    ContentUnavailableView("Shop Not Found", systemImage: "cup.and.saucer")
                }
            }
            .navigationTitle(detail?.name ?? "Shop Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let detail {
                        let shareText = "\(detail.name)\n\(detail.address ?? "")\nhttps://maps.apple.com/?q=\(detail.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                        ShareLink(item: shareText) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: toggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? .red : .secondary)
                    }
                }
            }
        }
        .task { await loadDetail() }
        .sheet(isPresented: $showAddVisit) {
            if let detail {
                AddVisitView(placeId: detail.placeId, shopName: detail.name, coordinate: detail.coordinate)
            }
        }
    }

    @ViewBuilder
    private func detailContent(_ shop: ShopDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Photos
                if !photos.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(photos.indices, id: \.self) { i in
                                Image(uiImage: photos[i])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 280, height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    // Rating & Status
                    HStack {
                        if let rating = shop.rating {
                            Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                .foregroundStyle(.orange)
                        }
                        if let isOpen = shop.isOpen {
                            Text(isOpen ? "Open" : "Closed")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(isOpen ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }

                    // Address
                    if let address = shop.address {
                        Label(address, systemImage: "mappin")
                            .font(.subheadline)
                    }

                    // Phone
                    if let phone = shop.phoneNumber {
                        Label(phone, systemImage: "phone")
                            .font(.subheadline)
                    }

                    // Website
                    if let url = shop.website {
                        Link(destination: url) {
                            Label("Website", systemImage: "globe")
                                .font(.subheadline)
                        }
                    }

                    // Hours
                    if let hours = shop.hours, !hours.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hours")
                                .font(.headline)
                            ForEach(hours, id: \.self) { line in
                                Text(line)
                                    .font(.caption)
                            }
                        }
                    }

                    // Log Visit Button
                    Button(action: { showAddVisit = true }) {
                        Label("Log Visit", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.brown)
                    .padding(.top, 8)
                }
                .padding(.horizontal)
            }
        }
    }

    private func loadDetail() async {
        do {
            let service = PlacesService()
            detail = try await service.fetchDetail(placeId: placeId)
            if let photoMetadata = detail?.photos.prefix(5) {
                for meta in photoMetadata {
                    if let img = try? await service.loadPhoto(meta) {
                        photos.append(img)
                    }
                }
            }
        } catch {
            print("Load detail failed: \(error)")
        }
        isLoading = false
    }

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.placeId == placeId }) {
            modelContext.delete(existing)
        } else if let detail {
            let fav = FavoriteShop(placeId: detail.placeId, name: detail.name, latitude: detail.coordinate.latitude, longitude: detail.coordinate.longitude)
            modelContext.insert(fav)
        }
    }
}
