import ASNetworkKit
import ASRepository
import Combine
import Foundation

final class OnboardingViewModel {
    // TODO: 닉네임 생성기 + 이미지 fetch (배열) + 참가하기 로직, 생성하기 로직
    private var avatarRepository: AvatarRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var avatars: [URL] = []
    private var selectedAvatar: URL?
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var nickname: String = NickNameGenerator.generate()
    @Published var avatarData: Data?
    @Published var roomNumber: String = ""
    @Published var buttonEnabled: Bool = true
    
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
    
    func joinRoom(roomNumber id: String) {
        guard let selectedAvatar else { return }
        self.buttonEnabled = false
        roomActionRepository.joinRoom(nickname: nickname, avatar: selectedAvatar, roomNumber: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.buttonEnabled = true
                }
            } receiveValue: { [weak self] isSuccess in
                if isSuccess {
                    self?.roomNumber = id
                    self?.buttonEnabled = true
                }
            }
            .store(in: &cancellables)
    }
    
    func createRoom() {
        guard let selectedAvatar else { return }
        self.buttonEnabled = false
        roomActionRepository.createRoom(nickname: nickname, avatar: selectedAvatar)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.buttonEnabled = true
                }
            } receiveValue: { [weak self] roomNumber in
                self?.joinRoom(roomNumber: roomNumber)
            }
            .store(in: &cancellables)
    }
}
