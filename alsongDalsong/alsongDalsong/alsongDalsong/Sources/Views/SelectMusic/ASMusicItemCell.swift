import SwiftUI

struct ASMusicItemCell: View {
    let imageURL: URL?
    let title: String
    let artist: String
    var body: some View {
        HStack {
            if let imageURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
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
    ASMusicItemCell(imageURL: URL(string: "https://i.namu.wiki/i/Xy0ciMmQU5kRJEWrNBKejOFZbQu7kLwZhCbXLuaY9cWQH_maTUCfT8njMyT3EbOK2nXSPo-3Go5FgJ5Na4aeTw.webp")!, title: "Dumb Dumb", artist: "레드벨벳")
}
