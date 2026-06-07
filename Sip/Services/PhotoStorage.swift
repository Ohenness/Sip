import UIKit

enum PhotoStorage {
    private static var photosDirectory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "visit_photos")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func save(_ image: UIImage) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        let url = photosDirectory.appending(path: fileName)
        do {
            try data.write(to: url)
            return fileName
        } catch {
            return nil
        }
    }

    static func load(_ fileName: String) -> UIImage? {
        let url = photosDirectory.appending(path: fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
