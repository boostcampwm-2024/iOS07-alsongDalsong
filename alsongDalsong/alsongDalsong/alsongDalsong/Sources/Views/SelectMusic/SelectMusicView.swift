// import Combine
import SwiftUI

struct SelectMusicView: View {
    @ObservedObject var viewModel: SelectMusicViewModel
    @State var searchTerm = ""
    private let debouncer = Debouncer(delay: 0.5)
    var body: some View {
        VStack {
            HStack {
                ASMusicItemCell(music: viewModel.selectedMusic, fetchArtwork: { url in
                    await viewModel.downloadArtwork(url: url)
                })
                Spacer()
                Button {
                    viewModel.isPlaying.toggle()
                } label: {
                    viewModel.isPlaying ?
                        Image(systemName: "pause.fill") : Image(systemName: "play.fill")
                }
                .tint(.primary)
                .frame(width: 60)
                .padding(.trailing, 12)
            }
            .frame(height: 100)
            ASSearchBar(text: $searchTerm, placeHolder: "곡 제목을 검색하세요")
                .onChange(of: searchTerm) { newValue in
                    debouncer.debounce {
                        Task {
                            if newValue.isEmpty { viewModel.resetSearchList() }
                            try await viewModel.searchMusic(text: newValue)
                        }
                    }
                }
            if searchTerm.isEmpty {
                VStack(alignment: .center) {
                    Spacer()
                    Text("음악을 선택하세요!")
                        .font(.custom("DoHyeon-Regular", size: 36))
                    Spacer()
                }
            } else {
                List(viewModel.searchList) { music in
                    Button {
                        viewModel.handleSelectedSong(with: music)
                    } label: {
                        ASMusicItemCell(music: music, fetchArtwork: { url in
                            await viewModel.downloadArtwork(url: url)
                        })
                        .tint(.black)
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(.asLightGray)
    }
}

#Preview {
//    SelectMusicView(v)
}
