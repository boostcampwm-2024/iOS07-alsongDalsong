import ASContainer
import ASEntity
import ASRepository
import Combine
import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State var isPresented = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(0 ..< viewModel.playerMaxCount) { index in
                        if index < viewModel.players.count {
                            let player = viewModel.players[index]
                            ProfileView(
                                imagePublisher: viewModel.getAvatarData(url: player.avatarUrl),
                                name: player.nickname,
                                isHost: player.id == viewModel.host?.id
                            )
                        } else {
                            ProfileView(
                                imagePublisher: Just(Data()).setFailureType(to: Error.self).eraseToAnyPublisher(),
                                name: nil,
                                isHost: false
                            )
                        }
                    }
                }
                .padding()
            }

            GeometryReader { reader in
                SnapperView(size: reader.size, modeInfos: ModeInfo.modeInfos, currentMode: $viewModel.mode)
            }
        }
        .background(Color.asLightGray)
    }
}
