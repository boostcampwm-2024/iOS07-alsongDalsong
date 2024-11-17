import Foundation
import Combine

final class OnboardingViewModel {
    // TODO: 닉네임 생성기 + 이미지 fetch (배열) + 참가하기 로직, 생성하기 로직
    var onboardingData = OnboardingData()
    private var onboardingRepository: OnboardingRepositoryProtocol!
    
    private var avatars: [URL] = []
    
    func setNickname(with nickname: String) {
    }
    
    func setAvatarURL(with url: URL) {
        
    }
    
    func fetchAvatars() {
        self.avatars = [URL(string: "https://i.namu.wiki/i/UPNrk6CU0c-W4lE4dt9ire9gJQEcF3FnlSnZG6v_RgDzP40M6Xhm0aIWrr4bakrmJFl2zQbbCJsiWe_QKuNbag.webp")!]
    }
    
    func joinRoom(roomNumber: String) {
//        Task {
//            onboardingRepository.joinRoom(nickname: onboardingData.nickname, avatar: onboardingData.avatarURL, roomNumber: roomNumber) { result in
//                if result {
//                }
//            }
//        }
    }
    
    func createRoom() {
        
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
