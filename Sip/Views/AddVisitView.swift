import SwiftUI
import SwiftData
import CoreLocation
import MapKit

struct AddVisitView: View {
    let placeId: String
    let shopName: String
    let coordinate: CLLocationCoordinate2D

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var visitDate = Date.now
    @State private var rating = 3
    @State private var drinkName = ""
    @State private var notes = ""
    @State private var acidity = 3
    @State private var bodyScore = 3
    @State private var roast = 3
    @State private var includeTasteNotes = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Visit") {
                    DatePicker("Date", selection: $visitDate, displayedComponents: .date)
                    HStack {
                        Text("Rating")
                        Spacer()
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundStyle(.orange)
                                .onTapGesture { rating = star }
                        }
                    }
                }

                Section("Drink") {
                    TextField("Drink name", text: $drinkName)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Taste Notes", isOn: $includeTasteNotes)
                    if includeTasteNotes {
                        Stepper("Acidity: \(acidity)/5", value: $acidity, in: 1...5)
                        Stepper("Body: \(bodyScore)/5", value: $bodyScore, in: 1...5)
                        Stepper("Roast: \(roast)/5", value: $roast, in: 1...5)
                    }
                }
            }
            .navigationTitle("Log Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                }
            }
        }
    }

    private func save() {
        let entry = VisitEntry(
            placeId: placeId,
            shopName: shopName,
            visitDate: visitDate,
            rating: rating,
            drinkName: drinkName.isEmpty ? nil : drinkName,
            notes: notes.isEmpty ? nil : notes,
            acidity: includeTasteNotes ? acidity : nil,
            body: includeTasteNotes ? bodyScore : nil,
            roast: includeTasteNotes ? roast : nil
        )
        modelContext.insert(entry)

        // Update city tracker via reverse geocoding
        Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            guard let request = MKReverseGeocodingRequest(location: location) else { return }
            if let mapItems = try? await request.mapItems,
               let mapItem = mapItems.first,
               let city = mapItem.address?.fullAddress.components(separatedBy: ", ").first {
                entry.city = city
                updateCityTracker(city: city, country: nil)
            }
        }
        dismiss()
    }

    private func updateCityTracker(city: String, country: String?) {
        let descriptor = FetchDescriptor<CityVisit>(predicate: #Predicate { $0.cityName == city })
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.shopCount += 1
        } else {
            modelContext.insert(CityVisit(cityName: city, country: country))
        }
    }
}
