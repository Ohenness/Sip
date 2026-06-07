import Foundation
import CoreLocation
import GooglePlaces
import UIKit

struct CoffeeShop: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let rating: Float?
    let isOpen: Bool?
}

struct ShopDetail {
    let placeId: String
    let name: String
    let address: String?
    let coordinate: CLLocationCoordinate2D
    let rating: Float?
    let priceLevel: Int?
    let phoneNumber: String?
    let website: URL?
    let hours: [String]?
    let isOpen: Bool?
    let photos: [GMSPlacePhotoMetadata]
}

struct AutocompleteResult: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
}

final class PlacesService {
    private let client = GMSPlacesClient.shared()

    func searchNearbyCoffeeShops(location: CLLocationCoordinate2D, radius: Double = 1500) async throws -> [CoffeeShop] {
        let placeProperties = [GMSPlaceProperty.placeID, GMSPlaceProperty.name, GMSPlaceProperty.coordinate, GMSPlaceProperty.rating, GMSPlaceProperty.businessStatus].map { $0.rawValue }

        let circularLocation = GMSPlaceCircularLocationOption(location, radius)
        let request = GMSPlaceSearchNearbyRequest(locationRestriction: circularLocation, placeProperties: placeProperties)
        request.includedTypes = ["cafe", "coffee_shop"]

        return try await withCheckedThrowingContinuation { continuation in
            client.searchNearby(with: request, completion: { response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let shops = (response?.places ?? []).map { place in
                    CoffeeShop(
                        id: place.placeID ?? "",
                        name: place.name ?? "Unknown",
                        coordinate: place.coordinate,
                        rating: place.rating,
                        isOpen: nil
                    )
                }
                continuation.resume(returning: shops)
            })
        }
    }

    func fetchDetail(placeId: String) async throws -> ShopDetail {
        let placeProperties = [
            GMSPlaceProperty.placeID, GMSPlaceProperty.name, GMSPlaceProperty.formattedAddress,
            GMSPlaceProperty.coordinate, GMSPlaceProperty.rating, GMSPlaceProperty.priceLevel,
            GMSPlaceProperty.phoneNumber, GMSPlaceProperty.website, GMSPlaceProperty.openingHours,
            GMSPlaceProperty.photos, GMSPlaceProperty.businessStatus
        ].map { $0.rawValue }

        let fetchRequest = GMSFetchPlaceRequest(placeID: placeId, placeProperties: placeProperties, sessionToken: nil)

        return try await withCheckedThrowingContinuation { continuation in
            client.fetchPlace(with: fetchRequest, callback: { place, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let place else {
                    continuation.resume(throwing: PlacesError.notFound)
                    return
                }
                let detail = ShopDetail(
                    placeId: place.placeID ?? placeId,
                    name: place.name ?? "Unknown",
                    address: place.formattedAddress,
                    coordinate: place.coordinate,
                    rating: place.rating,
                    priceLevel: place.priceLevel.rawValue,
                    phoneNumber: place.phoneNumber,
                    website: place.website,
                    hours: place.openingHours?.weekdayText,
                    isOpen: nil,
                    photos: place.photos ?? []
                )
                continuation.resume(returning: detail)
            })
        }
    }

    func autocomplete(query: String) async throws -> [AutocompleteResult] {
        let request = GMSAutocompleteRequest(query: query)
        let filter = GMSAutocompleteFilter()
        filter.types = ["cafe", "coffee_shop"]
        request.filter = filter

        return try await withCheckedThrowingContinuation { continuation in
            client.fetchAutocompleteSuggestions(from: request, callback: { suggestions, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let items = (suggestions ?? []).compactMap { suggestion -> AutocompleteResult? in
                    guard let placeSuggestion = suggestion.placeSuggestion else { return nil }
                    return AutocompleteResult(
                        id: placeSuggestion.placeID,
                        title: placeSuggestion.attributedPrimaryText.string,
                        subtitle: placeSuggestion.attributedSecondaryText?.string
                    )
                }
                continuation.resume(returning: items)
            })
        }
    }

    func loadPhoto(_ metadata: GMSPlacePhotoMetadata, maxSize: CGSize = CGSize(width: 400, height: 300)) async throws -> UIImage {
        let fetchPhotoRequest = GMSFetchPhotoRequest(photoMetadata: metadata, maxSize: maxSize)
        return try await withCheckedThrowingContinuation { continuation in
            client.fetchPhoto(with: fetchPhotoRequest, callback: { image, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let image {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: PlacesError.notFound)
                }
            })
        }
    }
}

enum PlacesError: Error {
    case notFound
}
