import Foundation

struct Badge: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: Int
    let current: Int

    var isEarned: Bool { current >= requirement }
    var progress: Double { min(Double(current) / Double(requirement), 1.0) }
}

struct BadgeService {
    static func computeBadges(visits: [VisitEntry], cities: [CityVisit]) -> [Badge] {
        let uniqueShops = Set(visits.map(\.placeId)).count
        let uniqueDrinks = Set(visits.compactMap(\.drinkName)).count
        let tasteNoteCount = visits.filter { $0.acidity != nil }.count
        let maxSameShop = Dictionary(grouping: visits, by: \.placeId).values.map(\.count).max() ?? 0

        return [
            Badge(id: "first_sip", name: "First Sip", description: "Log your first visit", icon: "cup.and.saucer.fill", requirement: 1, current: visits.count),
            Badge(id: "regular", name: "Regular", description: "Log 10 visits", icon: "10.circle.fill", requirement: 10, current: visits.count),
            Badge(id: "explorer", name: "Explorer", description: "Visit 5 different shops", icon: "safari.fill", requirement: 5, current: uniqueShops),
            Badge(id: "globe_trotter", name: "Globe Trotter", description: "Visit shops in 5 cities", icon: "globe.americas.fill", requirement: 5, current: cities.count),
            Badge(id: "world_traveler", name: "World Traveler", description: "Visit shops in 10 cities", icon: "airplane", requirement: 10, current: cities.count),
            Badge(id: "connoisseur", name: "Connoisseur", description: "Log taste notes on 10 visits", icon: "nose", requirement: 10, current: tasteNoteCount),
            Badge(id: "loyal", name: "Loyal Customer", description: "Visit the same shop 5 times", icon: "house.fill", requirement: 5, current: maxSameShop),
            Badge(id: "variety", name: "Variety Pack", description: "Try 10 different drinks", icon: "paintpalette.fill", requirement: 10, current: uniqueDrinks),
            Badge(id: "critic", name: "Critic", description: "Rate 20 visits", icon: "star.fill", requirement: 20, current: visits.count),
        ]
    }
}
