import Foundation

public protocol Endpoint<Path> {
    associatedtype Path: CustomStringConvertible
    var scheme: String { get }
    var host: String { get }
    var path: Path { get set }
    var method: HTTPMethod { get set }
    var headers: [String: String] { get set }
    var body: Data? { get set }
    var queryItems: [URLQueryItem]? { get set }
    var url: URL? { get }
}
