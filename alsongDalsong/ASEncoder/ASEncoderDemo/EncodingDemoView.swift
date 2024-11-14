import SwiftUI

struct EncodingDemoView: View {
    @ObservedObject var viewModel = EncodingDemoViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("사용자 이름")) {
                        TextField("이름을 입력하세요", text: $viewModel.userInfo.userName)
                    }

                    Section(header: Text("아바타 URL")) {
                        TextField("URL을 입력하세요", text: $viewModel.userAvatarUrl)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                    }

                    Section(header: Text("생년월일")) {
                        DatePicker(
                            "생년월일",
                            selection: $viewModel.userInfo.userBirthDate,
                            displayedComponents: .date
                        )
                    }

                    Section(header: Text("사용자 상태")) {
                        Picker("상태", selection: $viewModel.userInfo.userStatus) {
                            ForEach(UserStatus.allCases) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                    }
                    if let jsonDisplayText = viewModel.jsonDisplayText {
                        Text(jsonDisplayText)
                            .padding()
                            .listRowSeparator(.hidden)
                            .listRowInsets(.none)
                            .listRowBackground(
                                Color(uiColor: .systemGroupedBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    .padding()
                            )
                    }
                }
                .listStyle(.plain)
            }
            .onReceive(viewModel.$userInfo) { _ in
                viewModel.updateJSON()
            }
            .navigationTitle("Encoding Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EncodingDemoView()
}
