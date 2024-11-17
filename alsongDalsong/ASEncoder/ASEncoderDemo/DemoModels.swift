import Foundation

class UserInfo: Encodable {
    var userName: String
    var userAvaterUrl: URL
    var userBirthDate: Date
    var userStatus: UserStatus
    
    init(userName: String, userAvaterUrl: URL, userBirthDate: Date, userStatus: UserStatus) {
        self.userName = userName
        self.userAvaterUrl = userAvaterUrl
        self.userBirthDate = userBirthDate
        self.userStatus = userStatus
    }
}

enum UserStatus: String, CaseIterable, Identifiable, Encodable {
    case waiting
    case humming
    var id: String { self.rawValue }
}
