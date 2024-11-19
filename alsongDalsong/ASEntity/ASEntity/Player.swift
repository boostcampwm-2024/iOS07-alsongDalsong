import Foundation

public struct Player: Codable, Equatable, Identifiable {
    public var id: String
    public var avatarUrl: URL?
    public var nickname: String?
    public var score: Int?
    public var order: Int?
    
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
