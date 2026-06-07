# Sip ☕

A SwiftUI iOS app for discovering coffee shops, keeping a personal visit journal, and tracking your coffee journey across cities.

## Features

- **Map** — Browse nearby coffee shops on a Google Map centered on your current location, with brown markers for each café. Automatically re-searches as you pan to new areas.
- **Search** — Find coffee shops by name with Google Places autocomplete
- **Shop Details** — View ratings, hours, address, phone, website, and photos for any shop
- **Open Now Filter** — Toggle to show only currently-open shops
- **Favorites** — Save shops to a persistent favorites list, sortable by date, name, or city
- **Share** — Share shop details and an Apple Maps link via the system share sheet
- **Visit Journal** — Log visits with date, rating (1–5 stars), drink name, notes, and optional taste scores (acidity, body, roast). Stats header shows total visits, average rating, and most-visited shop.
- **Coffee Passport** — Earn badges for milestones like visiting 5 cities, logging taste notes, or trying 10 different drinks. Progress bars show how close you are to each badge.
- **City Tracker** — Automatically tracks which cities you've visited coffee shops in via reverse geocoding

## Requirements

- Xcode 16+
- iOS 17+
- A Google Cloud project with the **Maps SDK for iOS** and **Places API (New)** enabled

## Setup

1. Clone the repository and open `Sip.xcodeproj` in Xcode.

2. Add the Google Maps and Places SPM dependencies (File → Add Package Dependencies):
   - `https://github.com/googlemaps/ios-maps-sdk`
   - `https://github.com/googlemaps/ios-places-sdk`

3. Configure your API key — edit `Sip/Secrets.plist` and replace `YOUR_API_KEY_HERE` with your Google API key. This file is gitignored.

4. Add the location usage description in your target's Info tab:
   - Key: `Privacy - Location When In Use Usage Description`
   - Value: `Sip uses your location to find coffee shops near you.`

5. Build and run on a simulator or device.

## Architecture

| Layer | Description |
|-------|-------------|
| **Models** | SwiftData `@Model` classes — `FavoriteShop`, `VisitEntry`, `CityVisit`. Badge logic computed from visit data. |
| **Views** | SwiftUI views organized by feature — Map, Favorites, Journal, Progress, Shop Detail |
| **ViewModels** | `@Observable` classes driving map state, search, and filtering |
| **Services** | `PlacesService` (nearby search, detail, autocomplete, photos), `LocationService` (CLLocationManager wrapper), `SecretsManager` (plist reader) |

## Project Structure

```
Sip/
├── SipApp.swift            # App entry point, SDK initialization, model container
├── ContentView.swift       # Tab bar (Map, Favorites, Journal, Progress)
├── Models/
│   ├── Models.swift        # SwiftData models
│   └── Badge.swift         # Badge definitions and computation logic
├── ViewModels/
│   └── MapViewModel.swift  # Map state, search, markers, filtering, debounced re-search
├── Views/
│   ├── MapTab.swift        # Map + search overlay + Open Now filter
│   ├── GoogleMapView.swift # UIViewRepresentable GMSMapView wrapper
│   ├── SearchBar.swift     # Search bar + autocomplete results list
│   ├── ShopDetailView.swift # Photos, hours, rating, favorite, share, log visit
│   ├── AddVisitView.swift  # Journal entry form with taste notes
│   ├── FavoritesView.swift # Saved shops with sort options
│   ├── JournalView.swift   # Visit history with stats header
│   ├── ProgressTab.swift   # Coffee Passport badges + city tracker
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
