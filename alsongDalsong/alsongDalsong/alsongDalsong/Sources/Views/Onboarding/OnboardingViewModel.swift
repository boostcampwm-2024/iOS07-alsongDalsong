import ASNetworkKit
import ASRepository
import Combine
import Foundation

final class OnboardingViewModel: @unchecked Sendable {
    private var avatarRepository: AvatarRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var avatars: [URL] = []
    private var selectedAvatar: URL?
    private var cancellables: Set<AnyCancellable> = []

    @Published var nickname: String = NickNameGenerator.generate()
    @Published var avatarData: Data?
    @Published var buttonEnabled: Bool = true

    init(avatarRepository: AvatarRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol) {
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
                    case let .failure(error):
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
                    case let .failure(error):
                        print(error.localizedDescription)
                }
            } receiveValue: { [weak self] data in
                self?.avatarData = data
            }
            .store(in: &cancellables)
    }

    @MainActor
    func joinRoom(roomNumber id: String) async -> String? {
        guard let selectedAvatar else { return nil }
        buttonEnabled = false
        do {
            buttonEnabled = try await roomActionRepository.joinRoom(nickname: nickname, avatar: selectedAvatar, roomNumber: id)
            return id
        } catch {
            buttonEnabled = true
            return nil
        }
    }

    @MainActor
    func createRoom() async -> String? {
        guard let selectedAvatar else { return nil }
        buttonEnabled = false
        do {
            let roomNumber = try await roomActionRepository.createRoom(nickname: nickname, avatar: selectedAvatar)
            return await joinRoom(roomNumber: roomNumber)
        } catch {
            buttonEnabled = true
            return nil
        }
    }
}
