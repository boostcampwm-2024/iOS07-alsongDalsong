import Combine
import Foundation
import SwiftUI

struct AsyncImageView: View {
    let imagePublisher: (URL?) async -> Data?
    let url: URL?
    @State private var imageData: Data?

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 5))
            }
        }
        .onAppear {
            Task {
                imageData = await imagePublisher(url)
            }
        }
    }
}

struct ProfileView: View {
    let imagePublisher: (URL?) async -> Data?
    let name: String?
    let isHost: Bool
    let imageUrl: URL?

    var body: some View {
        VStack {
            AsyncImageView(imagePublisher: imagePublisher, url: imageUrl)
                .background(Color.asMint)
                .frame(width: 75, height: 75)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 5))
                .overlay(alignment: .top) {
                    isHost ? Image(systemName: "crown.fill")
                        .foregroundStyle(.asYellow)
                        .font(.system(size: 20))
                        .offset(y: -20)
                        : nil
                }
                .padding(.bottom, 4)
            if let name {
                Text(name)
                    .font(.doHyeon(size: 16))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            } else {
                Text("비어 있음")
                    .font(.doHyeon(size: 16))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(width: 75)
    }
}
