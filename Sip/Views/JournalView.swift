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
                    List(entries) { entry in
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
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Journal")
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
