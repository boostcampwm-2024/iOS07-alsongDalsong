import Foundation

public struct Player {
    var id: String
    var avatarUrl: URL?
    var nickname: String?
    var score: Int?
    var order: Int?
    
    public init(
        id: String,
        avatarUrl: URL? = nil,
        nickname: String? = nil,
        score: Int? = nil,
        order: Int? = nil
    ) {
        self.id = id
        self.avatarUrl = avatarUrl
        self.nickname = nickname
        self.score = score
        self.order = order
    }
}
