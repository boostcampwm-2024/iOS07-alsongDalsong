import Foundation

public struct Player: Codable, Equatable, Identifiable, Sendable, Hashable {
    public let id: String
    public let avatarUrl: URL?
    public let nickname: String?
    public let score: Int?
    public let order: Int?
    
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

extension Player {
    public static let playerStub1: Player = Player(id: "0", avatarUrl: nil, nickname: "Tltlbo", score: nil, order: 0)
    public static let playerStub2: Player = Player(id: "1", avatarUrl: nil, nickname: "Sonny", score: nil, order: 1)
    public static let playerStub3: Player = Player(id: "2", avatarUrl: nil, nickname: "Moral-life", score: nil, order: 2)
    public static let playerStub4: Player = Player(id: "3", avatarUrl: nil, nickname: "Sang₩", score: nil, order: 3)
}
