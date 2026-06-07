import SwiftUI
import SwiftData

struct ProgressTab: View {
    @Query(sort: \CityVisit.firstVisited, order: .reverse) private var cities: [CityVisit]
    @Query(sort: \VisitEntry.visitDate, order: .reverse) private var visits: [VisitEntry]

    private var badges: [Badge] {
        BadgeService.computeBadges(visits: visits, cities: cities)
    }

    private var earnedCount: Int {
        badges.filter(\.isEarned).count
    }

    var body: some View {
        NavigationStack {
            List {
                // Passport section
                Section {
                    VStack(spacing: 8) {
                        Text("\(earnedCount)/\(badges.count) Badges Earned")
                            .font(.headline)
                        Text("Keep exploring to unlock more!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                    ForEach(badges) { badge in
                        BadgeCard(badge: badge)
                    }
                } header: {
                    Text("Coffee Passport")
                }

                // Cities section
                Section {
                    if cities.isEmpty {
                        Text("Cities appear here when you log visits.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(cities) { city in
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
                } header: {
                    Text("Cities Visited")
                }
            }
            .navigationTitle("Progress")
        }
    }
}

private struct BadgeCard: View {
    let badge: Badge

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: badge.icon)
                .font(.title2)
                .foregroundStyle(badge.isEarned ? .brown : .gray)
                .frame(width: 40, height: 40)
                .background(badge.isEarned ? Color.brown.opacity(0.15) : Color.gray.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(badge.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(badge.isEarned ? .primary : .secondary)
                Text(badge.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !badge.isEarned {
                    ProgressView(value: badge.progress)
                        .tint(.brown)
                    Text("\(badge.current)/\(badge.requirement)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            if badge.isEarned {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
        .opacity(badge.isEarned ? 1.0 : 0.7)
    }
}
