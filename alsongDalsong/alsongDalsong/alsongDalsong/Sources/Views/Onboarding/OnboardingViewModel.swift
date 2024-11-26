import ASNetworkKit
import ASRepository
import Combine
import Foundation

final class OnboardingViewModel {
    private var avatarRepository: AvatarRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var avatars: [URL] = []
    private var selectedAvatar: URL?
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var nickname: String = NickNameGenerator.generate()
    @Published var avatarData: Data?
    @Published var roomNumber: String = ""
    @Published var buttonEnabled: Bool = true
    @Published var joinResponse: Bool = true
    
    init(avatarRepository: AvatarRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol)
    {
        self.avatarRepository = avatarRepository
        self.roomActionRepository = roomActionRepository
        refreshAvatars()
    }
    
    func setNickname(with nickname: String) {
        self.nickname = nickname
    }
    
    private func fetchAvatars() {
        avatarRepository.getAvatarUrls()
            .receive(on: DispatchQueue.main)
            .map { $0.shuffled() }
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] urls in
                self?.avatars = urls
                self?.refreshAvatars()
            }
            .store(in: &cancellables)
    }
    
    func refreshAvatars() {
        if avatars.isEmpty {
            fetchAvatars()
        }
        guard let randomAvatar = avatars.randomElement() else { return }
        selectedAvatar = randomAvatar
        
        avatarRepository.getAvatarData(url: randomAvatar)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] data in
                self?.avatarData = data
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func joinRoom(roomNumber id: String) {
        guard let selectedAvatar else { return }
        buttonEnabled = false
        Task {
            do {
                self.buttonEnabled = try await roomActionRepository.joinRoom(nickname: nickname, avatar: selectedAvatar, roomNumber: id)
                self.roomNumber = id
            } catch {
                self.buttonEnabled = true
                self.joinResponse = false
            }
        }
    }
    
    @MainActor
    func createRoom() async {
        guard let selectedAvatar else { return }
        buttonEnabled = false
        Task {
            do {
                let roomNumber = try await roomActionRepository.createRoom(nickname: nickname, avatar: selectedAvatar)
                self.joinRoom(roomNumber: roomNumber)
            } catch {
                self.buttonEnabled = true
                self.joinResponse = false
            }
        }
    }
}
