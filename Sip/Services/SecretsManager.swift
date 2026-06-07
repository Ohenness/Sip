import Foundation

enum SecretsManager {
    static var googleAPIKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["GOOGLE_API_KEY"] as? String else {
            fatalError("Missing Secrets.plist or GOOGLE_API_KEY entry. See README.")
        }
        return key
    }
}
