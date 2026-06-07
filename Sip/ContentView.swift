import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book")
                }
            ProgressTab()
                .tabItem {
                    Label("Progress", systemImage: "trophy")
                }
        }
    }
}
