import Foundation

public struct Music: Codable {
    public var id: UUID?
    public var title: String?
    public var artist: String?
    public var lyrics: String?

    public init() {}
}
