import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State var isPresented = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(0 ..< viewModel.playerMaxCount) { index in
                        if index < viewModel.players.count {
                            let player = viewModel.players[index]
                            ProfileView(
                                imagePublisher: { url in
                                    await viewModel.getAvatarData(url: url)
                                },
                                name: player.nickname,
                                isHost: player.id == viewModel.host?.id,
                                imageUrl: player.avatarUrl
                            )
                        } else {
                            ProfileView(
                                imagePublisher: { url in
                                    await viewModel.getAvatarData(url: url)
                                },
                                name: nil,
                                isHost: false,
                                imageUrl: nil
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 12)
            }
            VStack {
                if viewModel.isHost {
                    GeometryReader { reader in
                        SnapperView(size: reader.size, currentMode: $viewModel.mode)
                    }
                } else {
                    GeometryReader { geometry in
                        ModeView(modeInfo: viewModel.mode, width: geometry.size.width * 0.85)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .background(Color.asLightGray)
    }
}
