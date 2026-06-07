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
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera = false

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

                    HStack {
                        PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .images) {
                            Label("Library", systemImage: "photo.on.rectangle")
                        }
                        Spacer()
                        Button(action: { showCamera = true }) {
                            Label("Camera", systemImage: "camera")
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
            .onChange(of: selectedItems) {
                Task {
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            photos.append(image)
                        }
                    }
                    selectedItems = []
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(image: Binding(get: { nil }, set: { img in
                    if let img { photos.append(img) }
                }))
                .ignoresSafeArea()
            }
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

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
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
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
