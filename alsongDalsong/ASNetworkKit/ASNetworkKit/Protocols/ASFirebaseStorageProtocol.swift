import Foundation

public protocol ASFirebaseStorageProtocol {
    // 플레이어 아바타 이미지 URL들을 가져오는 함수.
    func getAvatarUrls() async throws -> [URL]
}
