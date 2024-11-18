import Foundation
import Combine

final class OnboardingViewModel {
    // TODO: 닉네임 생성기 + 이미지 fetch (배열) + 참가하기 로직, 생성하기 로직
    private var onboardingRepository: OnboardingRepositoryProtocol = OnboradingRepository()
    private var avatars: [URL] = []
    private var onboardingData = OnboardingData()
    var publisher = PassthroughSubject<OnboardingData, Never>()
    
    init() {
        refreshAvatars()
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
    
    @MainActor
    func joinRoom(roomNumber id: String) throws {
        Task {
            do {
                let roomNumber = try await onboardingRepository.joinRoom(nickname: onboardingData.nickname, avatar: onboardingData.avatarURL, roomNumber: id)
                onboardingData.setRoomNumber(with: roomNumber)
            } catch {
                throw error
            }
        }
    }
    
    @MainActor
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
