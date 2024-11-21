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
            // TODO:- 버튼 사이즈 안맞음
            ShareLink(item: URL(string: "alsongDalsong://?roomnumber=\(viewModel.roomNumber)")!) {
                Image(systemName: "link")
                Text("초대코드!")
            }
            .buttonStyle(ASButtonStyle(backgroundColor: Color(.asYellow)))
            .padding(.top, 20)
        }
        .background(Color.asLightGray)
    }
}
