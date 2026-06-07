import Foundation
import SwiftData

@Model
final class FavoriteShop {
    @Attribute(.unique) var placeId: String
    var name: String
    var latitude: Double
    var longitude: Double
    var city: String?
    var dateAdded: Date

    init(placeId: String, name: String, latitude: Double, longitude: Double, city: String? = nil) {
        self.placeId = placeId
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.dateAdded = .now
    }
}

@Model
final class VisitEntry {
    var placeId: String
    var shopName: String
    var city: String?
    var visitDate: Date
    var rating: Int
    var drinkName: String?
    var notes: String?
    var acidity: Int?
    var body: Int?
    var roast: Int?

    init(placeId: String, shopName: String, city: String? = nil, visitDate: Date = .now, rating: Int = 3, drinkName: String? = nil, notes: String? = nil, acidity: Int? = nil, body: Int? = nil, roast: Int? = nil) {
        self.placeId = placeId
        self.shopName = shopName
        self.city = city
        self.visitDate = visitDate
        self.rating = rating
        self.drinkName = drinkName
        self.notes = notes
        self.acidity = acidity
        self.body = body
        self.roast = roast
    }
}

@Model
final class CityVisit {
    @Attribute(.unique) var cityName: String
    var country: String?
    var shopCount: Int
    var firstVisited: Date

    init(cityName: String, country: String? = nil, shopCount: Int = 1) {
        self.cityName = cityName
        self.country = country
        self.shopCount = shopCount
        self.firstVisited = .now
    }
}
