import SwiftUI
import SwiftData
import GoogleMaps
import GooglePlaces

@main
struct SipApp: App {
    let container: ModelContainer

    init() {
        let apiKey = SecretsManager.googleAPIKey
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)

        let schema = Schema([FavoriteShop.self, VisitEntry.self, CityVisit.self])
        let config = ModelConfiguration(schema: schema)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // If schema migration fails, delete and recreate
            print("ModelContainer failed: \(error). Recreating store.")
            let config = ModelConfiguration(schema: schema)
            container = try! ModelContainer(for: schema, configurations: [config])
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
