import SwiftUI

struct ASDecoderDemoView: View {
    @StateObject private var viewModel = ASDecoderDemoViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    VStack(alignment: .leading) {
                        if viewModel.jsonString == nil {
                            titleText("디코딩할 자료 구조")
                            Text(viewModel.modelString)
                        }

                        if let jsonString = viewModel.jsonString {
                            titleText("원본 JSON")
                            Text(jsonString)
                        }
                    }
                }
                .padding()
                .foregroundStyle(Color.white)
                .background(LinearGradient(colors: [.red, .purple, .yellow],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Group {
                    VStack(alignment: .leading) {
                        if let userInfo = viewModel.userInfo {
                            titleText("디코딩 정보")
                            Text("사용자 ID: \(userInfo.id)")
                            Text("사용자 이름: \(userInfo.userName)")
                            Text("아바타 URL: \(userInfo.userAvatarUrl.absoluteString)")
                            Text("생년월일: \(userInfo.userBirthDate, formatter: viewModel.customDateFormatter)")
                            Text("상태: \(userInfo.userStatus)")
                        } else if let errorMessage = viewModel.errorMessage {
                            titleText("디코딩 정보")
                            Text(errorMessage)
                                .foregroundColor(.red)
                        } else {
                            Text("디코딩 시나리오를 선택하세요")
                        }
                    }
                }
                .padding()
                .multilineTextAlignment(.center)
                .background(LinearGradient(colors: [.cyan, .green, .yellow],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 10))

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
