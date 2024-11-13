import Foundation

enum Config {
    enum Firebase {
        static let apiKey = Bundle.main.infoDictionary?["FIREBASE_API_KEY"] as! String
        static let projectID = Bundle.main.infoDictionary?["FIREBASE_PROJECT_ID"] as! String
        static let appID = Bundle.main.infoDictionary?["FIREBASE_APP_ID"] as! String
        static let clientID = Bundle.main.infoDictionary?["FIREBASE_CLIENT_ID"] as! String
        static let storageBucket = Bundle.main.infoDictionary?["FIREBASE_STORAGE_BUCKET"] as! String
        static let gcmsenderID = Bundle.main.infoDictionary?["FIREBASE_GCM_SENDER_ID"] as! String
        static let databaseURL = Bundle.main.infoDictionary?["FIREBASE_DATABASE_URL"] as! String
    }
}
