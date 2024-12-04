import Foundation

public struct Playlist: Codable, Equatable, Sendable, Hashable {
    public let artworkUrl: URL?
    public let title: String?

    public init() {}
}
