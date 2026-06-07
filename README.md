# Sip ☕

A SwiftUI iOS app for discovering coffee shops, keeping a personal visit journal, and tracking your coffee journey across cities.

## Features

- **Map** — Browse nearby coffee shops on a Google Map centered on your current location, with brown markers for each café
- **Search** — Find coffee shops by name with Google Places autocomplete
- **Shop Details** — View ratings, hours, address, phone, website, and photos for any shop
- **Favorites** — Save shops to a persistent favorites list
- **Visit Journal** — Log visits with date, rating (1–5 stars), drink name, notes, and optional taste scores (acidity, body, roast)
- **City Tracker** — Automatically tracks which cities you've visited coffee shops in via reverse geocoding

## Requirements

- Xcode 15+
- iOS 17+
- A Google Cloud project with the **Maps SDK for iOS** and **Places API (New)** enabled

## Setup

1. Clone the repository and open `Sip.xcodeproj` in Xcode.

2. Add the Google Maps and Places SPM dependencies (File → Add Package Dependencies):
   - `https://github.com/googlemaps/ios-maps-sdk`
   - `https://github.com/googlemaps/ios-places-sdk`

3. Configure your API key — edit `Sip/Secrets.plist` and replace `YOUR_API_KEY_HERE` with your Google API key. This file is gitignored.

4. Build and run on a simulator or device.

## Architecture

| Layer | Description |
|-------|-------------|
| **Models** | SwiftData `@Model` classes — `FavoriteShop`, `VisitEntry`, `CityVisit` |
| **Views** | SwiftUI views organized by feature — Map, Favorites, Journal, Cities, Shop Detail |
| **ViewModels** | `@Observable` classes driving map state and search |
| **Services** | `PlacesService` (nearby search, detail, autocomplete, photos), `LocationService` (CLLocationManager wrapper), `SecretsManager` (plist reader) |

## Project Structure

```
Sip/
├── SipApp.swift            # App entry point, SDK initialization, model container
├── ContentView.swift       # Tab bar (Map, Favorites, Journal, Cities)
├── Models/
│   └── Models.swift        # SwiftData models
├── ViewModels/
│   └── MapViewModel.swift  # Map state, search, marker management
├── Views/
│   ├── MapTab.swift
│   ├── GoogleMapView.swift # UIViewRepresentable GMSMapView wrapper
│   ├── SearchBar.swift
│   ├── ShopDetailView.swift
│   ├── AddVisitView.swift
│   ├── FavoritesView.swift
│   ├── JournalView.swift
│   └── CityTrackerView.swift
├── Services/
│   ├── PlacesService.swift
│   ├── LocationService.swift
│   └── SecretsManager.swift
├── Assets.xcassets/
└── Secrets.plist           # API key (gitignored)
```

## License

Private project — all rights reserved.
