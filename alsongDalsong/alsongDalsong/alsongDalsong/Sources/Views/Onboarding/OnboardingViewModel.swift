import Foundation
import Combine
import ASRepository
import ASNetworkKit

final class OnboardingViewModel {
    // TODO: 닉네임 생성기 + 이미지 fetch (배열) + 참가하기 로직, 생성하기 로직
    private var onboardingRepository: OnboardingRepositoryProtocol
    private var avatars: [URL] = []
    private var selectedAvatar: URL?
    
    @Published var nickname: String = NickNameGenerator.generate()
    @Published var avatarData: Data?
    
    @Published var roomNumber: String = ""
    
    init(repository: OnboardingRepositoryProtocol) {
        self.onboardingRepository = repository
    }
    
    func setNickname(with nickname: String) {
        self.nickname = nickname
    }
    
    @MainActor
    func fetchAvatars() async {
        do {
            avatars = try await onboardingRepository.getAvatarUrls() ?? []
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func refreshAvatars() {
        Task {
            do {
                if avatars.isEmpty {
                    await fetchAvatars()
                }
                guard let url = avatars.randomElement() else { return }
                selectedAvatar = url
                
                guard let selectedAvatar else { return }
                avatarData = try await self.onboardingRepository.getAvatarData(url: selectedAvatar)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func joinRoom(roomNumber id: String) throws {
        Task {
            do {
                roomNumber = try await onboardingRepository.joinRoom(nickname: nickname, avatar: selectedAvatar, roomNumber: id)
            } catch {
                print(error)
                throw error
            }
        }
    }
    
    @MainActor
    func createRoom() throws {
        Task {
            do {
                let roomNumber = try await onboardingRepository.createRoom(nickname: nickname, avatar: selectedAvatar)
                if !roomNumber.isEmpty {
                    try joinRoom(roomNumber: roomNumber)
                }
            } catch {
                throw error
            }
        }
    }
}
