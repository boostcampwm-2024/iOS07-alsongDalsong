import SwiftUI

struct ASDecoderDemoView: View {
    @StateObject private var viewModel = ASDecoderDemoViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    if viewModel.jsonString == nil {
                        VStack(alignment: .leading) {
                            titleText("디코딩할 자료 구조")
                            Text(viewModel.modelString)
                        }
                        .grayBackground()
                    }
                    if let jsonString = viewModel.jsonString {
                        VStack(alignment: .leading) {
                            titleText("원본 JSON")
                            Text(jsonString)
                        }
                        .secondaryGradientBackground()
                    }
                }

                Group {
                    if let userInfo = viewModel.userInfo {
                        VStack(alignment: .leading) {
                            titleText("디코딩 정보")
                            Text("사용자 ID: \(userInfo.id)")
                            Text("사용자 이름: \(userInfo.userName)")
                            Text("아바타 URL: \(userInfo.userAvatarUrl.absoluteString)")
                            Text("생년월일: \(userInfo.userBirthDate, formatter: viewModel.customDateFormatter)")
                            Text("상태: \(userInfo.userStatus)")
                        }
                        .primaryGradientBackground()
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(alignment: .leading) {
                            titleText("디코딩 정보")
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        .primaryGradientBackground()
                    } else {
                        Text("디코딩 시나리오를 선택하세요")
                            .grayBackground()
                    }
                }

                VStack {
                    Button("정상 JSON 디코딩") {
                        Task {
                            await viewModel.loadUserInfo(from: .correct)
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("필드 누락 JSON 디코딩") {
                        Task {
                            await viewModel.loadUserInfo(from: .missing)
                        }
                    }
                    .buttonStyle(.bordered)

                    Button("잘못된 형식 JSON 디코딩") {
                        Task {
                            await viewModel.loadUserInfo(from: .incorrect)
                        }
                    }
                    .buttonStyle(.bordered)

                    Button("초기화") {
                        viewModel.reset()
                    }
                    .foregroundColor(.red)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Decoding Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    func titleText(_ string: String) -> some View {
        Text(string)
            .font(.title2)
            .foregroundStyle(Color.white)
            .bold()
    }
}

#Preview {
    ASDecoderDemoView()
}
