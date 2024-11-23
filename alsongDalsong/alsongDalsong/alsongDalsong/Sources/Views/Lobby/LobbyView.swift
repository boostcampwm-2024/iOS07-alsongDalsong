import ASContainer
import ASEntity
import ASRepository
import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State var isPresented = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
        
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(viewModel.players) { player in
                        ProfileView(
                            imagePublisher: viewModel.getAvatarData(url: player.avatarUrl),
                            name: player.nickname,
                            isHost: player.id == viewModel.host?.id
                        )
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
