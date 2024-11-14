import Foundation

public struct Player {
    var id = UUID()
    var avatarUrl: URL?
    var nickname: String?
    var score: Int?
    var order: Int?
    
    public init() {}
}
