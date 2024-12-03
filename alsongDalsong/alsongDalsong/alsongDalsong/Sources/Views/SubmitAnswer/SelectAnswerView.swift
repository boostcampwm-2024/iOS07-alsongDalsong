import ASMusicKit
import SwiftUI

struct SelectAnswerView: View {
    @ObservedObject var viewModel: SubmitAnswerViewModel
    @State var searchTerm = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    private let debouncer = Debouncer(delay: 0.5)

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ASMusicItemCell(music: viewModel.selectedMusic, fetchArtwork: { url in
                        await viewModel.downloadArtwork(url: url)
                    })
                    .scaleEffect(1.1)
                    Spacer()
                    Button {
                        if viewModel.selectedMusic != nil {
                            viewModel.isPlaying.toggle()
                        }
                    } label: {
                        if #available(iOS 17.0, *) {
                            Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                                .font(.largeTitle)
                                .contentTransition(.symbolEffect(.replace.offUp))
                        } else {
                            Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                                .font(.largeTitle)
                        }
                    }
                    .tint(.primary)
                    .frame(width: 60)
                }
                .padding(16)
                .onTapGesture {
                    isFocused = false
                }

                ASSearchBar(text: $searchTerm, placeHolder: "노래를 선택하세요")
                    .onChange(of: searchTerm) { newValue in
                        debouncer.debounce {
                            Task {
                                if newValue.isEmpty { viewModel.resetSearchList() }
                                try await viewModel.searchMusic(text: newValue)
                            }
                        }
                    }
                    .focused($isFocused)
                if viewModel.isSearching {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2.0)
                        Spacer()
                    }
                } else {
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
                    .edgesIgnoringSafeArea(.bottom)
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .background(.asLightGray)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        viewModel.stopMusic()
                        dismiss()
                    }
                }
            }
        }
    }
}
