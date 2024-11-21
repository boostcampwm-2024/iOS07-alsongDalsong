import SwiftUI

struct SelectMusicView: View {
    
    @ObservedObject var viewModel: SelectMusicViewModel
    @State var searchTerm = ""
    
    var body: some View {
        VStack{
            HStack {
                ASMusicItemCell(imageURL: viewModel.selectedSong.artwork, title: viewModel.selectedSong.title, artist: viewModel.selectedSong.artistName)
                    .padding(EdgeInsets(top: 4, leading: 32, bottom: 4, trailing: 32))
                Spacer()
            }

            ASSearchBar(text: $searchTerm, placeHolder: "곡 제목을 검색하세요")
                .onChange(of: searchTerm) { newValue in
                    viewModel.searchMusic(text: newValue)
                }
            List(viewModel.searchList) { song in
                Button {
                    viewModel.handleSelectedSong(song: song)
                } label: {
                    ASMusicItemCell(imageURL: song.artwork, title: song.title, artist: song.artistName)
                        .tint(.black)
                }
            }
            Button {
                
            } label: {
                Text("선택 완료")
            }
            .buttonStyle(ASButtonStyle(backgroundColor: .asGreen))
        }
    }

}

#Preview {
//    SelectMusicView(v)
}
