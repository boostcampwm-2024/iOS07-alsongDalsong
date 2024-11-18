import Foundation
import Combine

actor OnboardingViewModel: Sendable {
    // TODO: 닉네임 생성기 + 이미지 fetch (배열) + 참가하기 로직, 생성하기 로직
    private var onboardingRepository: OnboardingRepositoryProtocol = OnboradingRepository()
    private var avatars: [URL] = []
    
    private var onboardingData = OnboardingData()
    private var continuations: [AsyncStream<OnboardingData>.Continuation] = []
    
    init() {
        Task {
            await refreshAvatars()
            await publish()
        }
    }
    
    func setNickname(with nickname: String) {
        onboardingData.setNickname(with: nickname)
    }
    
    func setAvatarURL(with url: URL) {
        onboardingData.setAvatarURL(with: url)
    }
    
    func fetchAvatars() {
        self.avatars = [URL(string: "https://i.namu.wiki/i/UPNrk6CU0c-W4lE4dt9ire9gJQEcF3FnlSnZG6v_RgDzP40M6Xhm0aIWrr4bakrmJFl2zQbbCJsiWe_QKuNbag.webp")!]
    }
    
    func refreshAvatars() {
        if avatars.isEmpty {
            fetchAvatars()
        }
        guard let randomAvatar = avatars.randomElement() else { return }
        self.onboardingData.setAvatarURL(with: randomAvatar)
    }
    
    func valueStream() -> AsyncStream<OnboardingData> {
        // 새로운 AsyncStream 생성 및 반환
        return AsyncStream { continuation in
            // 초기 값 전달
            continuation.yield(onboardingData)
            // 구독자 목록에 추가
            continuations.append(continuation)
        }
    }
    func publish() {
        for continuation in continuations {
            continuation.yield(onboardingData)
        }
    }
    
    func joinRoom(roomNumber id: String) throws {
        Task {
            do {
                let roomNumber = try await onboardingRepository.joinRoom(nickname: onboardingData.nickname, avatar: onboardingData.avatarURL, roomNumber: id)
                onboardingData.setRoomNumber(with: roomNumber)
                publish()
                
            } catch {
                throw error
            }
        }
    }
    
    func createRoom() throws {
        Task {
            do {
                let roomNumber = try await onboardingRepository.createRoom(nickname: onboardingData.nickname, avatar: onboardingData.avatarURL)
                if !roomNumber.isEmpty {
                    try joinRoom(roomNumber: roomNumber)
                }
            } catch {
                throw error
            }
        }
    }
}

struct OnboardingData {
    private(set) var nickname: String = NickNameGenerator.generate()
    var avatarURL: URL?
    var roomNumber: String?
    
    mutating func setNickname(with nickname: String) {
        self.nickname = nickname
    }
    
    mutating func setAvatarURL(with url: URL) {
        self.avatarURL = url
    }
    
    mutating func setRoomNumber(with roomNumber: String) {
        self.roomNumber = roomNumber
    }
    
}
