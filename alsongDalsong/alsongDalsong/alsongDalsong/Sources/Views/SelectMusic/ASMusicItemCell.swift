import SwiftUI
import MusicKit

struct ASMusicItemCell: View {
    let artwork: Artwork?
    let title: String
    let artist: String
    var body: some View {
        HStack {
            if let artwork {
                ArtworkImage(artwork, width: 60)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.horizontal,8)
            } else {
                Image(systemName: "music.quarternote.3")
                .frame(width: 60, height: 60)
                .padding()
            }
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(artist)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    ASMusicItemCell(artwork: nil, title: "Dumb Dumb", artist: "레드벨벳")
}
