import Foundation
import Combine

actor OnboardingViewModel: Sendable {
    // TODO: 닉네임 생성기 + 이미지 fetch (배열) + 참가하기 로직, 생성하기 로직
    private var onboardingRepository: OnboardingRepositoryProtocol = OnboradingRepository()
    private var avatars: [URL] = []
    
    @Published var onboardingData = OnboardingData()
    @Published var isButtonEnabled: Bool = true
    
    var isJoined: Bool = false
    
    private var continuations: [AsyncStream<Bool>.Continuation] = []
    
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
    
    func valueStream() -> AsyncStream<Bool> {
        // 새로운 AsyncStream 생성 및 반환
        return AsyncStream { continuation in
            // 초기 값 전달
            continuation.yield(isJoined)
            // 구독자 목록에 추가
            continuations.append(continuation)
        }
    }
    
    func joinRoom(roomNumber: String) {
        Task {
            do {
                isButtonEnabled = false
                
                isJoined = try await onboardingRepository.joinRoom(nickname: onboardingData.nickname, avatar: onboardingData.avatarURL, roomNumber: roomNumber)
                for continuation in continuations {
                    continuation.yield(isJoined)
                }
                
            } catch {
                isButtonEnabled = true
            }
        }
    }
    
    func createRoom() {
        Task {
            do {
                isButtonEnabled = false
                let roomNumber = try await onboardingRepository.createRoom(nickname: onboardingData.nickname, avatar: onboardingData.avatarURL)
                if !roomNumber.isEmpty {
                    joinRoom(roomNumber: roomNumber)
                }
            } catch {
                isButtonEnabled = true
            }
        }
    }
}

struct OnboardingData {
    private(set) var nickname: String = NickNameGenerator.generate()
    var avatarURL: URL?
    
    mutating func setNickname(with nickname: String) {
        self.nickname = nickname
    }
    
    mutating func setAvatarURL(with url: URL) {
        self.avatarURL = url
    }
    
}
