import Combine
import Foundation
import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    private var cancellable: AnyCancellable?

    func loadImage(from publisher: AnyPublisher<Data?, Error>) {
        cancellable = publisher
            .map { data -> UIImage? in
                guard let data else { return nil }
                return UIImage(data: data) // Data를 UIImage로 변환
            }
            .replaceError(with: nil) // 에러 발생 시 nil로 대체
            .receive(on: DispatchQueue.main) // UI 업데이트는 메인 스레드에서
            .assign(to: \.image, on: self) // 이미지 업데이트
    }
}

struct AsyncImageView: View {
    @StateObject private var loader = ImageLoader()
    let imagePublisher: AnyPublisher<Data?, Error>

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image) // UIImage를 SwiftUI Image로 변환
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 5))
            }
        }
        .onAppear {
            loader.loadImage(from: imagePublisher) // 이미지 로드 시작
        }
    }
}

struct ProfileView: View {
    let imagePublisher: AnyPublisher<Data?, Error>
    let name: String?
    let isHost: Bool

    var body: some View {
        VStack {
            AsyncImageView(imagePublisher: imagePublisher)
                .background(Color.asMint)
                .frame(width: 75, height: 75)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 5))
                .overlay(alignment: .bottomTrailing) {
                    isHost ? Image(systemName: "crown.fill")
                        .foregroundStyle(.asYellow)
                        .font(.system(size: 24))
                        : nil
                }
            if let name {
                Text(name)
                    .font(.custom("DoHyeon-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 75, maxHeight: 32.0)
            } else {
                Text("비어 있음")
                    .font(.custom("DoHyeon-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 75, maxHeight: 32.0)
            }
        }
    }
}

#Preview {
    ProfileView(imagePublisher: Just(Data()).setFailureType(to: Error.self).eraseToAnyPublisher(), name: "틀틀보", isHost: true)
}
