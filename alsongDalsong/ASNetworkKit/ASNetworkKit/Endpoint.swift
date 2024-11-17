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
    func update<T>(_: WritableKeyPath<Self, T>, with _: T) -> Self
}

extension Endpoint {
    public var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "\(path.description.dropFirst())-\(host)"
        components.path = path.description
        components.queryItems = queryItems
        return components.url
    }
    
    public func update<T>(_ keyPath: WritableKeyPath<Self, T>, with value: T) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}
