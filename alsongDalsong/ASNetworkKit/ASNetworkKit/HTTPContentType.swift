import Foundation

public enum HTTPContentType {
    case none
    case json
    case multipart

    func header(_ boundary: String) -> [String: String] {
        switch self {
            case .json:
                return ["Content-Type": "application/json"]
            case .multipart:
                let boundary = "Boundary-\(boundary)"
                return ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
            case .none:
                return [:]
        }
    }

    func body(_ boundary: String, with data: Data?) -> Data? {
        switch self {
            case .json:
                return data
            case .multipart:
                var body = Data()
                let boundary = "Boundary-\(boundary)"
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(UUID().uuidString).m4a\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
                body.append(data!)
                body.append("\r\n".data(using: .utf8)!)
                body.append("--\(boundary)--\r\n".data(using: .utf8)!)
                return body
            case .none:
                return nil
        }
    }
}
