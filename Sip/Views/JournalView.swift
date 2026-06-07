import SwiftUI
import SwiftData

struct JournalView: View {
    @Query(sort: \VisitEntry.visitDate, order: .reverse) private var entries: [VisitEntry]

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView("No Visits Yet", systemImage: "book", description: Text("Log a visit from a shop's detail page."))
                } else {
                    List {
                        Section {
                            JournalStatsView(entries: entries)
                        }
                        .listRowBackground(Color.brown.opacity(0.1))

                        ForEach(entries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(entry.shopName)
                                        .font(.headline)
                                    Spacer()
                                    HStack(spacing: 2) {
                                        ForEach(1...5, id: \.self) { star in
                                            Image(systemName: star <= entry.rating ? "star.fill" : "star")
                                                .font(.caption2)
                                                .foregroundStyle(.orange)
                                        }
                                    }
                                }

                                if let drink = entry.drinkName {
                                    Text(drink)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                HStack {
                                    Text(entry.visitDate, format: .dateTime.month().day().year())
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                    if let city = entry.city {
                                        Text("• \(city)")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }

                                if let notes = entry.notes {
                                    Text(notes)
                                        .font(.caption)
                                        .lineLimit(2)
                                }

                                if let acidity = entry.acidity, let body = entry.body, let roast = entry.roast {
                                    HStack(spacing: 12) {
                                        TasteLabel(name: "Acidity", value: acidity)
                                        TasteLabel(name: "Body", value: body)
                                        TasteLabel(name: "Roast", value: roast)
                                    }
                                    .padding(.top, 2)
                                }

                                if !entry.photoFileNames.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 6) {
                                            ForEach(entry.photoFileNames, id: \.self) { fileName in
                                                if let img = PhotoStorage.load(fileName) {
                                                    Image(uiImage: img)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 60, height: 60)
                                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Journal")
        }
    }
}

private struct JournalStatsView: View {
    let entries: [VisitEntry]

    private var avgRating: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.reduce(0) { $0 + $1.rating }) / Double(entries.count)
    }

    private var mostVisited: String? {
        let counts = Dictionary(grouping: entries, by: \.shopName).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    var body: some View {
        HStack(spacing: 16) {
            StatItem(value: "\(entries.count)", label: "Visits")
            StatItem(value: String(format: "%.1f", avgRating), label: "Avg ★")
            if let top = mostVisited {
                StatItem(value: top, label: "Top Shop")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

private struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct TasteLabel: View {
    let name: String
    let value: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)/5")
                .font(.caption.bold())
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
