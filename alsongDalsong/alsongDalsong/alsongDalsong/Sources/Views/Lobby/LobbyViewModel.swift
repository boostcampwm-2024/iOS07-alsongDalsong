import Foundation
import ASNetworkKit
import ASEntity

final class LobbyViewModel: ObservableObject {
    private let repository: LobbyRepository = LobbyRepository()
    
    let cards: [ModeInfo] = [
        ModeInfo(title: "허밍", imageName: "fake", description: String(localized: "HummingModeDescription")),
        ModeInfo(title: "하모니", imageName: "fake", description: String(localized: "HarmonyModeDescription")),
        ModeInfo(title: "이구동성", imageName: "fake", description: String(localized: "SyncModeDescription")),
        ModeInfo(title: "찰나의순간", imageName: "fake", description: String(localized: "InstantModeDescription")),
        ModeInfo(title: "TTS", imageName: "fake", description: String(localized: "TTSModeDescription")),
    ]
    
    @Published var lobbyData: LobbyData? {
        didSet {
            print(lobbyData)
        }
    }
    
    func fetchData(roomNumber: String) {
        repository.observeLobby(roomNumber: roomNumber) { [weak self] lobbyData in
            self?.lobbyData = lobbyData
        }
    }
}

struct LobbyData {
    let roomNumber: String
    let players: [Player]
    let mode: Mode
    var isHost: Bool
}
