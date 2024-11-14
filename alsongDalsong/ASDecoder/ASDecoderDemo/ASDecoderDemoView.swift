import SwiftUI

struct ASDecoderDemoView: View {
    @StateObject private var viewModel = ASDecoderDemoViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    if let userInfo = viewModel.userInfo {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("사용자 ID: \(userInfo.id)")
                            Text("사용자 이름: \(userInfo.userName)")
                            Text("아바타 URL: \(userInfo.userAvatarUrl.absoluteString)")
                            Text("생년월일: \(userInfo.userBirthDate, formatter: viewModel.customDateFormatter)")
                            Text("상태: \(userInfo.userStatus)")
                        }
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        Text("디코딩 시나리오를 선택하세요")
                    }
                }
                .padding()
                .multilineTextAlignment(.center)
                .background(Color(uiColor: .systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(spacing: 10) {
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
}

#Preview {
    ASDecoderDemoView()
}
