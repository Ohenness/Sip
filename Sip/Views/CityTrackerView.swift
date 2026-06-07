import SwiftUI
import SwiftData

struct CityTrackerView: View {
    @Query(sort: \CityVisit.firstVisited, order: .reverse) private var cities: [CityVisit]

    var body: some View {
        NavigationStack {
            Group {
                if cities.isEmpty {
                    ContentUnavailableView("No Cities Yet", systemImage: "building.2", description: Text("Cities are tracked automatically when you log visits."))
                } else {
                    List(cities) { city in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(city.cityName)
                                    .font(.headline)
                                if let country = city.country {
                                    Text(country)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(city.shopCount) \(city.shopCount == 1 ? "shop" : "shops")")
                                    .font(.subheadline.weight(.medium))
                                Text("Since \(city.firstVisited, format: .dateTime.month().year())")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Cities")
        }
    }
}
