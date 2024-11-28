import ASMusicKit
import SwiftUI

struct SelectAnswerView: View {
    @ObservedObject var viewModel: SubmitAnswerViewModel
    @State var searchTerm = ""
    @Environment(\.dismiss) private var dismiss
    private let debouncer = Debouncer(delay: 0.5)

    var body: some View {
        VStack {
            HStack {
                ASMusicItemCell(music: viewModel.selectedMusic, fetchArtwork: { url in
                    await viewModel.downloadArtwork(url: url)
                })
                .padding(EdgeInsets(top: 4, leading: 32, bottom: 4, trailing: 12))
                Spacer()
                Button {
                    viewModel.stopMusic()
                    dismiss()
                } label: {
                    Text("선택완료")
                        .font(.custom("DoHyeon-Regular", size: 16))
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 60)
                .padding(.trailing, 12)
            }
            .frame(height: 100)

            ASSearchBar(text: $searchTerm, placeHolder: "노래를 선택하세요")
                .onChange(of: searchTerm) { newValue in
                    debouncer.debounce {
                        Task {
                            if newValue.isEmpty { viewModel.resetSearchList() }
                            try await viewModel.searchMusic(text: newValue)
                        }
                    }
                }
            List(viewModel.searchList) { music in
                Button {
                    viewModel.handleSelectedMusic(with: music)
                } label: {
                    ASMusicItemCell(music: music, fetchArtwork: { url in
                        await viewModel.downloadArtwork(url: url)
                    })
                    .tint(.black)
                }
            }
            .listStyle(.plain)
        }
        .background(.asLightGray)
    }
}

#Preview {
//    SelectMusicView(v)
}
