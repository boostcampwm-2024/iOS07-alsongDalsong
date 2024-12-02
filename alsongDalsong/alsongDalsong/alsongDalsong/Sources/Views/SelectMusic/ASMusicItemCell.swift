import ASEntity
import SwiftUI

struct ASMusicItemCell: View {
    @State private var artworkData: Data?
    let music: Music?
    let fetchArtwork: (URL?) async -> Data?

    var body: some View {
        HStack {
            if let artworkData, let uiImage = UIImage(data: artworkData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.horizontal, 8)
            } else if let music, let artworkColor = music.artworkBackgroundColor {
                Rectangle()
                    .foregroundColor(Color(hex: artworkColor))
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.horizontal, 8)
            } else {
                Image(systemName: "music.quarternote.3")
                    .frame(width: 60, height: 60)
                    .background(.asSystem)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.horizontal, 8)
            }
            VStack(alignment: .leading) {
                Text(music?.title ?? "선택된 곡 없음")
                    .font(.doHyeon(size: 16))
                    .lineLimit(1)
                Text(music?.artist ?? "아티스트")
                    .foregroundStyle(.gray)
                    .font(.doHyeon(size: 16))
                    .lineLimit(1)
            }
        }
        .task(id: music) {
            artworkData = nil
            if let music {
                artworkData = await fetchArtwork(music.artworkUrl)
            }
        }
    }
}

#Preview {
    ASMusicItemCell(music: Music()) { _ in nil }
}
