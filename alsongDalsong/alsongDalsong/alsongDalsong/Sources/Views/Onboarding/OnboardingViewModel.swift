import Foundation
import Combine
import ASRepository

final class OnboardingViewModel {
    // TODO: 닉네임 생성기 + 이미지 fetch (배열) + 참가하기 로직, 생성하기 로직
    private var onboardingRepository: OnboardingRepositoryProtocol = OnboradingRepository()
    private var avatars: [URL] = []
    
    @Published var nickname: String = NickNameGenerator.generate()
    @Published var avatarURL: URL?
    @Published var roomNumber: String
    
    init() {
        refreshAvatars()
    }
    
    func setNickname(with nickname: String) {
        self.nickname = nickname
    }
    
    func fetchAvatars() {
        self.avatars = [
            URL(string: "https://i.namu.wiki/i/UPNrk6CU0c-W4lE4dt9ire9gJQEcF3FnlSnZG6v_RgDzP40M6Xhm0aIWrr4bakrmJFl2zQbbCJsiWe_QKuNbag.webp")!,
            URL(string: "https://i.namu.wiki/i/eNLun7GiuhVWMSMV8dTsW2Q1HPIS6Q6VgEw6nNZGheATcye9aVWtQAxH8aEP3eG_2QLbd7lu9BEKnz_lsmnb3A.gif")!,
            URL(string: "https://i.namu.wiki/i/ipynokVLK3TAvWxj4zzJ9fnLjvz6IRnTYy8lKkgnJYquv1vWl4SDnA9OOdB0OiDYfG13WusRKc_j6zdxkCislQ.webp")!,
            URL(string: "https://i.namu.wiki/i/chcr-vg2cJIbKZ4eoQDh0_1iVnK41MRfV5fQJ4hjvAhT7gyBuTzr2PvnxUExDvXFA9aXFV02VqjLKkkxVa8N1Q.webp")!,
            URL(string: "https://i.namu.wiki/i/NAAI2TdyvYSIaKl_rjCCARFDbrn-W8vB18NAfS7DTR2rAF3lMkAdXkexG-TqyavIaWO0PphIVJMO6HGjusL5qA.webp")!,
            URL(string:"https://i.namu.wiki/i/UeV-hSjVoUixzROj9YmJhIu6bL4En7AkCOeuUMuhxSXhY9VlKaUy9e1a9KReU_dYqE0WQw5PQH_APL_R1iDrtA.webp")!
        ]
    }
    
    func refreshAvatars() {
        if avatars.isEmpty {
            fetchAvatars()
        }
        guard let randomAvatar = avatars.randomElement() else { return }
        avatarURL = randomAvatar
    }
    
    @MainActor
    func joinRoom(roomNumber id: String) throws {
        Task {
            do {
                roomNumber = try await onboardingRepository.joinRoom(nickname: nickname, avatar: avatarURL, roomNumber: id)
            } catch {
                throw error
            }
        }
    }
    
    @MainActor
    func createRoom() throws {
        Task {
            do {
                roomNumber = try await onboardingRepository.createRoom(nickname: nickname, avatar: avatarURL)
                if !roomNumber.isEmpty {
                    try joinRoom(roomNumber: roomNumber)
                }
            } catch {
                throw error
            }
        }
    }
}
