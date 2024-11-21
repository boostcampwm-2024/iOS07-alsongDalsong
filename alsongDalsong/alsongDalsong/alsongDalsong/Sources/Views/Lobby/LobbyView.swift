import ASEntity
import ASRepository
import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack {
                Button {
                    viewModel.leaveRoom()
                    dismiss()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .rotationEffect(.degrees(-90))
                        .tint(.asBlack)
                }
                Spacer()
                Text(viewModel.roomNumber)
                    .foregroundStyle(.gray)
                    .font(.custom("DoHyeon-Regular", size: 48))
            }
            .font(.title)
            .padding()
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

            ShareLink(item: URL(string: "alsongDalsong://?roomnumber=\(viewModel.roomNumber)")!) {
                Image(systemName: "link")
                Text("초대코드!")
            }
            .buttonStyle(ASButtonStyle(backgroundColor: Color(.asYellow)))
            .padding(.vertical, 20)

            Button {
                viewModel.gameStart()
            } label: {
                Image(systemName: "play.fill")
                Text("시작하기!")
            }
            .buttonStyle(ASButtonStyle(backgroundColor: Color(.asMint)))
            .padding(.bottom, 20)
        }
        .background(Color.asLightGray)
    }
}
