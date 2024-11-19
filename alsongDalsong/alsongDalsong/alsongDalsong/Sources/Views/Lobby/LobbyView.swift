import ASRepository
import SwiftUI
import ASEntity

struct LobbyView: View {
    //    @StateObject var viewModel: LobbyViewModel
    @ObservedObject var viewModel: LobbyViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .rotationEffect(.degrees(-90))
                        .tint(.black)
                }
                Spacer()
                Text(viewModel.roomNumber)
                    .foregroundStyle(.gray)
                    .font(.custom("DoHyeon-Regular", size: 48))
            }
            .font(.title)
            .padding()
            HStack(spacing: 15) {
                ForEach(viewModel.players) { player in
                    ProfileView(imageURL: player.avatarUrl, name: player.nickname, isHost: player.id == viewModel.host?.id)
                }
            }
            .padding()
            GeometryReader { reader in
                SnapperView(size: reader.size, modeInfos: ModeInfo.modeInfos, currentMode: $viewModel.mode)
            }
            
            ShareLink(item: URL(string: "alsongDalsong://roomNumber?\(viewModel.roomNumber)")!) {
                Image(systemName: "link")
                Text("초대코드!")
            }
            .buttonStyle(ASButtonStyle(backgroundColor: Color(.asYellow)))
            .padding(.vertical, 20)
            
            Button {
                
            } label: {
                Image(systemName: "play.fill")
                Text("시작하기!")
            }
            .buttonStyle(ASButtonStyle(backgroundColor: Color(.asMint)))
            .padding(.bottom, 20)

        }
        .background(Color.asLightGray)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

#Preview {
    LobbyView(viewModel: LobbyViewModel(mainRepository: MainRepository(roomNumber: "ASDKFJ")))
}
