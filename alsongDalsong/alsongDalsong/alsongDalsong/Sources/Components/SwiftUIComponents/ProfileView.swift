import Foundation
import SwiftUI

struct ProfileView: View {
    let imageURL: URL?
    let name: String?
    let isHost: Bool
    
    var body: some View {
        VStack {
            ZStack {
                if let imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                    }
                    .background(Color.asMint)
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 5))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 5))
                }
                isHost ? Image(systemName: "crown.fill")
                    .foregroundStyle(.asYellow)
                    .font(.system(size: 24))
                    .padding(.top,40)
                    .padding(.leading,40)
                : nil
            }
            .padding(.vertical,2)
            if let name {
                Text(name)
                    .font(.custom("DoHyeon-Regular", size: 16))
            } else {
                Text("비어 있음")
                    .font(.custom("DoHyeon-Regular", size: 16))
            }
        }
    }
}

#Preview {
    ProfileView(imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/alsongdalsong-boostcamp.firebasestorage.app/o/avatar%2FDanielle1.png?alt=media&token=e6ba52fc-d67d-4792-b873-ec5dda20b64d")!, name: "틀틀보", isHost: true)
}
