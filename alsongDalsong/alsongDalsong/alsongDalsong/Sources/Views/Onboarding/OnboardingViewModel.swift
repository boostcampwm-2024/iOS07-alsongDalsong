import ASMusicKit
import ASRepositoryProtocol
import Combine
import Foundation

final class OnboardingViewModel: @unchecked Sendable {
    private var avatarRepository: AvatarRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var dataDownloadRepository: DataDownloadRepositoryProtocol
    private var avatars: [URL] = []
    private var selectedAvatar: URL?
    private var cancellables: Set<AnyCancellable> = []

    @Published var nickname: String = NickNameGenerator.generate()
    @Published var avatarData: Data?
    @Published var buttonEnabled: Bool = true

    init(avatarRepository: AvatarRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol,
         dataDownloadRepository: DataDownloadRepositoryProtocol)
    {
        self.avatarRepository = avatarRepository
        self.roomActionRepository = roomActionRepository
        self.dataDownloadRepository = dataDownloadRepository
        refreshAvatars()
    }

    func setNickname(with nickname: String) {
        self.nickname = nickname
    }

    private func fetchAvatars() {
        Task {
            avatars = try await avatarRepository.getAvatarUrls()
            avatars.shuffle()
            self.refreshAvatars()
        }
    }

    func refreshAvatars() {
        if avatars.isEmpty {
            fetchAvatars()
        }
        Task {
            guard let randomAvatarUrl = avatars.randomElement() else { return }
            selectedAvatar = randomAvatarUrl
            self.avatarData = await dataDownloadRepository.downloadData(url: randomAvatarUrl)
        }
    }

    @MainActor
    func authorizeAppleMusic() {
        let musicAPI = ASMusicAPI()
        Task {
            let _ = try await musicAPI.search(for: "뉴진스", 1, 1)
        }
    }

    @MainActor
    func joinRoom(roomNumber id: String) async throws -> String? {
        guard let selectedAvatar else { return nil }
        buttonEnabled = false
        do {
            buttonEnabled = try await roomActionRepository.joinRoom(nickname: nickname, avatar: selectedAvatar, roomNumber: id)
            return id
        } catch {
            buttonEnabled = true
            throw error
        }
    }

    @MainActor
    func createRoom() async throws -> String? {
        guard let selectedAvatar else { return nil }
        buttonEnabled = false
        do {
            let roomNumber = try await roomActionRepository.createRoom(nickname: nickname, avatar: selectedAvatar)
            return try await joinRoom(roomNumber: roomNumber)
        } catch {
            buttonEnabled = true
            throw error
        }
    }
}
