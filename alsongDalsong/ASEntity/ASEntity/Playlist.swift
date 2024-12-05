import Foundation

public struct Playlist: Codable, Equatable, Sendable, Hashable {
    public var artworkUrl: URL?
    public var title: String?

    public init() {}
}
