import SwiftUI
import SwiftData
import PhotosUI
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

    @State private var photos: [UIImage] = []
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showLibrary = false

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

                Section("Photos") {
                    if !photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(photos.indices, id: \.self) { i in
                                    Image(uiImage: photos[i])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(alignment: .topTrailing) {
                                            Button(action: { photos.remove(at: i) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.caption)
                                                    .foregroundStyle(.white, .red)
                                            }
                                            .offset(x: 4, y: -4)
                                        }
                                }
                            }
                        }
                    }

                    Button(action: { showPhotoOptions = true }) {
                        Label("Add Photo", systemImage: "plus.circle")
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
            .confirmationDialog("Add Photo", isPresented: $showPhotoOptions) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Take Photo") { showCamera = true }
                }
                Button("Choose from Library") { showLibrary = true }
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { image in
                    photos.append(image)
                }
                .ignoresSafeArea()
            }
            .photosPicker(isPresented: $showLibrary, selection: Binding(
                get: { [] as [PhotosPickerItem] },
                set: { items in
                    Task {
                        for item in items {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                photos.append(image)
                            }
                        }
                    }
                }
            ), maxSelectionCount: 5, matching: .images)
        }
    }

    private func save() {
        let fileNames = photos.compactMap { PhotoStorage.save($0) }

        let entry = VisitEntry(
            placeId: placeId,
            shopName: shopName,
            visitDate: visitDate,
            rating: rating,
            drinkName: drinkName.isEmpty ? nil : drinkName,
            notes: notes.isEmpty ? nil : notes,
            acidity: includeTasteNotes ? acidity : nil,
            body: includeTasteNotes ? bodyScore : nil,
            roast: includeTasteNotes ? roast : nil,
            photoFileNames: fileNames
        )
        modelContext.insert(entry)
        do {
            try modelContext.save()
            print("✅ Visit saved successfully")
        } catch {
            print("❌ Failed to save visit: \(error)")
        }

        Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            guard let request = MKReverseGeocodingRequest(location: location) else { return }
            if let mapItems = try? await request.mapItems,
               let mapItem = mapItems.first,
               let city = mapItem.address?.fullAddress.components(separatedBy: ", ").first {
                entry.city = city
                updateCityTracker(city: city, country: nil)
                try? modelContext.save()
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

struct CameraView: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
