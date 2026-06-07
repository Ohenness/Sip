import SwiftUI
import SwiftData
import GoogleMaps
import GooglePlaces

@main
struct SipApp: App {
    init() {
        let apiKey = SecretsManager.googleAPIKey
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [FavoriteShop.self, VisitEntry.self, CityVisit.self])
    }
}
