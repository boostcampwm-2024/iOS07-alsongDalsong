import ASCacheKitProtocol
import Foundation

public struct ASNetworkManager: ASNetworkManagerProtocol {
    private let urlSession: URLSessionProtocol
    private let cacheManager: CacheManagerProtocol

    public init(urlSession: URLSessionProtocol = URLSession.shared, cacheManager: CacheManagerProtocol) {
        self.urlSession = urlSession
        self.cacheManager = cacheManager
    }

    @discardableResult
    public func sendRequest(
        to endpoint: any Endpoint,
        type: HTTPContentType,
        body: Data? = nil,
        option: CacheOption = .both
    ) async throws -> Data {
        guard let url = endpoint.url else { throw ASNetworkErrors.urlError }
        if let cache = try await loadCache(from: url, option: option) { return cache }

        let updatedEndpoint = updateEndpoint(type: type, endpoint: endpoint, body: body)
        let request = try urlRequest(for: updatedEndpoint)
        let (data, response) = try await urlSession.data(for: request)

        try validate(response: response)
        saveCache(from: url, with: data, option: option)
        return data
    }

    private func loadCache(from url: URL, option: CacheOption) async throws -> Data? {
        cacheManager.loadCache(from: url, cacheOption: option)
    }

    private func saveCache(from url: URL, with data: Data, option: CacheOption) {
        cacheManager.saveCache(withKey: url, data: data, cacheOption: option)
    }

    private func updateEndpoint(type: HTTPContentType, endpoint: some Endpoint, body: Data? = nil) -> any Endpoint {
        let id = UUID().uuidString
        return endpoint
            .update(\.headers, with: type.header(id))
            .update(\.body, with: type.body(id, with: body))
    }

    private func urlRequest(for endpoint: any Endpoint) throws -> URLRequest {
        guard let url = endpoint.url else { throw ASNetworkErrors.urlError }
        return RequestBuilder(using: url)
            .setHeader(endpoint.headers)
            .setHttpMethod(endpoint.method)
            .setBody(endpoint.body)
            .build()
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ASNetworkErrors.responseError
        }

        let statusCode = StatusCode(statusCode: httpResponse.statusCode)
        switch statusCode {
            case .success, .noContent:
                break
            default:
                throw ASNetworkErrors.serverError(message: statusCode.description)
        }
    }
}

private extension ASNetworkManager {
    private enum StatusCode: Int, CustomStringConvertible {
        case success = 200
        case noContent = 204
        case multipleChoices = 300
        case movedPermanently = 301
        case found = 302
        case seeOther = 303
        case notModified = 304
        case useProxy = 305
        case temporaryRedirect = 307
        case permanentRedirect = 308
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case tooManyRequests = 429
        case internalServerError = 500
        case notImplemented = 501
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
        case startedRoom = 452
        case unknown

        var description: String {
            switch self {
                case .success:
                    return "성공: 요청이 성공적으로 완료되었습니다."
                case .noContent:
                    return "콘텐츠 없음: 요청은 성공했지만 반환할 내용이 없습니다."
                case .multipleChoices:
                    return "여러 선택: 요청에 대해 여러 선택지가 있습니다."
                case .movedPermanently:
                    return "영구 이동: 요청한 리소스의 위치가 영구적으로 변경되었습니다."
                case .found:
                    return "임시 이동: 요청한 리소스의 위치가 일시적으로 변경되었습니다."
                case .seeOther:
                    return "다른 위치 참조: 다른 URI에서 리소스를 확인해야 합니다."
                case .notModified:
                    return "수정되지 않음: 캐시된 리소스와 동일하여 변경 사항이 없습니다."
                case .useProxy:
                    return "프록시 사용: 요청을 프록시를 통해 처리해야 합니다."
                case .temporaryRedirect:
                    return "임시 리디렉션: 리소스가 일시적으로 다른 위치로 이동되었습니다."
                case .permanentRedirect:
                    return "영구 리디렉션: 리소스가 영구적으로 다른 위치로 이동되었습니다."
                case .badRequest:
                    return "잘못된 요청: 서버가 요청을 이해할 수 없습니다."
                case .unauthorized:
                    return "권한 없음: 인증이 필요합니다."
                case .forbidden:
                    return "금지됨: 서버가 요청을 거부했습니다."
                case .notFound:
                    return "찾을 수 없음: 요청한 리소스를 찾을 수 없습니다."
                case .methodNotAllowed:
                    return "허용되지 않는 메서드: 요청에 사용된 메서드는 허용되지 않습니다."
                case .tooManyRequests:
                    return "요청 과다: 너무 많은 요청이 이루어졌습니다."
                case .internalServerError:
                    return "서버 오류: 서버 내부에서 오류가 발생했습니다."
                case .notImplemented:
                    return "구현되지 않음: 서버가 요청을 처리할 수 있는 기능을 갖추지 않았습니다."
                case .badGateway:
                    return "잘못된 게이트웨이: 게이트웨이 서버에서 잘못된 응답을 받았습니다."
                case .serviceUnavailable:
                    return "서비스 이용 불가: 서버가 현재 요청을 처리할 수 없습니다."
                case .gatewayTimeout:
                    return "게이트웨이 시간 초과: 게이트웨이가 요청에 대한 응답을 받지 못했습니다."
                case .startedRoom:
                    return "이미 게임이 시작된 방입니다."
                case .unknown:
                    return "알 수 없는 오류: 예상하지 못한 오류가 발생했습니다."
            }
        }

        init(statusCode: Int) {
            self = StatusCode(rawValue: statusCode) ?? .unknown
        }
    }
}
