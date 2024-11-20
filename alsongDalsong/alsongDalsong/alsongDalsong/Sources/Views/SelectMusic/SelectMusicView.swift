import SwiftUI
import MusicKit
import ASMusicKit

struct SelectMusicView: View {
    
    @State private var searchTerm = ""
    @State var searchList: [ASSong] = []
    
    let musicAPI = ASMusicAPI()
    
    var body: some View {
        VStack{
            ASSearchBar(text: $searchTerm, placeHolder: "곡 제목을 검색하세요")
                .onChange(of: searchTerm) { newValue in
                    searchMusic(text: newValue)
                }
            List(searchList) { song in
                MusicCell(musicInfo: song)
            }
        }
    }
    
    func searchMusic(text: String) {
        Task {
            searchList = await musicAPI.search(for: text)
        }
    }
}

struct MusicCell: View {
    let musicInfo: ASSong
    var body: some View {
        VStack {
            Text(musicInfo.title)
            Text(musicInfo.artistName)
        }
    }
}

#Preview {
    SelectMusicView()
}
